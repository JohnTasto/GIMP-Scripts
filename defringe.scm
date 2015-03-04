; defringe.scm
; version 1.0
;
; This is Script-Fu program written for GIMP 2.8.
;
; It is designed to fix some transparancy problems in alpha masked images.  In
; photos that are masked, transparent pixels retain color information, which
; can cause weird halo effects in certain situations.  This copies color
; information from non-transparent pixels and spreads their color to nearby
; transparent pixels, so the halo is at least the same color as the intended
; image.
;
; The settings are a bit cryptic, so here is a more detailed explaination of
; each:
;
; Width of fringe:
;   This is the width of the transparent fringe border around the opaque image
;   to recolor.
;
; Width of edge color to ignore:
;   This causes the fringe to use the color further inside the opaque image,
;   rather than the color right on its border.
;
; Width of edge border to replace:
;   This causes a border around the inside of the opaque image to be replaced
;   by an opaque version of the reconstructed fringe.
;
; Fringe blur amount:
;   This blurs the fringe to smooth out any irregularities.
;
; Remove fringe:
;   This automatically erases the reconstructed fringe, leaving the original
;   opaque image but with the colors in the transparent areas around the fringe
;   corrected.  If you want to see the actual fringe before it is made
;   transparent again, uncheck this setting.  The fringe can be manually made
;   transparent by erasing it after the script runs by simply pressing 'delete'.
;
; The three settings 'Width of edge color to ignore', 'Width of edge border to
; replace', and 'Fringe blur amount' can be used in combination to rebuild the
; border of the opaque image, which can in many cases help correct bad edge
; lighting.  Setting the first two to '1' or '2' and setting a small blur amount
; will clean up the outer one or two pixels of the edge, but leave the overall
; shape the same.  Don't be afraid to play around with these, it is easy to
; undo and try different settings.
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


