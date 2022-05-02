.device attiny45
.org 0x0000

; r20, r21, r22 dont mass
;
.define stackStart $0100
.define uartActive $012c
.define numUartBits $012d
.define uartData $012e
.define hexBuffer $012f     ; number of bytes on top
.define asciiBuffer $013f
;

rjmp reset ; $00  ; reset
reti       ; $01  ; int 0
reti       ; $02  ; pcint0
rjmp pcint ; $03  ; pcint1
reti       ; $04  ; wdt
reti       ; $05  ; 
rjmp timer1       ; $06  ; compare A
reti       ; $07
reti       ; $08
reti       ; $09
reti       ; $0a
reti       ; $0b
reti       ; $0c
reti       ; $0d
reti       ; $0e
reti       ; $0f
reti       ; $10



reset:
  ldi r16, low(stackStart)
  out $3d, r16
  ldi r16, high(stackStart)
  out $3e, r16

  ldi r16, $0f
  out $1a, r16 ; set thing to outputs

  ldi r16, (1<<1)  ; interrupt on pb1
  out $20, r16

  ldi r16, (1<<5)
  out $3b, r16     ; interrupt on pcie1


  sei ; enable interrupts

  sbi $1a, 7
;rcall testerSub
ldi r16, $02
sts uartActive, r16 ; for startup reasons
slowLoop:
  rcall hexToAscii
  rcall asciiOut   ; updates display
  lds r16, uartActive
  dec r16
  sts uartActive, r16

  fastLoop:
    lds r16, uartActive
    cpi r16, $00
    nop
    breq fastLoop
  

rjmp slowLoop

pcint:
  push r16
  in r16, $3f ; push sreg
  push r16
  push r17

  clr r16
  out $2D, r16
  out $2C, r16   ; clears timer

  ldi r16, $04
  out $2b, r16
  ldi r16, $E0
  out $2a, r16     ; set compare value

  ldi r16, $02
  out $0c, r16     ; allow match a interrupts     

  ldi r16, $09
  out $2E, r16     ; set clock for timer1 and clear on compare
  
  in r16, $3b
  cbr r16, $20
  out $3b, r16  ; disables pin change interrupts

  sei ; interrupts will nest here
  rcall pushData

  pop r17
  pop r16
  out $3f, r16
  pop r16
reti

timer1:
  push r16
  in r16, $3f ; push sreg
  push r16
  push r17
  push r18

;sbi $19, 7
  in r17, $16 ; grab io register
  lds r16, numUartBits
  inc r16
  sts numUartBits, r16

  lds r18, uartData
  lsr r18
  sbrc r17, 1
    sbr r18, $80
  sts uartData, r18   ; reads a bit from uart  

  cpi r16, $02
  brlo setTimerForBits
  cpi r16, $09
  brsh doneWithUart
  cpi r16, $08
  brsh doneWithTimer
  
  rjmp timerAlreadyWorking
  setTimerForBits:
  ldi r16, $03
  out $2b, r16
  ldi r16, $53
  out $2a, r16    ; 833 cycles
  timerAlreadyWorking:

  rjmp keepTimerOn
  doneWithTimer:
    sts hexBuffer, r18
    ldi r18, $02
    sts uartActive, r18   ; so display knows to update
  keepTimerOn:

  rjmp keepUartOn
  doneWithUart:
    in r16, $2e
    cbr r16, $09
    out $2e, r16   ; stops clock
    cbi $0c, 2     ; disables interrupts for compare match

    clr r16
    out $2D, r16
    out $2C, r16   ; clears timer
    sts numUartBits, r16 ;  resets bit counter

    in r16, $3b
    sbr r16, $20
    out $3b, r16   ; allows interrups on pin change

    ldi r16, $20
    out $3a, r16  ; clear interrupt flag
  keepUartOn:

  pop r18
  pop r17
  pop r16
  out $3f, r16
  pop r16
reti

pushData:
  push r16
  push r17
  push r28
  push r29

  ldi r28, low(hexBuffer + $0E)
  ldi r29, high(hexBuffer + $0E)
  
clr r16
  pushLoop:
    cpi r16, $0F
    brsh endPushLoop
    inc r16
    
    ld r17, y+
;ldi r17, $69
    st y, r17
    ld r17, -y ; dec y only
    ld r17, -y ; dec y only

  rjmp pushLoop
  endPushLoop:

  pop r29
  pop r28
  pop r17
  pop r16
ret

testerSub:
  ldi r28, low(hexBuffer)
  ldi r29, high(hexBuffer)
 
  ldi r16, $f0
  st y+, r16
  ldi r16, $e1
  st y+, r16
  ldi r16, $d2
  st y+, r16
  ldi r16, $c3
  st y+, r16
  ldi r16, $b4
  st y+, r16
  ldi r16, $a5
  st y+, r16
  ldi r16, $96
  st y+, r16
  ldi r16, $87
  st y+, r16
  ldi r16, $78
  st y+, r16
  ldi r16, $69
  st y+, r16
  ldi r16, $5a
  st y+, r16
  ldi r16, $4b
  st y+, r16
  ldi r16, $3c
  st y+, r16
  ldi r16, $2d
  st y+, r16
  ldi r16, $1e
  st y+, r16
  ldi r16, $0f
  st y+, r16

  rcall pushData

  rcall hexToAscii
  rcall asciiOut
  rcall plzWait100ms



