
    ldi r30, low(charLookUp)
    ldi r31, high(charLookUp)
    lsl r30
    rol r31      ; multiply by 2
 
    lpm r16, z
    st y+, r16
