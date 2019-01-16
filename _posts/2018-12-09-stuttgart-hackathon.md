---
layout: post
title: Get the most out of hackathons
subtitle: a (late) summary of the Stuttgart Hackathon 2018
tags: [development]
---

> TL;DR; **Network** and play with expensive toys

# Intro

End of October I joined the [Stuttgart Hackathon](https://www.hackathon-stuttgart.de/) for the second time. It was my overall 4th public Hackathon. In this blog post I want to tell you why I enjoy doing Hackathons and why you should join one too if you have the chance!

![Stuttgart Hackathon 2018]({{ site.baseurl }}/img/assets/hackathons/stuttgart2018.jpg)

# How I used to approach Hackathons

The first Hackathon I ever participated in was hosted by Zeiss April 2017. Together with a [Tim Großmann](https://github.com/timgrossmann) I formed a team to compete in Munich for ideas and projects around Digitalization. We did not join to win but mostly to have fun and write a bit of code - so on our way to Munich we were discussing what would be fun to do. Not knowing the exact scope of the Hackathon we thought doing something with augmented reality on web apps would be fun. We also did not manage to get our hands any of the gadgets we wanted to include in our solution therefore we had to go with a pure code solution.

So we built [microllaborators](https://github.com/anoff/microllaborators) - an awful play of words with microscope and collaborators. We discussed the idea with the coaches and also came up with a pretty solid pitch with a working live demo including the audience. I still like the solution we built but sadly we only made 5th place 😢

Last years Stuttgart Hackathon started off completely different. I did not join with a team but participated in the on site team building event to find new people to code with. Having found a group of four something simliar to the Zeisshack happened; 

> we did not get the gadgets we needed to implement the idea we came up with

![Gadgets]({{ site.baseurl }}/img/assets/hackathons/Tokyo_Akihabara_gadgets.jpg)

So we fiddled around for 3 hours with the stuff we got + what we brought from our personal stashes and then decided we would not try to compete at all. Instead we spent another 10 hours teaching each other about languages, tools and programs that each of us used and left the Hackathon after 2/3.

# What changed

In the past I mostly joined Hackathons to gather experience with new languages, frameworks or gadgets like Alexa, Hue etc. 

By now I go there for two main reasons:

1. networking
2. play with things I would never get my hands on otherwise

As I also do a lot of side projects at home I want Hackathons to give me something that my personal projects do not. Therefore I do not want to build a fancy blockchain based, AWS hosted IoT solution. I can do that at home for very little money 💸.
What I can not do at home is meet awesome people that hang out at such events or get my hands on some prototypes or industrial equipment worth several thousand Euros 💰.

# Stuttgart Hackathon 2018

At this years Stuttgart Hackathon my team did exactly this. We all joined with the clear intention to _not compete to win_. If we end up with a solution that would be pitch worthy we agreed we should pitch it. But we did not make it our primary goal. We wanted to have fun - and we got our hands on one of these badasses: The Festo [Bionic Cobot](https://www.festo.com/group/en/cms/12746.htm) a humanoid robot arm powered by air pressure instead of electrical motors.

![Festo Bionic Cobot, copyright by Festo]({{ site.baseurl }}/img/assets/hackathons/bioniccobot.jpg)

After a few hours of fun with the robot we eventually thought about an actual project that would give the robot a purpose. Thus [R.I.C the robot interaction companion](https://github.com/anoff/ric/) was born. Using this prototype robot was really different from any side project I have done so far because it meant not only using a single gadget but understanding the complex system. The following diagram shows the system setup where the gray `Client Code` is the part that we coded ourself to control the robot. The great thing was that several experts were on site to help us with understanding and customizing the individual components of the Cobot.

![Cobot system](https://camo.githubusercontent.com/d894c6fa7acc16193425edf1b75cf1bc400fa265/687474703a2f2f7777772e706c616e74756d6c2e636f6d2f706c616e74756d6c2f70726f78793f63616368653d6e6f267372633d68747470733a2f2f7261772e6769746875622e636f6d2f616e6f66662f7269632f6d61737465722f6173736574732f73797374656d2e69756d6c)

We even managed to integrate a bunch of gadgets like LiDAR scanners and Echo dots with Alexa integration. We came up with a funny story to pitch and our presenter did an awesome job at the final presentations.

# My future Hackathon strategy

In the future I will keep attending hackathons with the goal of getting my hands on non consumer grade hardware and **networking**. If you are a student you might be tempted by the prizes available at Hackathons but I seriously encourage you to use the time to meet new people and exchange ideas and experiences with others - this is the most valuable thing you can get out of such events.

## Image sources

- Stuttgart Hackathon - my own
- Gadgets - [Wikipedia](https://de.wikipedia.org/wiki/Datei:Tokyo_Akihabara_gadgets.jpg)
- Cobot - [Festo](https://www.festo.com/group/en/repo/assets/00393-bioniccobot-1532x900px.jpg) found on their [website](https://www.festo.com/group/en/cms/12746.htm)