dedloop:
 rcall plzWait100ms
 rcall plzWait100ms
 rcall plzWait100ms
 rcall hexToAscii
 rcall asciiOut
nop
nop
nop
rjmp dedloop

asciiOut:
  push r16
  push r17
  push r18
  push r19
  push r26
  push r27

  in r17, $19
  cbr r17, $08 ; sw to zero
  out $1b, r17

  ldi r16, $38       ; setup 2 line mode
  rcall asciiByteOut

  ldi r16, $01       ; clear display
  rcall asciiByteOut
  rcall plzWait

  ldi r16, $0f
  rcall asciiByteOut   ; turn on display

  sbr r17, $08     ; put in input mode
  out $1b, r17

;  lds r18, hexBuffer  ; get num bytes to send out
  ldi r18, $10
  lsl r18
  inc r18

  ldi r26, low(asciiBuffer)
  ldi r27, high(asciiBuffer)

  
  asciiByteLoop:
    dec r18
    breq endAsciiByteLoop

;    lds r19, hexBuffer
	ldi r19, $10
    lsl r19
    sub r19, r18
    cpi r19, $10
    breq needNewLine

    thePlaceTheNewLineStarts:
    ldi r19, $09
    ld r16, x+

    asciiBitLoop:
      dec r19
      breq endAsciiBitLoop
      
      cbr r17, $03  ; clk and data low
      sbrc r16, 7
      sbr r17, $01  ; data maybe high
      out $1b, r17
      sbr r17, $02  ; clock high
      lsl r16
      nop
      nop
      nop
      out $1b, r17

    rjmp asciiBitLoop
    endAsciiBitLoop:

    rcall plzWait
    sbr r17, $04  ; rclk high
    out $1b, r17
    nop
    nop
    nop
    nop
    cbr r17, $04 ; rclk low
    out $18, r17

  rjmp asciiByteLoop
  needNewLine:
    cbr r17, $08
    out $1b, r17  ; control mode
    ldi r16, $c0
    rcall asciiByteOut  ; new line
    sbr r17, $08
    out $1b, r17  ; data mode
    rcall plzWait
  rjmp thePlaceTheNewLineStarts
  endAsciiByteLoop:

  pop r27
  pop r26
  pop r19
  pop r18
  pop r17
  pop r16
ret

asciiByteOut: ;  only for use with ascii out subroutine
  ldi r19, $09
  
  asciiByteOutLoop:
    dec r19
    breq endAsciiByteOutLoop
    
    cbr r17, $03 ; clk and data low
    sbrc r16, 7
      sbr r17, 1
    out $1b, r17
    sbr r17, $02
    lsl r16
    out $1b, r17
 
  rjmp asciiByteOutLoop
  endAsciiByteOutLoop:

  rcall plzWait
  sbr r17, $04 ; rclk high
  out $1b, r17
  rcall plzWait
  cbr r17, $04
  out $1b, r17 ; rclk low
  rcall plzWait

ret

HexToAscii:
  push r16
  push r17
  push r18
  push r19

  push r26
  push r27
  push r28
  push r29
  push r30
  push r31

  ldi r28, low(asciiBuffer)
  ldi r29, high(asciiBuffer)

  ldi r26, low(hexBuffer)
  ldi r27, high(hexBuffer)

  ldi r19, $11

  forHexToAsciiLoop:
    dec r19
    breq endHexToAsciiLoop

    ld r18, x+
    ldi r30, low(charLookUp)
    ldi r31, high(charLookUp)
    lsl r30
    rol r31      ; multiply by 2
 
    mov r17, r18
    cbr r18, $0f
    swap r18
;ldi r18, $0f
    add r30, r18
    brcc noCarryHexToAscii
      inc r31
    noCarryHexToAscii:      ;  get addrs for char
 
    lpm r16, z
    st y+, r16
  
    mov r18, r17
    cbr r18, $f0
  
    ldi r30, low(charLookUp)
    ldi r31, high(charLookUp)
    lsl r30
    rol r31
    
   
    add r30, r18
    brcc noCarryHereHexToAscii
    inc r31
    noCarryHereHexToAscii:
 
    lpm r16, z
    st y+, r16 
    rjmp forHexToAsciiLoop

  endHexToAsciiLoop:

  pop r31
  pop r30
  pop r29
  pop r28
  pop r27
  pop r26

  pop r19
  pop r18
  pop r17
  pop r16
ret


charLookUp: .dw $3130 ; 0, 1
            .dw $3332 ; 2, 3
            .dw $3534 ; 4, 5
            .dw $3736 ; 6, 7
            .dw $3938 ; 8, 9
            .dw $4241 ; a, b
            .dw $4443 ; c, d
            .dw $4645 ; e, f



plzWait:
  push r16
  push r17
  clr r16
  ldi r17, $00
plzWaitLoop:
  inc r16
  brne plzWaitLoop
  inc r17
  brne plzWaitLoop
  pop r17
  pop r16
ret

plzWait100ms:
  push r16
  ldi r16, $F0
  plzWait100msLoop:
    rcall plzWait
    inc r16
    brne plzWait100msLoop
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

