; tile-random-rotation.scm
; version 1.0
;
; This is Script-Fu program written for GIMP 2.8.
;
; It tiles the image with optional random rotations and flipping, useful for
; previewing seams in a tileable texture.
;
; X Tiles:
; Y Tiles:
;   The number of tiles in the x and y direction.
;
; Rotate randomly:
;   If selected, each tile will be randomly rotated.
;
; Flip randomly:
;   If selected, each tile will be randomly flipped.
;
;
; Copyright 2015 John Tasto
; 
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;     http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.


(define (script-fu-tile-random-rotation image
                                        layerBase
                                        tilesX
                                        tilesY
                                        rotate
                                        flip)
  (let* (
          (layerBasePosition (car (gimp-image-get-item-position image layerBase)))
          (width             (car (gimp-drawable-width layerBase)))
          (height            (car (gimp-drawable-height layerBase)))
          (layerTile         (car (gimp-layer-new-from-drawable layerBase image)))
          (layerFloating     0)
          (midWidth          0)
          (midHeight         0)
          (x                 0)
          (y                 0)
        )

    (set! tilesX (round tilesX))
    (set! tilesY (round tilesY))

    (set! midWidth  (round (* (/ width  2) (- tilesX 1))))
    (set! midHeight (round (* (/ height 2) (- tilesY 1))))

    (gimp-context-push)
    (gimp-context-set-defaults)
    (gimp-image-undo-group-start image)
    (srand  (car (gettimeofday)))

    (gimp-image-insert-layer image layerTile 0 layerBasePosition)

    (gimp-image-resize image     (* width tilesX) (* height tilesY) 0 0)
    (gimp-layer-resize layerBase (* width tilesX) (* height tilesY) 0 0)

    (gimp-context-set-antialias FALSE)
    (gimp-context-set-feather FALSE)

    (while (< x tilesX)
      (while (< y tilesY)
        (gimp-selection-none image)
        (gimp-edit-copy layerTile)
        (set! layerFloating (car (gimp-edit-paste layerBase FALSE)))
        (if (= flip TRUE)
          (begin
            (if (= 0 (random 2))
              (gimp-item-transform-flip-simple layerFloating ORIENTATION-HORIZONTAL TRUE 0)
            )
            (if (= 0 (random 2))
              (gimp-item-transform-flip-simple layerFloating ORIENTATION-VERTICAL   TRUE 0)
            )
          )
        )
        (if (and (= rotate TRUE) (not (= 0 (random 4))))
          (gimp-item-transform-rotate-simple layerFloating (random 3) TRUE 0 0)
        )
        ; need offsets because layers are pasted in the middle of the image
        (gimp-layer-translate layerFloating (- (* x width ) midWidth)
                                            (- (* y height) midHeight))
        (set! y (+ y 1))
      )
      (set! y 0)
      (set! x (+ x 1))
    )
    (gimp-floating-sel-anchor layerFloating)

    (gimp-selection-none image)
    (gimp-image-remove-layer image layerTile)

    (gimp-image-undo-group-end image)
    (gimp-displays-flush)
    (gimp-context-pop)
  )
)

(script-fu-register "script-fu-tile-random-rotation"
  _"_Tile with random rotation..."
  _"Tile an image with each tile randomly rotated"
  "John Tasto <john@tasto.net>"
  "John Tasto"
  "2015/08/03"
  "RGB* GRAY* INDEXED*"
  SF-IMAGE       "Image"           0
  SF-DRAWABLE    "Drawable"        0
  SF-ADJUSTMENT _"X Tiles"         '(4  1 256 1 1 0 SF-SPINNER)
  SF-ADJUSTMENT _"Y Tiles"         '(3  1 256 1 1 0 SF-SPINNER)
  SF-TOGGLE     _"Rotate randomly" TRUE
  SF-TOGGLE     _"Flip randomly"   TRUE
)

(script-fu-menu-register "script-fu-tile-random-rotation"
                         "<Image>/Filters/Texture")
