pleaseWait:
  push r16
  push r17
  push r18
  clr r16
  clr r17
  ldi r18, $c0

pleaseWaitLoop:
inc r16
brne pleaseWaitLoop
inc r17
brne pleaseWaitLoop
inc r18
brne pleaseWaitLoop

  pop r18
  pop r17
  pop r16
ret
