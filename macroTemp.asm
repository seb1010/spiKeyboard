.macro sendAck
  ldi r16, $D2
  sts pidOut, r16
  ldi r16, $10
  sts numBitsOutAS, r16
  rcall usbOut
.endmacro

.macro sendNak
  ldi r16, $5A
  sts pidOut, r16
  ldi r16, $10
  sts numBitsOutAS, r16
  rcall usbOut
.endmacro

.macro waitForNext

waitForNextPacket:
    lds r16, usbDataReceived
    cpi r16, $01
  brlo waitForNextPacket
  
  clr r16
  sts usbDataReceived, r16
.endmacro
