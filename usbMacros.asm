;
; welcome to the macros file
;
; contains random macros
; ya its not ideal organization
; but here it its
;
;
;
;
;
; ################### Macros start Here ###################

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
    ldi r16, $01
    sts packetReady, r16
    lds r16, usbDataReceived
    cpi r16, $01
  brlo waitForNextPacket
  
  clr r16
  sts usbDataReceived, r16
.endmacro
