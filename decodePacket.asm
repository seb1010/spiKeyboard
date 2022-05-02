;  sbi $19, 7

in r17, $3b
cbr r17, (1 << 4)
out $3b, r17         ; disable pin change interrupts
sbr r17, (1 << 4)

sei  ; enable pin change interrupts
lds r16, usbIn  ; load PID

rjmp endPacketDecode
cpi r16, $2D
breq setupPacket
cpi r16, $E1
breq outPacket
cpi r16, $69
breq inPacket
cpi r16, $C3
breq dataPacket
cpi r16, $4B
breq dataPacket
cpi r16, $D2
breq ackPacket
cpi r16, $5A
breq nakPacket

setupPacket:
ldi r16, (1 << 0)
sts BmPrevious, r16

outPacket:
ldi r16, (1 << 1)
sts BmPrevious, r16

inPacket:
  lds r16, packetReady
  cpi r16, $00
  brne sendPacketOut
    ldi r16, $5a
    rcall sendAByte      ;  send nak
    rjmp endPacketDecode
  sendPacketOut:
;  rcall usbOut
   rjmp endPacketDecode 

dataPacket:
    ldi r16, $D2
    rcall sendAByte      ;  send nak

ackPacket:

nakPacket:

  endPacketDecode:
;lds r7, (usbIn + 0)
;rcall uartOut

contOn:
sts $015E, r29
sts $015F, r28


  ldi r16, $10
  out $3a, r16     ; clears interrupt flag

  out $3b, r17     ; enable pin change interrupts

  pop r29
  pop r28
;  pop r20
  pop r18
  pop r17
  pop r16
  out $3f, r16
  pop r16
reti

sendAByte:
  push r16
  push r17  
  push r18
  push r19
  push r20
;ldi r16, $5A

  in r17, $1b
  cbr r17, (1 << 0) ; D+ goes low
  sbr r17, (1 << 1) ; D- goes high

  in r18, $1a
  sbr r18, $03
  out $1a, r18 ; set pins to outputs

  ldi r19, $03 ; for exor reasons
  ldi r20, $80 ; clocksync pulse
  clr r18
  nakOutLoop0:
    sbrs r20, 0
      eor r17, r19
    out $1b, r17
    lsr r20    
    inc r18
    cpi r18, $08
    brlo nakOutLoop0

  nakOutLoop1:
    sbrs r16, 0
      eor r17, r19
    out $1b, r17
    lsr r16    
    inc r18
    cpi r18, $10
    brlo nakOutLoop1

  nop
  nop
  cbr r17, $03
  out $1b, r17
  ldi r18, $05
    se0Loop:
      dec r18
    brne se0Loop
  sbr r17, (1 << 1)
  out $1b, r17 ; driven back to idle state

  in r18, $1a
  cbr r18, $03
  out $1a, r18 ; set pins to inputs

  pop r20
  pop r19
  pop r18
  pop r17
  pop r16
ret


