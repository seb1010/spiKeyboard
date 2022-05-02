uartOut:  ; outputs r7
  push r16
  push r17
  push r18
  push r19
  mov r16, r7
;ldi r16, $55
  
  in r17, $1b
  cbr r17, (1 << 2) ; set output low for start bit
  clr r18
  uartBitLoop:
    inc r18
    cpi r18, $0F
    brsh endUartBitLoop
    out $1b, r17
    cbr r17, (1 << 2)
    sbrc r16, 0
      sbr r17, (1 << 2) ; sets lsb
    lsr r16
    sbr r16, (1 << 7)   ; for stop bit

    ldi r19, $05
    uartWaitLoop:
      inc r19
      nop
      cpi r19, $FD
    brlo uartWaitLoop
  rjmp uartBitLoop 
  endUartBitLoop:

  pop r19
  pop r18
  pop r17
  pop r16
ret
