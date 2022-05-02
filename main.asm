;  Welcome to the main file for the usb spi "keyboard"
;  
;
;
;

.device attiny45 ; well 44 but close enough
.org 0x0000

; pb0 and pb1 are for crystal
; pa0 is d+
; pa1 is d-
; pa2 is sclk
; pa3 is mosi

; ###################### CODE STARTS HERE ###########################

rjmp reset        ; $00
reti              ; $0b
rjmp pcint0       ; $02
reti              ; $03
reti              ; $04
reti              ; $05
reti              ; $06
reti              ; $07
reti              ; $08
rjmp timer0CompA  ; $09
reti              ; $0a
reti              ; $0b
reti              ; $0c
reti              ; $0d
reti              ; $0e
reti              ; $0f
reti              ; $10
 
.include "usbDataIn.asm"
.include "debugFunctions.asm"
.include "definitions.asm"

reset:
  ldi r16, low(stackStart)   ; sets stack pointer to ok place
  out $3d, r16
  ldi r16, high(stackStart)
  out $3e, r16

  sbi $12, 1  ; enable interrupts on PA0
  ldi r16, (1 << 4)
  out $3b, r16  ; enable interrupts on Port A

  ldi r16, $0c ; PA2 and PA3 to outputs
  out $1a, r16 ; PA0 and PA1 remain inputs

sbi $1a, 7


  sei ; enable interrupts

;  rcall packetDecode
  resetLoop:
    nop
    nop
    nop
rjmp resetLoop

packetDecode:
  push r16

clr r16
;out $12, r16

  ldi r16, $47
  sts $012c, r16

  rcall usbDataOutOnUart
;  sbi $19, 7

sbi $12, 0

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
nop