; Eight direction defringe (doesn't look right.. unused)
(define (defringe8 image
                  layerWorking
                  layerWorkingPosition
                  offset)

  (let* (
          (layerNE  (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerE   (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerSE  (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerS   (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerSW  (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerW   (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerNW  (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerN   (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerOut 0)
        )

    (gimp-image-insert-layer image layerNE 0 (+ layerWorkingPosition 1))
    (gimp-image-insert-layer image layerE  0 (+ layerWorkingPosition 1))
    (gimp-image-insert-layer image layerSE 0 (+ layerWorkingPosition 1))
    (gimp-image-insert-layer image layerS  0 (+ layerWorkingPosition 1))
    (gimp-image-insert-layer image layerSW 0 (+ layerWorkingPosition 1))
    (gimp-image-insert-layer image layerW  0 (+ layerWorkingPosition 1))
    (gimp-image-insert-layer image layerNW 0 (+ layerWorkingPosition 1))
    (gimp-image-insert-layer image layerN  0 (+ layerWorkingPosition 1))

    (gimp-layer-translate layerNE    offset   (- offset) )
    (gimp-layer-translate layerE     offset      0       )
    (gimp-layer-translate layerSE    offset      offset  )
    (gimp-layer-translate layerS     0           offset  )
    (gimp-layer-translate layerSW (- offset)     offset  )
    (gimp-layer-translate layerW  (- offset)     0       )
    (gimp-layer-translate layerNW (- offset)  (- offset) )
    (gimp-layer-translate layerN     0        (- offset) )

    (set! layerNW (car (gimp-image-merge-down image layerN  CLIP-TO-IMAGE)))
    (set! layerW  (car (gimp-image-merge-down image layerNW CLIP-TO-IMAGE)))
    (set! layerSW (car (gimp-image-merge-down image layerW  CLIP-TO-IMAGE)))
    (set! layerS  (car (gimp-image-merge-down image layerSW CLIP-TO-IMAGE)))
    (set! layerSE (car (gimp-image-merge-down image layerS  CLIP-TO-IMAGE)))
    (set! layerE  (car (gimp-image-merge-down image layerSE CLIP-TO-IMAGE)))
    (set! layerNE (car (gimp-image-merge-down image layerE  CLIP-TO-IMAGE)))

    (if (= offset 1)
      (begin
        (set! layerOut (car (gimp-layer-new-from-drawable layerWorking image)))
        (gimp-image-insert-layer image layerOut 0 (+ layerWorkingPosition 1))
      )
      (set! layerOut (defringe image layerWorking layerWorkingPosition (- offset 1)))
    )
    (set! layerOut (car (gimp-image-merge-down image layerOut CLIP-TO-IMAGE)))

  )
)

; Four direction defringe
(define (defringe image
                  layerWorking
                  layerWorkingPosition
                  offset)

  (let* (
          (layerE   (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerS   (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerW   (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerN   (car (gimp-layer-new-from-drawable layerWorking image)))
          (layerOut 0)
        )

    (gimp-image-insert-layer image layerE 0 (+ layerWorkingPosition 1))
    (gimp-image-insert-layer image layerS 0 (+ layerWorkingPosition 1))
    (gimp-image-insert-layer image layerW 0 (+ layerWorkingPosition 1))
    (gimp-image-insert-layer image layerN 0 (+ layerWorkingPosition 1))

    (gimp-layer-translate layerE     offset      0       )
    (gimp-layer-translate layerS     0           offset  )
    (gimp-layer-translate layerW  (- offset)     0       )
    (gimp-layer-translate layerN     0        (- offset) )

    (set! layerW  (car (gimp-image-merge-down image layerN CLIP-TO-IMAGE)))
    (set! layerS  (car (gimp-image-merge-down image layerW CLIP-TO-IMAGE)))
    (set! layerE  (car (gimp-image-merge-down image layerS CLIP-TO-IMAGE)))

    (if (= offset 1)
      (begin
        (set! layerOut (car (gimp-layer-new-from-drawable layerWorking image)))
        (gimp-image-insert-layer image layerOut 0 (+ layerWorkingPosition 1))
      )
      (set! layerOut (defringe image layerWorking layerWorkingPosition (- offset 1)))
    )
    (set! layerOut (car (gimp-image-merge-down image layerOut CLIP-TO-IMAGE)))

  )
)

(define (script-fu-defringe image
                            layerBase
                            fringeWidth
                            ignoreWidth
                            replaceWidth
                            blurRadius
                            removeFringe)
  (let* (
          (layerBasePosition (car (gimp-image-get-item-position image layerBase)))
          (layerTemp         (car (gimp-layer-new-from-drawable layerBase image)))
          (layerBlurred      (car (gimp-layer-new-from-drawable layerBase image)))
          (layerFringe       0)
        )

    (set! fringeWidth  (round fringeWidth))
    (set! ignoreWidth  (round ignoreWidth))
    (set! replaceWidth (round replaceWidth))

    (gimp-context-push)
    (gimp-context-set-defaults)

    (gimp-image-set-active-layer image layerBase)

    (gimp-image-undo-group-start image)

    (gimp-image-insert-layer image layerTemp    0 (+ layerBasePosition 1))
    (gimp-image-insert-layer image layerBlurred 0 (+ layerBasePosition 2))

    (if (> ignoreWidth 0)
      (begin
        (gimp-image-select-item image CHANNEL-OP-REPLACE layerBlurred)
        (gimp-selection-invert image)
        (gimp-selection-grow image ignoreWidth)
        (gimp-edit-clear layerBlurred)
      )
    )

    (gimp-selection-none image)

    ; blur pre-fringe
    (if (>= blurRadius 0.1)
      (plug-in-gauss-rle RUN-NONINTERACTIVE image layerBlurred blurRadius TRUE TRUE)
    )

    ; create fringe
    (set! layerFringe (defringe image layerBlurred (+ layerBasePosition 2) (+ fringeWidth (ceiling blurRadius))))
    (set! layerFringe (car (gimp-image-merge-down image layerBlurred CLIP-TO-IMAGE)))
    ;(gimp-item-set-visible layerFringe FALSE)

    ; trim edge from original image
    (if (> replaceWidth 0)
      (begin
        (gimp-image-select-item image CHANNEL-OP-REPLACE layerBase)
        (gimp-selection-invert image)
        (gimp-selection-grow image replaceWidth)
        (gimp-edit-clear layerBase)
      )
    )

    ; get selection from temp layer, then remove that layer (this is all it is for)
    (gimp-image-select-item image CHANNEL-OP-REPLACE layerTemp)
    (gimp-image-remove-layer image layerTemp)

    (set! layerBase (car (gimp-image-merge-down image layerBase CLIP-TO-IMAGE)))
    (gimp-selection-invert image)
    (if (= removeFringe TRUE)
      (begin
        (gimp-edit-clear layerBase)
        (gimp-selection-none image)
      )
    )

    (gimp-image-set-active-layer image layerBase)
    (gimp-image-undo-group-end image)
    (gimp-displays-flush)

    (gimp-context-pop)
  )
)

(script-fu-register "script-fu-defringe"
  _"_Defringe..."
  _"Expand edge of masked image under transparent areas"
  "John Tasto <john@tasto.net>"
  "John Tasto"
  "2015/02/10"
  "RGBA"
  SF-IMAGE      "Image"    0
  SF-DRAWABLE   "Drawable" 0
  SF-ADJUSTMENT _"Width of fringe"                 '(8  0 1024 1 8 0 1)
  SF-ADJUSTMENT _"Width of edge color to ignore"   '(1  0 1024 1 8 0 1)
  SF-ADJUSTMENT _"Width of edge border to replace" '(2  0 1024 1 8 0 1)
  SF-ADJUSTMENT _"Fringe blur amount"              '(2  0   16 1 2 0 1)
  SF-TOGGLE     _"Remove fringe"                   TRUE
)

(script-fu-menu-register "script-fu-defringe"
                         "<Image>/Filters/Texture")
