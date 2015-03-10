# GIMP-Scripts

A collection of several scripts for GIMP.

- *defringe.scm:* fixes fringe discoloration on masked images
- *make-rotationally-seamless.scm:* used to help make textures seamless on rotation and flip
- *make-seamless-by-mirroring.scm:* makes textures seamless by mirroring them
- *tile-random-rotation.scm:* preview tileable textures

## defringe.scm
version 1.01

This is Script-Fu program written for GIMP 2.8.

It is designed to fix some transparancy problems in alpha masked images.  In photos that are masked, transparent pixels retain color information, which can cause weird halo effects in certain situations.  This copies color information from non-transparent pixels and spreads their color to nearby transparent pixels, so the halo is at least the same color as the intended image.

The settings are a bit cryptic, so here is a more detailed explaination of each:

- *Width of fringe:* This is the width of the transparent fringe border around the opaque image
  to recolor.
- *Width of edge color to ignore:* This causes the fringe to use the color further inside the opaque image,rather than the color right on its border.
- *Width of edge border to replace:* This causes a border around the inside of the opaque image to be replaced by an opaque version of the reconstructed fringe.
- *Fringe blur amount:* This blurs the fringe to smooth out any irregularities.
- *Remove fringe:* This automatically erases the reconstructed fringe, leaving the original opaque image but with the colors in the transparent areas around the fringe corrected.  If you want to see the actual fringe before it is made transparent again, uncheck this setting.  The fringe can be manually made transparent by erasing it after the script runs by simply pressing *delete*.

The three settings *Width of edge color to ignore*, *Width of edge border to replace*, and *Fringe blur amount* can be used in combination to rebuild the border of the opaque image, which can in many cases help correct bad edge lighting.  Setting the first two to *1* or *2* and setting a small blur amount will clean up the outer one or two pixels of the edge, but leave the overall shape the same.  Play around with these settings to get good results.

## make-rotationally-seamless.scm
version 1.1

This is Script-Fu program written for GIMP 2.8.

Its purpose is to help create texture images that can not only be tiled through translation, but also when combined with flipping and rotation.  It works by taking one half of one side and flipping and rotating it around the other edges.  It leaves the original image as a layer underneath so you can fine tune the blending.

- *Blend width (0 for full):* Sets the blend width around the edge of the image.  If this is *0*, it does not attempt to blend, instead it leaves the newly created layer for you to mask the middle and reveal the original image.

- *Preview X tiles:* *Preview Y tiles:* If either (or both) of these are greater than *1*, it will create a preview tiled image where the tiles are rotated and flipped randomly.  It will also create an additional undo point to easily go back to the untiled version without re-running the script.

It works best on images that are mostly uniform and square, and although it will resize the image to make it square if necessary, it is not recommended.  This also leaves pretty obvious mirroring when tiled, so unless you blend it manually, the results are usually less than spectacular.

## make-seamless-by-mirroring.scm
version 1.0

This is Script-Fu program written for GIMP 2.8.

It creates a tileable image in perhaps the simplest way possible: by mirroring the image in both the x and y direction, leaving an image that is twice the original width and height.

- *Preview X tiles:* *Preview Y tiles: If either (or both) of these are greater than *1*, it will create a preview tiled image.  It will also create an additional undo point to easily go back to the untiled version without re-running the script.

## tile-random-rotation.scm
version 1.0

This is Script-Fu program written for GIMP 2.8.

It tiles the image with optional random rotations and flipping, useful for previewing seams in a tileable texture.

- *X Tiles:* *Y Tiles:* The number of tiles in the x and y direction.
- *Rotate randomly:* If selected, each tile will be randomly rotated.
- *Flip randomly:* If selected, each tile will be randomly flipped.

## License

Copyright 2015 John Tasto

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
