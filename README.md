# GIMP-Scripts

A collection of several scripts for GIMP.

- *defringe.scm:* fixes fringe discoloration on masked images
- *make-rotationally-seamless.scm:* used to help make textures seamless on rotation and flip

## defringe.scm
version 1.0

This is Script-Fu program written for GIMP 2.8.

It is designed to fix some transparancy problems in alpha masked images.  In photos that are masked, transparent pixels retain color information, which can cause weird halo effects in certain situations.  This copies color information from non-transparent pixels and spreads their color to nearby transparent pixels, so the halo is at least the same color as the intended image.

The settings are a bit cryptic, so here is a more detailed explaination of each:

- *Width of fringe:* This is the width of the transparent fringe border around the opaque image
  to recolor.
- *Width of edge color to ignore:* This causes the fringe to use the color further inside the opaque image,rather than the color right on its border.
- *Width of edge border to replace:* This causes a border around the inside of the opaque image to be replaced by an opaque version of the reconstructed fringe.
- *Fringe blur amount:* This blurs the fringe to smooth out any irregularities.
- *Remove fringe:* This automatically erases the reconstructed fringe, leaving the original opaque image but with the colors in the transparent areas around the fringe corrected.  If you want to see the actual fringe before it is made transparent again, uncheck this setting.  The fringe can be manually made transparent by erasing it after the script runs by simply pressing 'delete'.

The three settings *Width of edge color to ignore*, *Width of edge border to replace*, and *Fringe blur amount* can be used in combination to rebuild the border of the opaque image, which can in many cases help correct bad edge lighting.  Setting the first two to *1* or *2* and setting a small blur amount will clean up the outer one or two pixels of the edge, but leave the overall shape the same.  Don't be afraid to play around with these, it is easy to undo and try different settings.

## make-rotationally-seamless.scm
version 1.0

This is a Script-Fu program written for GIMP 2.8.

Its purpose is to help create texture images that can not only be tiled through translation, but also when combined with flipping and rotation.

It does not do all the work for you, all it does is take one half of one side and flip and rotate it around the other edges.  It leaves the original image as a layer underneath, and you should erase most of the inside of the generated layer to reveal the original image underneath.

It works best on images that are mostly uniform and square, and although it will resize the image to make it square if necessary, it is not recommended.

## License

Copyright 2015 John Tasto

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.