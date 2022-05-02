.device attiny45 ; well 44 but close enough
.org 0x0000

; pb0 and pb1 are for crystal
; pa0 is d+
; pa1 is d-
; pa2 is sclk
; pa3 is mosi

.define stackStart $0100
.define usbIn $0153


rjmp reset  ; $00
reti        ; $0b
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
 
pcint0:
reset:
  ldi r16, low(stackStart)   ; sets stack pointer to ok place
  out $3d, r16
  ldi r16, high(stackStart)
  out $3e, r16

  ldi r16, $01  ; enable interrupts
  out $12, r16  
  ldi r16, $10
  out $3b, r16

  ldi r16, $0c
  out $1a, r16

;  sei ; enable interrupts

  in r17, $1A
  sbr r17, (1 << 2)
  out $1A, r17

ldi r16, $69
mov r7, r16
resetLoop:
inc r7
rcall uartOut

clr r16
clr r17
startLoopMeme:
inc r16
brne startloopMeme
inc r17
brne startloopMeme
inc r18
brne startloopMeme

rjmp resetLoop

.include "uart9600.asm"


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
