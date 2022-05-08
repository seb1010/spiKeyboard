
usbOut:
  ldi r28, low(clockSync)
  ldi r29, high(clockSync)
  lds r20, numBitsOutAS
  inc r20
  in r17, $1b   ; input port A
  cbr r17, (1 << 0)  ; D+ low
  sbr r17, (1 << 1 ) ; D- high
  out $1b, r17

  in r16, $1a  
  sbr r16, $03  ; D+ and D- to outputs
  out $1a, r16

  ldi r19, $03
  clr r1
  clr r2

  ld r16, y+
  rjmp nibbleOutLoop

  newByte:
  out $1b, r17
  ld r16, y+
  nibbleOutLoop:
    inc r1
    dec r20               ; bit 0 out
    breq endByteOutLoop
    sbrs r16, 0
      eor r17, r19
    out $1b, r17
    nop
    nop
    nop

    dec r20
    breq endByteOutLoop
     
    sbrs r16, 1           ; bit 1 out
      eor r17, r19
    out $1b, r17
    nop   
    nop
    nop

    dec r20
    breq endByteOutLoop

    sbrs r16, 2           ; bit 2 out
      eor r17, r19
    out $1b, r17
    
    sbrs r16, 3
      eor r17, r19
    dec r20               ; bit 3 out
    breq endByteOutLoopPlus          
    sbrs r1, 0            ; load new byte
      rjmp newByte
    swap r16
    out $1b, r17

  rjmp nibbleOutLoop
  endByteOutLoopPlus:
    nop
  endByteOutLoop:

     cbr r17, $03
     out $1b, r17

     ldi r16, $fc
     wasteLoop:
      inc r16
     brne wasteLoop
     
     in r16, $1a
     cbr r16, $03
     sbr r17, (1 << 1)
     out $1b, r17 ; D- high
     out $1a, r16 ; tristate outputs
ret
