;  Welcome to the main file for the usb spi "keyboard"
;  
; Random notes
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
reti              ; $01
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
 
.include "debugFunctions.asm"
.include "definitions.asm"
.include "variables.asm"
;.include "prepForOutput.asm"
.include "decodePacket2.asm"
.include "usbOut.asm"
.include "usbMacros.asm"
.include "usbDataIn.asm"
.include "usbSetup.asm"
.include "descriptorTables.asm"

reset:
  ldi r16, low(stackStart)   ; sets stack pointer to ok place
  out SPL, r16
  ldi r16, high(stackStart)
  out SPH, r16

  sbi $12, 0  ; enable interrupts on PA0
  ldi r16, (1 << 4)
  out $3b, r16  ; enable interrupts on Port A

  ldi r16, (1 << 2) ; PA2 to output
  out $1a, r16 ; PA0 and PA1 remain inputs
  out $1b, r16 ; PA2 High

  ldi r16, high(numBitsOutAS)   ; sets up pointer for usb out
  sts yPointOut, r16
  ldi r16, low(numBitsOutAS)
  sts (yPointOut + 1), r16

  ldi r16, $10                 ; sets up nak packets 
  sts nakOutNumBits, r16
  ldi r16, $80
  sts (nakOutNumBits + 1), r16
  ldi r16, $5A
  sts (nakOutNumBits + 2), r16

  ldi r16, $4B
  sts preDataType, r16


sbi $1a, 7   ; PA7 Lo-z for debugging

sei ; enable interrupts


ldi r28, low(numBitsOutBS)
ldi r29, high(numBitsOutBS)

;ldi r16, $05
;sts (pidIn+4), r16
;rcall getDescriptor
rcall usbSetupMain
;rcall getDescriptor

;sendNak
;sendAck

resetLoop:
    nop
    nop
    nop
rjmp resetLoop


dedLoop:
  cli
  sbi $19, 7
  rcall pleaseWait
rjmp dedLoop


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
