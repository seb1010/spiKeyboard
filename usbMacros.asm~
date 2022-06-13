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
  push r17
  ldi r16, $D2
  sts pidOut, r16
  ldi r16, $10
  sts numBitsOutAS, r16
  rcall usbOut
  pop r17
.endmacro

.macro sendNak
push r19
push r20
  ldi r16, high(nakOutNumBits)
  sts yPointOut, r16
  ldi r16, low(nakOutNumBits)
  sts (yPointOut + 1), r16

  rcall usbOut

  ldi r16, high(numBitsOutAS)
  sts yPointOut, r16
  ldi r16, low(numBitsOutAS)
  sts (yPointOut + 1), r16
pop r20
pop r19
.endmacro

.macro waitForNext
    ldi r16, $01
    sts packetReady, r16
    clr r16
    sts usbDataReceived, r16
waitForNextPacket:
    lds r16, usbDataReceived
    cpi r16, $01
  brlo waitForNextPacket
  
  clr r16
  sts packetReady, r16
.endmacro



