;
; Welcome to the usb setup file
;
; This file contains subroutines that handle enumeration and such
; This may have sub files as it is expected that this will be 50%
;    of the effort for this project (yikes)
;
;
;

usbSetupMain:
  push r16

  waitForNext ; waiting for setup packet

  waitForNext ; waiting for data packet

  sendAck

  rcall prepDeviceDescriptor

  lds r16, $012C  ; PID of dataIn

rjmp dedLoop

  cpi r16, $80
  brlo waitForIn 

waitForOut:
  lds r16, usbDataReceived   ; runs in circles waiting for input
  cpi r16, $01
  brlo waitForOut
  

waitForIn:

  pop r16
ret



prepDeviceDescriptor:
  push r16
  push r18  ; holds number of bytes to be sent total
  push r19  ; holds bytes in packet
  push r28
  push r29  ; points to sram
  push r30  ; points to pm
  push r31

  ldi r18, $12

  ldi r30, low(deviceDescriptor * 2)
  ldi r31, high(deviceDescriptor * 2)
  ldi r29, high(usbDataOutBS)
  ldi r28, low(usbDataOutBS)


  loadSramLoop:
    cpi r18, $01
    brlo endLoadSramLoop
    clr r19
    loadPacketLoop:
      cpi r19, $08
      brsh endLoadPacket   ; case where we run out of packet
      cpi r18, $01
      brlo endLoadPacket   ; case where we run out of data
      dec r18
      inc r19
      lpm r16, z+
      st y+, r16
  mov r7, r19
;  rcall uartOut    
;  rcall pleaseWait
    rjmp loadPacketLoop
  endLoadPacket:
  mov r16, r18
  lsl r16
  lsl r16
  lsl r16  ; multiply by 8
  sts numBitsOutBS, r16
  rcall prepDataOutMain
  ; wait for data
;  sbi $19, 7
  waitForNext
  lds r16, pidIn
  cpi r16, $69
  breq askingForData
  rjmp dedLoop
  askingForData:
  rcall usbOut
  
  waitForNext
  cli
  rcall usbDataOutOnUart
  rjmp dedLoop
  

  rjmp loadSramLoop
  endLoadSramLoop:

  pop r31
  pop r30
  pop r29
  pop r28
  pop r19
  pop r18
  pop r16

ret
