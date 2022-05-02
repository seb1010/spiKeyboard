
spiOut:
  push r16
  push r17
  push r18
  push r26
  push r27
  ldi r26, low(usbIn)
  ldi r27, high(usbIn)
ldi r16, $0d
st -x, r16

  in r17, $1b

  spiOutByteLoop:
    cpi r26, $60
    brcc endSpiOut
    
    ld r16, x+
    ldi r18, $09
    spibitLoop:
      dec r18
      breq endSpiBitLoop

      cbr r17, $0c
      sbrc r16, 7
      sbr r17, $08
      out $1b, r17   ; data correct clock low
      rcall spiWaste200Cycles
      lsl r16
      sbr r17, $04
      out $1b, r17   ; clock high
      rcall spiWaste200Cycles
      
    rjmp spiBitLoop
    endSpiBitLoop:
      rcall spiWaste200Cycles
  rjmp spiOutByteLoop

  endSpiOut:
  pop r27
  pop r26
  pop r18
  pop r17
  pop r16
ret

spiWaste200Cycles:
  push r16
  ldi r16, $60
  spiWaste200CyclesLoop:
    inc r16
    brne spiWaste200CyclesLoop
  pop r16
ret

