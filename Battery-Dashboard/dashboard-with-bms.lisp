; define filter and filter constant for IR filter
(def filter-weight 0.99)
; define current threshold to add point to IR computation
(def current-threshold 0.1)
; define internal resistance near actual variable
(def ir 0.25)
; set update rate for computation and sending to VESC tool
(def update-rate-hz 10)

; get initial readings before entering loop
(def this-V (get-vin))
(def this-I (get-current-in))
(sleep (/ 1 update-rate-hz))

;create list of p-group indices
(def num-cells (get-bms-val 'bms-cell-num))
(def cell-indices (range 0 num-cells))

; define function to get p-group voltage for row x
(def get-bms-voltage (lambda (x) (get-bms-val 'bms-v-cell x)))

; continuously compute and send to vesc tool
(loopwhile t
    (progn
        ; rotate values
        (def prev-V this-V)
        (def prev-I this-I)
        ; grab new values
        (def this-V (get-vin))
        (def this-I (get-current-in))
        ; if current difference > threshold calculate, if not use previous ir
        (if (> (abs (- this-I prev-I)) current-threshold)
            ; use ohms law to estimate resistance
            (def this-ir (- (/ (- this-V prev-V) (- this-I prev-I))))
            (def this-ir ir))
        ; update filtered resistance value
        (def ir (+ (* filter-weight ir) (* (- 1 filter-weight) this-ir)))
        ; get high and low row voltages from BMS
        ; map bms cell voltage function over cells
        (def voltage-list (map get-bms-voltage cell-indices))
        ; initialize max and min voltages
        (def max-voltage 0)
        (def min-voltage 100000)
        ; loop through voltages and set extremes
        (loopforeach voltage voltage-list
            (progn
                (if (> voltage max-voltage) (def max-voltage voltage))
                (if (< voltage min-voltage) (def min-voltage voltage))
            )
        )
        ; compute the greatest voltage mismatch
        (def mismatch (- max-voltage min-voltage))

        ; send data values to VESC tool
        ; define array with space for 4 32-bit floats
        (def arr (array-create 16))
        ; stuff array with ir, mismatch, min voltage, and max cell temp
        (bufset-f32 arr 0 ir)
        (bufset-f32 arr 4 mismatch)
        (bufset-f32 arr 8 min-voltage)
        (bufset-f32 arr 12 (get-bms-val 'bms-temp-cell-max))
        ; send buffer to vesc tool
        (send-data arr)

        ; sleep according to update rate
        (sleep (/ 1.0 update-rate-hz))
    )
)
