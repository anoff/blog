---
title: Davinci Resolve Workflows
date: 2026-02-07
tags: [video, data management]
author: anoff
resizeImages: true
draft: true
---

# 

# Archive Project

This method backs up the project and all USED files in ORIGINAL size.

## Remove unused clips

- go to edit mode
- select media pool master bucket
- top three dot menu -> `Remove Unused Clips`
  - make sure to select `Load All Timelines`

## Proceed to Archive

Create project archive (.dra) including all used media files.

- open project manager
- right click the project -> `Export Project Archive`
- uncheck Render Cache and Proxy Media
- make sure to check `Media Files`

## Color Grading

The Golden Rule: You must transform your footage into the "Language" the LUT speaks (usually Rec.709) before the LUT touches it.

Step 1: Create 3 Serial Nodes
Press Alt+S (Windows) or Option+S (Mac) to create nodes.

Node 1: Input Transform (The "Fixer")

Node 2: Primary Correction (Exposure/White Balance)

Node 3: The LUT

Step 2: Configure Node 1 (Color Space Transform)
This is the most critical step. This node converts your HDR phone footage into standard SDR footage that LUTs can understand.

Open the Effects Library (top right) and search for Color Space Transform (CST). Drag it onto Node 1.

In the CST settings, set the Input parameters based on your phone:

For iPhone 12 (Dolby Vision/HLG):

Input Color Space: Rec.2020

Input Gamma: Rec.2100 HLG

For Pixel 10 (10-bit HDR):

Note: Pixel phones usually shoot HLG, but check your file metadata if this looks wrong.

Input Color Space: Rec.2020

Input Gamma: Rec.2100 HLG (Try ST.2084 / PQ if HLG looks too dark/contrasty).

Set the Output parameters (Targeting your LUT):

Output Color Space: Rec.709

Output Gamma: Gamma 2.4 (This is standard for most creative LUTs).

CRITICAL: Tone Mapping

Scroll down to Tone Mapping in the CST plugin.

Set Tone Mapping Method to DaVinci or Luminance Mapping.

This "squashes" the bright HDR highlights down into standard range so they don't clip. You may need to adjust the "Max Input Nits" slider (try 1000 or 2000) to recover detail in the sky/highlights.

Step 3: Apply the LUT on Node 3
Now that Node 1 has "cleaned" the signal into standard Rec.709:

Right-click Node 3.

Go to LUTs and select your desired creative LUT.

Because the input is now correct (Rec.709), the LUT will look as intended—balanced and cinematic, not broken.


Phone,Input Space,Input Gamma,Output to LUT
iPhone 12,Rec.2020,Rec.2100 HLG/ST.2084 (PQ),Rec.709 / Gamma 2.4
Pixel 10,Rec.2020,Rec.2100 HLG*,Rec.709 / Gamma 2.4
Osmo,DJI D-Gamut,DJI D-Log,Rec.709,Gamma 2.4


### Group CST

Method 2: Using Groups (Best for Mixed Cameras)
This is the professional workflow. It separates your camera "fix" (CST) from your creative grading, allowing you to tweak the LUT for all iPhone clips at once without affecting the Pixel clips.

Step 1: Create Groups
Select all your iPhone 12 clips.

Right-click one of them > Add into a New Group > Name it "iPhone".

Select all your Pixel 10 clips.

Right-click > Add into a New Group > Name it "Pixel".

Step 2: Apply the Transform (Group Pre-Clip)
Resolve has a hidden "layer" of nodes that applies to the whole group.

Click the distinct drop-down menu above the Node Graph (it usually says Clip).

Change it to Group Pre-Clip.

Create your CST Node here.

Why? Now every single clip in the "iPhone" group automatically gets the correct HDR-to-SDR conversion. You don't have to copy-paste anything.

Do this for the "Pixel" group as well with its specific CST settings.

Step 3: Creative Grading (Group Post-Clip)
Change the drop-down menu to Group Post-Clip.

Add your LUT Node here.

Why? If you decide later that the LUT is too strong, you just adjust it here once, and it updates for every clip in that group instantly.

Step 4: Individual Tweaks (Clip)
Change the drop-down menu back to Clip.

Do your exposure/white balance adjustments here.

Why? This level is unique to each specific video file. Use this to fix a shot that is slightly darker or brighter than the rest.

Summary of Group Hierarchy
Group Pre-Clip: The Fix (CST Node) -> Applies to all iPhone clips.

Clip: The Balance (Exposure/White Balance) -> Applies to just this one specific video.

Group Post-Clip: The Look (The LUT) -> Applies to all iPhone clips.