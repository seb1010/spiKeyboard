;
; this file is for subroutines related to uart input
; 
;
;
;
;
;
;
; ################# code starts here ################;
;
;

setupUartClock: ; we are baselining 600 baud which gives 1.67us per bit
  push r18      ; this is 20k cycles
  
  ldi r18, $02  ; prescale clock by 8
  out $2e, r18  ; now we need 2.5k cycles per bit

  clr r18
  out $2D, r18
  out $2C, r18 ; clearing the clock

  ldi r18, $0E
  sts uartClkHigh, r18
  ldi r18, $A6
  sts (uartClkHigh + 1), r18 ; we will compare to this register in future

  pop r18
ret

sampleUart:
  push r17
  push r18
  push r19
  push r20


  sampleUartLoop:
    in r18, $2C           ; low byte must be read first
    in r18, $2D           ; grab high byte of clock and 
    lds r19, uartClkHigh  ; clock compare value


    cp r18, r19
    brlo plzNoSampleUart
      in r17, $16
	  lsr r20
      sbrc r17, 2
   	    sbr r20, $80

	  lds r18, (uartClkHigh + 1)
	  ldi r19, 196  ; need to increase for next compare
	  add r18, r19
	  sts (uartClkHigh + 1), r18
	  lds r18, uartClkHigh
	  brcc noCarryInUartLoop
	    inc r18
	  noCarryInUartLoop:
	  ldi r19, $09
	  add r18, r19
	  sts uartClkHigh, r18

	plzNoSampleUart:
	lds r18, uartClkHigh
	cpi r18, $58
	brsh doneReadingUart
	rjmp sampleUartLoop

  doneReadingUart:
  sts keyboardNumberOut, r20

  ensureUartDoneLoop:   ; this exits to check ensure we have
    in r18, $2C         ; reached the end of the uart packet
	in r18, $2D
    cpi r18, $65
  brlo ensureUartDoneLoop


  pop r20
  pop r19
  pop r18
  pop r17

ret

convertToUsbChar:
  push r18
  push r19

  lds r18, keyboardNumberOut
  

  ldi r19, $1C      ; space bar
  cpi r18, $10
  breq OffsetComplete

  ldi r19, $08      ; newline
  cpi r18, $20
  breq OffsetComplete

  ldi r19, ($100 - $09)   ; zero
  cpi r18, $30
  breq OffsetComplete

  ldi r19, ($100 - $13)   ; nums 1 - 9
  cpi r18, $3A
  brlo OffsetComplete

  ldi r19, ($100 - $3D)   ; uppercase letter
  cpi r18, $5B
  brlo OffsetComplete

  OffsetComplete:
    add r18, r19
	sts keyboardNumberOut, r18

  pop r19
  pop r18
ret



