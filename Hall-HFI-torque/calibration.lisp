; See
; https://www.youtube.com/watch?v=H0oRhapKZnM

(import "pkg@://vesc_packages/lib_nau7802/nau7802.vescpkg" 'nau7802)
(eval-program (read-program nau7802))
(nau-init)

; Run this function without any weight to calibrate the zero offset
(defun zero-offset ()
    (progn
        (def adc-ofs 0.0)
        (looprange i 0 100
            (progn
                (def adc-ofs (+ adc-ofs (nau-read-adc)))
                (sleep 0.01)
        ))
        (def adc-ofs (/ adc-ofs 100.0))
))

(defun read-avg (samples)
    (progn
        (let ((avg 0))
            (progn
                (looprange it 0 samples
                    (progn
                        (setvar 'avg (+ avg (- (nau-read-adc) adc-ofs)))
                        (sleep 0.01)
                ))
            (/ avg samples)
))))

; Used to calibrate scale. Put a known weight on the scale
; and use this function with the weight as an argument.
; zero-offset has to be run first.
(defun cal-with-weight (weight)
    (setvar 'scale (/ weight (read-avg 100)))
)

(defun read-grams ()
    (* (- (nau-read-adc) adc-ofs) scale)
)

(defun lpf (val sample)
    (- val (* 0.5 (- val sample)))
)

;(def scale 21572.6) ; Factor to convert voltage to grams
(def scale 7557)    ; factor using roll of quarters calibration
(def grams 0)       ; Weight in grams
(def gramsf 0)      ; Filtered weight

(zero-offset)

(defun calc-torque ()
    (* 1.5 (conf-get 'si-motor-poles) 0.5
    (get-current) (conf-get 'foc-motor-flux-linkage) 0.001)
)

(spawn (fn () (loopwhile t
            (progn
                (def adc (nau-read-adc))
                (def grams (read-grams))
                (def gramsf (lpf gramsf grams))
                (def torque (* (* gramsf -0.01) 0.0424))
                (def torque-calc (calc-torque))
                (sleep 0.01)
))))
