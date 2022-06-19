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
.include "uartIn.asm"
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

rcall usbSetupMain

clr r18             ; this initializes things
sts keyboardNumberOut, r18
rcall loadKeyboardPacket
waitForNext
rcall usbOut
waitForNext
rcall usbOut


waitForUartLoop:
  in r17, $16
  cbr r17, $FB
  brne waitForUartLoop ; checking if input is low


  rcall setupUartClock
  rcall sampleUart
  rcall convertToUsbChar 
ldi r18, $07  ; ########### D ############ 
sts keyBoardNumberOut, r18
  rcall loadKeyboardPacket
  waitForNext
  rcall usbOut
  clr r18
  sts keyboardNumberOut, r18
  rcall loadKeyboardPacket
  waitForNext
  rcall usbOut

rjmp waitForUartLoop

resetLoop:
  ldi r16, $00
  sts keyboardNumberOut, r16
  rcall loadKeyboardPacket
  waitForNext
  rcall usbOut

  ldi r16, $04
  sts keyboardNumberOut, r16
  rcall loadKeyboardPacket
  waitForNext
  rcall usbOut

  rcall pleaseWait

  
rjmp resetLoop


dedLoop:
  cli
  sbi $19, 7
  rcall pleaseWait
rjmp dedLoop

loadKeyboardPacket:
  push r18
  push r19
  push r28
  push r29

  ldi r28, low(numBitsOutBs)
  ldi r29, high(numBitsOutBs)

  ldi r18, $40
  st y+, r18

  clr r18
  clr r19
  loadEmptyLoop:
    cpi r19, $07
    brsh endLoadEmptyLoop
	clr r18
	cpi r19, $02
	brne noCharHere
      lds r18, keyboardNumberOut
	noCharHere:
	st y+, r18
    inc r19
  rjmp loadEmptyLoop
  endLoadEmptyLoop:

  rcall prepDataOutMain

  pop r29
  pop r28
  pop r19
  pop r18
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
