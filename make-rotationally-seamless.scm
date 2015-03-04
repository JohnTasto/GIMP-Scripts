; make-rotationally-seamless.scm
; version 1.0
;
; This is Script-Fu program written for GIMP 2.8.
;
; Its purpose is to help create texture images that can not only be tiled
; through translation, but also when combined with flipping and rotation.
;
; It does not do all the work for you, all it does is take one half of one side
; and flip and rotate it around the other edges.  It leaves the original image
; as a layer underneath, and you should erase most of the inside of the
; generated layer to reveal the original image underneath.
;
; It works best on images that are mostly uniform and square, and although it
; will resize the image to make it square if necessary, it is not recommended.
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


(define (script-fu-make-rotationally-seamless image
                                              layerBase
                                              sideStart)
  (let* (
          (layerBasePosition (car (gimp-image-get-item-position image layerBase)))
          (width             (car (gimp-drawable-width layerBase)))
          (height            (car (gimp-drawable-height layerBase)))
          (layerComplete     (car (gimp-layer-new-from-drawable layerBase image)))
          (layerFloating     0)
          (size              0)
          (sel               0)
          (trans             0)
          (rotate            0)
          (flip              0)
          (temp              0)
        )

    ;sideStart: 
    ;0 Top left
    ;1 Top right
    ;2 Bottom left
    ;3 Bottom right
    ;4 Left top
    ;5 Left bottom
    ;6 Right top
    ;7 Right bottom

    (if (or (= sideStart 0) (= sideStart 1))
      (set! rotate 0)
    )
    (if (or (= sideStart 2) (= sideStart 3))
      (set! rotate 2)
    )
    (if (or (= sideStart 4) (= sideStart 5))
      (set! rotate 1)
    )
    (if (or (= sideStart 6) (= sideStart 7))
      (set! rotate 3)
    )
    (if (or (= sideStart 1) (= sideStart 2) (= sideStart 4) (= sideStart 7))
      (set! flip #t)
      (set! flip #f)
    )

    (gimp-context-push)
    (gimp-context-set-defaults)
    (gimp-image-undo-group-start image)

    (gimp-image-insert-layer image layerComplete 0 layerBasePosition)
    (gimp-layer-add-alpha layerComplete)

    ; Pre rotate and flip image
    (if (= rotate 1)
      (gimp-image-rotate image ROTATE-90)
    )
    (if (= rotate 2)
      (gimp-image-rotate image ROTATE-180)
    )
    (if (= rotate 3)
      (gimp-image-rotate image ROTATE-270)
    )
    (if flip
      (gimp-image-flip image ORIENTATION-HORIZONTAL)
    )

    ; Resize image to square
    (if (= width height)
      (set! size width)
      (begin
        (if (< width height)
          (begin
            (gimp-image-resize image         height height 0 0)
            (gimp-layer-resize layerBase     height height 0 0)
            (gimp-layer-resize layerComplete height height 0 0)
            (set! size height)
          )
          (begin
            (gimp-image-resize image         width width 0 0)
            (gimp-layer-resize layerBase     width width 0 0)
            (gimp-layer-resize layerComplete width width 0 0)
            (set! size width)
          )
        )
      )
    )

    (if (= 0 (modulo size 2))
      (begin ;even
        (set! sel   (+ 1 (/ size 2)))
        (set! trans      (/ size 2))
      )
      (begin ;odd
        (set! sel   (ceiling (/ size 2)))
        (set! trans (ceiling (/ size 2)))
      )
    )

    (gimp-context-set-antialias FALSE)
    (gimp-context-set-feather FALSE)

    ;top right
    (gimp-image-select-polygon image CHANNEL-OP-REPLACE 6 (vector 0 0 sel sel sel 0))
    (gimp-edit-copy layerBase)
    (set! layerFloating (car (gimp-edit-paste layerComplete FALSE)))
    (gimp-item-transform-flip-simple layerFloating ORIENTATION-HORIZONTAL TRUE 0)
    (gimp-layer-translate layerFloating trans 0)

    ;right top
    (gimp-image-select-polygon image CHANNEL-OP-REPLACE 6 (vector 0 0 sel sel sel 0))
    (gimp-edit-copy layerBase)
    (set! layerFloating (car (gimp-edit-paste layerComplete FALSE)))
    (gimp-item-transform-rotate-simple layerFloating ROTATE-90 TRUE 0 0)
    (gimp-layer-translate layerFloating trans 0)

    ;right bottom
    (gimp-image-select-polygon image CHANNEL-OP-REPLACE 6 (vector 0 0 sel sel sel 0))
    (gimp-edit-copy layerBase)
    (set! layerFloating (car (gimp-edit-paste layerComplete FALSE)))
    (gimp-item-transform-flip-simple layerFloating ORIENTATION-HORIZONTAL TRUE 0)
    (gimp-item-transform-rotate-simple layerFloating ROTATE-90 TRUE 0 0)
    (gimp-layer-translate layerFloating trans trans)

    ;bottom right
    (gimp-image-select-polygon image CHANNEL-OP-REPLACE 6 (vector 0 0 sel sel sel 0))
    (gimp-edit-copy layerBase)
    (set! layerFloating (car (gimp-edit-paste layerComplete FALSE)))
    (gimp-item-transform-rotate-simple layerFloating ROTATE-180 TRUE 0 0)
    (gimp-layer-translate layerFloating trans trans)

    ;bottom left
    (gimp-image-select-polygon image CHANNEL-OP-REPLACE 6 (vector 0 0 sel sel sel 0))
    (gimp-edit-copy layerBase)
    (set! layerFloating (car (gimp-edit-paste layerComplete FALSE)))
    (gimp-item-transform-flip-simple layerFloating ORIENTATION-HORIZONTAL TRUE 0)
    (gimp-item-transform-rotate-simple layerFloating ROTATE-180 TRUE 0 0)
    (gimp-layer-translate layerFloating 0 trans)

    ;left bottom
    (gimp-image-select-polygon image CHANNEL-OP-REPLACE 6 (vector 0 0 sel sel sel 0))
    (gimp-edit-copy layerBase)
    (set! layerFloating (car (gimp-edit-paste layerComplete FALSE)))
    (gimp-item-transform-rotate-simple layerFloating ROTATE-270 TRUE 0 0)
    (gimp-layer-translate layerFloating 0 trans)

    ;left top
    (gimp-image-select-polygon image CHANNEL-OP-REPLACE 6 (vector 0 0 sel sel sel 0))
    (gimp-edit-copy layerBase)
    (set! layerFloating (car (gimp-edit-paste layerComplete FALSE)))
    (gimp-item-transform-flip-simple layerFloating ORIENTATION-HORIZONTAL TRUE 0)
    (gimp-item-transform-rotate-simple layerFloating ROTATE-270 TRUE 0 0)

    (gimp-floating-sel-anchor layerFloating)

    ; Rotate and flip image back
    (if flip
      (gimp-image-flip image ORIENTATION-HORIZONTAL)
    )
    (if (= rotate 1)
      (gimp-image-rotate image ROTATE-270)
    )
    (if (= rotate 2)
      (gimp-image-rotate image ROTATE-180)
    )
    (if (= rotate 3)
      (gimp-image-rotate image ROTATE-90)
    )

    (gimp-image-undo-group-end image)
    (gimp-displays-flush)
    (gimp-context-pop)
  )
)

(script-fu-register "script-fu-make-rotationally-seamless"
  _"_Make rotationally seamless..."
  _"Copy, rotate, and flip half of one edge of the image around its border (must be square!)"
  "John Tasto <john@tasto.net>"
  "John Tasto"
  "2015/03/03"
  "RGB* GRAY* INDEXED*"
  SF-IMAGE    "Image"    0
  SF-DRAWABLE "Drawable" 0
  SF-OPTION   _"Side to duplicate" '("Top left" "Top right" "Bottom left" "Bottom right"
                                     "Left top" "Left bottom" "Right top" "Right bottom")
)

(script-fu-menu-register "script-fu-make-rotationally-seamless"
                         "<Image>/Filters/Texture")

