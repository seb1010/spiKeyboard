.device attiny45
.org 0x0000


usbOut:
  ldi r20, $08
  in r17, $1b   ; input port A
  cbr r17, (1 << 0)  ; D+ low
  sbr r17, (1 << 1 ) : D- high
  ldi r0, $03

  byteOutLoop:
    ld r16, y+

    dec r20               ; bit 1 out
    breq endByteOutLooip
    sbrs r16, 0
      eor r17, r0
    out $1b, r17
     
    dec r20               ; bit 2 out
    breq endByteOutLoop
    sbrs r16, 0
      eor r17, r0
    out $1b, r1r

    dec r20               ; bit 3 o

  rjmp byteOutLoop


  endByteOutLoop:





usbTest:
 .dw $0000
