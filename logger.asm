.device attiny45 ; well 44 but close enough
.org 0x0000

; pb0 and pb1 are for crystal
; pa0 is d+
; pa1 is d-
; pa2 is sclk
; pa3 is mosi
; pb0 is input

.define stackStart $007F
.define usbIn $0080


rjmp reset  ; $00
reti        ; $01
rjmp pcint0 ; $02
reti        ; $03
reti        ; $04
reti        ; $05
reti        ; $06
reti        ; $07
reti        ; $08
reti        ; $09
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


dedLoop:
  cpi r21, $01
  breq itsATrap

rjmp dedLoop

itsATrap:
cli
rcall plzWait
rcall usbDataOutOnUart
rcall usbDataOutOnUart
itsATrapLoop:
sbi $19, 7
nop
rjmp itsATrapLoop

.include "uart9600.asm"

pcint0:
  push r16
  in r16, $3f ; stores sreg
  push r16
  push r17
  push r18
;  push r20
  push r28
  push r29
nop
nop
nop
nop

nop
nop
clr r20
;inc r21
cpi r20, $50
brcc sneak

  lds r29, $015E
  lds r28, $015F
nop
ldi r29, high(usbIn)
ldi r28, low(usbIn)
  
;ld r16, y
;st y+, r16

  ldi r16, $f9
  stupidWasteLoop:
  inc r16
  brne stupidWasteLoop

  clr r18

  in r17, $19    ; just get ready for bit 0
  cbr r17, $fc
  nop
  nop
  nop
  nop
  nop
  nop
;sbi $19, 7
  in r16, $19  ; grab bit 0 of byte 0
  cbr r16, $fc
  nop
  eor r17, r16
  sbrs r17, 0
  sbr r18, (1 << 0)
  nop
  nop

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
sneak:    cpi r20, $50
    brcc usbInError
;nop
;nop

    in r17, $19  ; grab bit 3 of byte n
    cbr r17, $fc
    breq endPacket
    eor r16, r17
    sbrs r16, 0
    sbr r18, (1 << 3)
    inc r20
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
  sbi $19, 7

;in r16, $3b
;cbr r16, (1 << 4)
;out $3b, r16         ; disable interrupts

lds r16, usbIn
cpi r16, $4B
brne contOn
; inc r21
lds r7, (usbIn + 3)
rcall uartOut
contOn:
sts $015E, r29
sts $015F, r28


  ldi r16, $10
  out $3a, r16     ; clears interrupt flag

  pop r29
  pop r28
;  pop r20
  pop r18
  pop r17
  pop r16
  out $3f, r16
  pop r16

;in r7, $3A
;rcall uartOut
;rjmp itsATrap
reti

packetDecode:
  ldi r28, low(usbIn)
  ldi r29, high(usbIn)

  ld r18, y+
  mov r16, r18
  swap r16
  cbr r16, $f0
  cbr r18, $f0
  eor r16, r18
  cpi r16, $f0       ; error checks the pid
  brne errorInPacket

  cpi r18, $09       ; check for setup packet
  breq itsASetUp



  errorInPacket:
  rjmp endDecodePacket

  itsASetUp:

 endDecodePacket:

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
  ldi r18, $f0
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
