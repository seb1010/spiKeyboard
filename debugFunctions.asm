;  Welcome to the debug functions file
; 
;  This file exists to support debugging 
;  
;  Sorry about the mess
;
;  Thanks
;
; ################### CODE STARTS HERE  ###################

.include "uart9600.asm"

usbDataOutOnUart:
  push r7
  push r16
  push r28
  push r29
    ldi r28, low(pidIn + $10)
    ldi r29, high(pidIn + $10)
  clr r16
  uartByteLoop:
  cpi r16, $10
  inc r16
  brsh endUartByteLoop
    ld r7, -y
;mov r7, r28
    rcall uartOut
  rjmp uartByteLoop
  endUartByteLoop:
    
  pop r29
  pop r28
  pop r16
  pop r7
ret

OutOnUart:
  push r7
  push r16
  push r28
  push r29
    ldi r28, low($0152 + $10)
    ldi r29, high($0152 + $10)
  clr r16
  uartByteLoop1:
  cpi r16, $10
  inc r16
  brsh endUartByteLoop1
    ld r7, -y
;mov r7, r28
    rcall uartOut
  rjmp uartByteLoop1
  endUartByteLoop1:
    
  pop r29
  pop r28
  pop r16
  pop r7
ret

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
