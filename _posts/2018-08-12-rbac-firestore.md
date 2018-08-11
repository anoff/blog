---
layout: post
title: RBAC with Google Firestore
subtitle: Implementing Role Based Access Control with Google's serverless database
tags: [google, serverless, web]
image: /img/assets/rbac-firestore/logo.png
share-img: /img/assets/rbac-firestore/logo.png
---

![Zombies not allowed]({{ site.baseurl }}/img/assets/rbac-firestore/logo.png)

This post will explain how to implement role based access control ([RBAC](https://en.wikipedia.org/wiki/Role-based_access_control)) using the Google Firestore serverless database.

<!-- TOC depthFrom:2 -->

- [Firestore basics](#firestore-basics)
- [Firestore Security Rules](#firestore-security-rules)
- [RBAC example scenario](#rbac-example-scenario)
- [Required security rules for RBAC](#required-security-rules-for-rbac)
  - [User collection](#user-collection)
  - [Roles collection](#roles-collection)
  - [Posts collection](#posts-collection)
  - [Comments collection](#comments-collection)
- [Implementing security rules for RBAC](#implementing-security-rules-for-rbac)
  - [RBAC helper functions](#rbac-helper-functions)
  - [Users collection](#users-collection)
  - [Roles collection](#roles-collection-1)
  - [Posts collection](#posts-collection-1)
  - [Comments collection](#comments-collection-1)
- [Summary](#summary)

<!-- /TOC -->

## Firestore basics

Firestore is database that is part of Googles Firebase suite for mobile app development. It is currently in _beta_ and has the potential to replace the current Firebase Realtime Database due to its superior API and features.
> [Cloud Firestore](https://firebase.google.com/docs/firestore/) is a flexible, scalable database for mobile, web, and server development from Firebase and Google Cloud Platform

For those that never used a Firebase database; it is a NoSQL document oriented database. Firestore allows you to nest documents by creating multiple collections inside a document.

<img src="{{ site.baseurl }}/img/assets/rbac-firestore/firestore-documents.png" width="640px" alt="Screenshot of a Firestore database with nested collections">

The Firebase suite is built for mobile development and provides SDKs for all major languages. JavaScript/Node.js, Swift, Objective C, Android, Java, Python, Ruby, Go. The SDKs allow add, query or delete data as well as other operations required when interacting with a database as a client. One feature I really like is the possiblity to register your client to receive [updates](https://firebase.google.com/docs/firestore/query-data/listen) automatically. This allows you to build **three way data binding** in realtime applications easily. This is a feature I used in my [first project with Firebase](https://github.com/anoff/microllaborators).

In combination with the Firebase [authentication provider](https://firebase.google.com/docs/auth/) you can limit access the database to people that are logged in. The auth provider also provides an SDK and requires only a few lines of code to implement in a web app.

![Firebase application design]({{ site.baseurl }}/img/assets/rbac-firestore/dist/arch.svg)

## Firestore Security Rules

The ability to create a detailed rule set make Firestore enable use cases for a serverless database without any backend code and still keeping data secure. It is also the foundation for building a role based access control.

> All roles and authorization rules will be enforced by the Firestore server

Security rules are written in a JavaScript-like syntax but have their own methods. First you nest `match` operators to specify the document level you want to be affected by this rule. Use `{wildcards}` that can later on be referenced in the rule definition. Granting/denying access is done via an `allow <method> if` statement that grants access if it returns `true` or otherwise blocks the transaction.

```javascript
service cloud.firestore {
  match /databases/{database}/documents {
    allow read, write: if <some_condition>;
    allow delete: if false;
  }
}
```

There are **five methods** that can be specified:

1. `get`: retrieve a single document
1. `list`: read an entire collection or perform queries
1. `create`: write to non existing documents
1. `update`: write to existing documents
1. `delete`: remove a document


The modifying operations 3-5 can be addressed using the `write` method instead of specifying them individually, `read` applies both _get_ and _list_. If multiple rules match for a request only one needs to resolve to `true` for the request to be successful.

```javascript
// allow anyone to read but only signed in users to create/update; only a specific user can delete
service cloud.firestore {
  match /databases/{database}/documents {
    match /posts/{document=**} {
      allow read: if true;
      allow create, update: if request.auth != null;
      allow delete: if request.auth.uid == 'an0xff';
    }
  }
}
```

## RBAC example scenario

We will setup RBAC for a simple content site with _posts_ that can be commented with the following roles:

- **admin**: can assign roles
- **writer**: can create new posts, can modify its own posts
- **editor**: can edit any post, delete comments
- **user**: can create and modify its own comments, can modify his user settings

On the root level of Firestore we add three different collections. One holds the content, one for user details and one that implements the roles per user. The reason to separate role assignments from the user document is to easily allow users to modify their own details without giving them the possibility to grant themselves new roles.

![Class diagram of the database structure]({{ site.baseurl }}/img/assets/rbac-firestore/dist/document-classes.svg)

## Required security rules for RBAC

Given the collection setup and the above role definition we can define the rules we need to implement for each collection.

### User collection

| method | permissions |
|--------|---------------|
| get    | anyone |
| list | noone |
| create | noone |
| update | user (own profile) |
| delete | user (own profile) |

### Roles collection

| method | permissions |
|--------|---------------|
| get    | user itself, admin |
| list | admin |
| create | noone |
| update | admin |
| delete | noone |

### Posts collection

| method | permissions |
|--------|---------------|
| get    | anyone |
| list | anyone |
| create | writer |
| update | editor, writer (their own) |
| delete | writer (their own) |

### Comments collection

| method | permissions |
|--------|---------------|
| get    | anyone |
| list | anyone |
| create | user |
| update | user (their own) |
| delete | user (own), editor |

## Implementing security rules for RBAC

We start with a default _DENY ALL_ policy setup for the collections in our project.

```javascript
service cloud.firestore {
  match /databases/{database}/documents {
    // this addresses any entry in the user collection
    match /users/{user} {
     	allow read, write: if false;
    }
    // rules for the roles setup
    match /roles/{user} {
      allow read, write: if false;
    }

    match /posts/{post} {
      allow read, write: if false;
    }

    match /posts/{post}/comments/{comment} {
      allow read, write: if false;
    }
  }
}
```

### RBAC helper functions

We start by implementing a few custom functions that help us define role based rules.

```javascript
service cloud.firestore {
  match /databases/{database}/documents {
    ...
    // the request object contains info about the authentication status of the requesting user
    // if the .auth property is not set, the user is not signed in
    function isSignedIn() {
      return request.auth != null;
    }
    // return the current users entry in the roles collection
    function getRoles() {
      return get(/databases/$(database)/documents/roles/$(request.auth.uid)).data
    }
    // check if the current user has a specific role
    function hasRole(role) {
      return isSignedIn() && getRoles()[role] == true;
    }
    // check if the user has any of the given roles (list)
    function hasAnyRole(roles) {
      return isSignedIn() && getRoles().keys().hasAny(roles);
    }
  }
}
```

With these functions in the security rules you can now easily implement security roles based on the users roles. 

### Users collection

First we make sure only the user itself can modify its data:

```javascript
match /users/{user} {
  // anyone can see a specific users profile data (name, email etc), in a real scenario you might want to make this more granular
  allow get: if true;
  // noone can query for users
  allow list, create: if false;
  // users can modify their own data
  allow update, delete: if request.auth.uid == user;
}
```

### Roles collection

Next we enforce the rules for the role collection

```javascript
match /roles/{user} {
  allow get: if request.auth.uid == user || hasRole('admin');
  allow list: if hasRole('admin');
  allow update: if hasRole('admin');
  allow create, delete: if false;
}
```

### Posts collection

This one is a little trickier because we first need to figure out who actually created the post if we want to enforce the _update_ rule.

```javascript
match /posts/{post} {
  allow get, list: if true;
  allow create: if hasRole('writer');
  // check if the post author is identical to requesting user
  allow update: if (hasRole('writer') && resource.data.author == request.auth.uid) || hasRole('editor');
  allow delete: if hasRole('writer');
}
```

### Comments collection

Make sure that users can modify or delete their comments and editors can moderate anyones comments.

```javascript
match /posts/{post}/comments/{comment} {
  allow get, list: if true;
  allow create: if hasRole('user');
  // check if the comment author is identical to requesting user
  allow update: if resource.data.author == request.auth.uid);
  allow delete: if hasRole('editor') || (hasRole('user') && resource.data.author == request.auth.uid);
}
```

## Summary

You created a Firestore ruleset that enforces **data privacy and integrity** by limiting access to resources based according to a role design. To see a similar design implemented you can check out my [techradar](https://github.com/anoff/techradar) project which also showcases how to implement RBAC on the frontend too. There are other interesting ways to secure Firestore data for example checking which parts of a resource are being changed in an update process to allow users to update only specific properties. Also check out my previous post on creating [PlantUML diagrams](https://anoff.io/blog/2018-07-31-diagrams-with-plantuml/).

Drop me a message on [Twitter](https://twitter.com/an0xff) if you have feedback about this post.
