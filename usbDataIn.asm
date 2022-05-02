.device attiny45 ; well 44 but close enough
.org 0x0000

; pb0 and pb1 are for crystal
; pa0 is d+
; pa1 is d-
; pa2 is sclk, also uart
; pa3 is mosi
; pb0 is input

.define stackStart $007F
.define usbIn $0080
.include "definitions.asm"

rjmp reset  ; $00
reti        ; $01
rjmp pcint0 ; $02
reti        ; $03
reti        ; $04
reti        ; $05
reti        ; $06
reti        ; $07
reti        ; $08
rjmp timer0CompA        ; $09
reti        ; $0a
reti        ; $0b
reti        ; $0c
reti        ; $0d
reti        ; $0e
reti        ; $0f
reti        ; $10
 

reset:
  ldi r16, low(stackStart)   ; sets stack pointer to ok place
  out $3d, r16
  ldi r16, high(stackStart)
  out $3e, r16
  
  in r16, $35
  sbr r16, (1 << 6)
  out $35, r16           ; disable pullups

  ldi r16, $01  ; enable interrupts
  out $12, r16  
  ldi r16, $10
  out $3b, r16

;  ldi r16, $0c
;  out $1a, r16

  sbi $1a, 2
  sbi $1b, 2
  sbi $1a, 3
  sbi $1a, 7
  clr r20
;newDed:
;  sbi $19, 7
;rjmp newDed

;  ldi r16, (1 << 5)  ;  enable sleep
;  out $35, r16 

  ldi r28, low(usbIn)
  ldi r29, high(usbIn)
  sts $015E, r29
  sts $015F, r28

;ldi r19, $08

  sei ; enable interrupts
;  sbi $1a, 7

;ldi r16, $69
;sts (usbIn + 1), r16
;clr r21
;  resetLoop:
;    lds r7, (usbIn + 3)
;mov r7, r20
;    rcall spiByteOut
;    rcall spiWaste200Cycles
;    rcall spiWaste200Cycles
;    rcall spiWaste200Cycles
;    rcall spiWaste200Cycles
;    clr r20

;    lds r29, $015E
;    lds r28, $015F

;cpi r21, $08
;brsh doneHere
   
;rjmp resetLoop
;    cpi r20, $44
;    brlo resetLoop
;doneHere:
;cli
;mov r7, r21
;    rcall spiByteOut
;	rcall plzWait
;sbi $19, 7
;rcall spiOut

;ldi r16, $69
;mov r7, r16


;dedLoop:
;  cpi r21, $01
;  breq itsATrap

;rjmp dedLoop

itsATrap:
cli
rcall plzWait
ldi r16, $69
sts usbIn, r16
lds r7, usbIn
rcall uartOut
;rcall usbDataOutOnUart
itsATrapLoop:
;rcall plzWait
;rcall plzWait
;sbi $19, 7
;rcall sendAByte
nop
nop
nop
nop
rjmp itsATrapLoop

.include "uart9600.asm"

pcint0:
  push r16
;sbi $19, 7
  ldi r16, $00
  out $32, r16  ; clear timer
  ldi r16, $23
  out $36, r16  ; compare match a
  ldi r16, $01
  out $33, r16  ; starts timer
  ldi r16, (1 << 1)
  out $39, r16  ; enables interrupts for compare match a   
  
  pop r16
reti

timer0CompA:
  push r16
  in r16, $3f ; stores sreg
  push r16
  push r17
  push r18

  in r17, $19    ; just get ready for bit 0
  cbr r17, $fc

    ldi r16, $00
    out $33, r16 ; stop timer

    push r28
    push r29     ; just using time wisely

  in r16, $19  ; grab bit 0 of byte 0
  cbr r16, $fc
  clr r18
  eor r17, r16
  sbrs r17, 0
  sbr r18, (1 << 0)

    ldi r29, high(usbIn)    ; just using time wisely
    ldi r28, low(usbIn)     ; set correct y pointer

  in r17, $19  ; grab bit 1 of byte 0
  cbr r17, $fc
  nop
  eor r16, r17
  sbrs r16, 0
  sbr r18, (1 << 1)
  nop
  nop

  usbInLoop:
    in r16, $19  ; grab bit 2 of byte n
    cbr r16, $fc
    breq endPacket
    eor r17, r16
    sbrs r17, 0
    sbr r18, (1 << 2)
    cpi r28, $39       ; overflow limiting in event of error
    brcc usbInError

    in r17, $19  ; grab bit 3 of byte n
    cbr r17, $fc
    breq endPacket
    eor r16, r17
    sbrs r16, 0
    sbr r18, (1 << 3)
    nop
    nop

    in r16, $19  ; grab bit 4 of byte n
    cbr r16, $fc
    breq endPacket
    eor r17, r16
    sbrs r17, 0
    sbr r18, (1 << 4)
    nop
    nop

    in r17, $19  ; grab bit 5 of byte n
    cbr r17, $fc
    breq endPacket
    eor r16, r17
    sbrs r16, 0
    sbr r18, (1 << 5)
    nop
    nop

    in r16, $19  ; grab bit 6 of byte n
    cbr r16, $fc
    breq endPacket
    eor r17, r16
    sbrs r17, 0
    sbr r18, (1 << 6)
    nop
    nop

  
    in r17, $19  ; grab bit 7 of byte n
    cbr r17, $fc
    breq endPacket
    eor r16, r17
    sbrs r16, 0
    sbr r18, (1 << 7)
    st y+, r18


    in r16, $19  ; grab bit 0 of byte n+1
    cbr r16, $fc
    breq endPacket
    eor r17, r16
    clr r18        ; aporant boi
    sbrs r17, 0
    sbr r18, (1 << 0)
    nop

    in r17, $19  ; grab bit 1 of byte n+1
    cbr r17, $fc
    breq endPacket
    eor r16, r17
    sbrs r16, 0
    sbr r18, (1 << 1)


  rjmp usbInLoop

  endPacket:
    st y+, r18
;    rcall packetDecode
  usbInError:
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


spiByteOut:
push r7
push r16
push r17
push r18

    mov r16, r7
    in r17, $1b
    ldi r18, $09

    spiBitLoop2:
      dec r18
      breq endSpiBitLoop2

      cbr r17, $0c
      sbrc r16, 7
      sbr r17, $04
      out $1b, r17   ; data correct clock low
;      rcall spiWaste200Cycles
      lsl r16
      sbr r17, $08
      out $1b, r17   ; clock high
;      rcall spiWaste200Cycles
      
    rjmp spiBitLoop2
    endSpiBitLoop2:
;    rcall plzWait

pop r18
pop r17
pop r16
pop r7
ret

spiOut:
  push r16
  push r17
  push r18
  push r26
  push r27
  ldi r26, low(usbIn)
  ldi r27, high(usbIn)

  in r17, $1b

  spiOutByteLoop:
    cpi r27, $01
    brlo weOk
    cpi r26, $4c
    brsh endSpiOut
    weOk:

    ld r16, x+

    ldi r18, $09
    spiBitLoop:
      dec r18
      breq endSpiBitLoop

      cbr r17, $0c
      sbrc r16, 7
      sbr r17, $04
      out $1b, r17   ; data correct clock low
      rcall spiWaste200Cycles
      lsl r16
      sbr r17, $08
      out $1b, r17   ; clock high
      rcall spiWaste200Cycles
      
    rjmp spiBitLoop
    endSpiBitLoop:
    rcall plzWait
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

plzWait:
  push r16
  push r17
  push r18
  clr r16
  clr r17
  ldi r18, $fF
  plzWaitLoop:
    inc r16
    brne plzWaitLoop
    inc r17
    brne plzWaitLoop
    inc r18
    brne plzWaitLoop
  pop r18
  pop r17
  pop r16
ret

nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
