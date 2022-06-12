;
; Welcome to the prep for output file
;
;  This file adds sync, crc and bitstuffing to data before sending it
;  
;  
;
;

;################## Code Starts Here ###########################

prepDataOutMain:   ; takes about 240 uS or 2.9k cycles
  push r16

  rcall movOutToCrc16Mem
  rcall crc16
  rcall appendWithCrc16
  rcall stuffBits
  rcall flipDataType
  lds r16, preDataType
  sts pidOut, r16

  pop r16
ret

flipDataType:   ; switches data0 to data1
  push r16
  push r17

  lds r16, preDataType
  ldi r17, $88
  eor r16, r17
  sts preDataType, r16

  pop r17
  pop r16
ret

prepTokenOutMain:
;  rcall moveOutToCrc5Mem
  rcall crc5
;  rcall appendWithCrc5
  rcall stuffBits
ret


movOutToCrc16Mem:
  push r16 ; counter
  push r17 ; temp storage
  push r26
  push r27
  push r28
  push r29
    ldi r26, low(crc16Length)
    ldi r27, high(crc16Length)

    ldi r28, low(numBitsOutBS)
    ldi r29, high(numBitsOutBS)    

    clr r16
    movOutLoop:
      cpi r16, $09
      inc r16
    brsh endMoveOutLoop
    ld r17, y+
    st x+, r17  
    rjmp movOutLoop
    endMoveOutLoop:

  pop r29
  pop r28
  pop r27
  pop r26
  pop r17
  pop r16
ret

appendWithCrc16:
  push r16
  push r17
  push r26
  push r27
    ldi r26, low(numBitsOutBS)
    ldi r27, high(numBitsOutBS)

    ld r16, x  ; load number of bits

    ldi r17, $10
    add r17, r16
    st x+, r17  ; increase number of bits by 16

    lsr r16
    lsr r16
    lsr r16 ; divide number of bits by 8 

    add r26, r16
    brcc noNeedForAddAppend16
      inc r27
    noNeedForAddAppend16:
    
    lds r16, crcOut
    st x+, r16
    lds r16, (crcOut + 1)
    st x, r16

  pop r27
  pop r26
  pop r17
  pop r16
ret


crc5:
  push r16 ; holds msB of data
  push r17 ; holds lsB of data
  push r18 ; remainder
  push r19 ; for xoring data with remainder
  push r20 ; holds genorator polynomial
  push r21 ; holds number of bits of data

  lds r16, (crc5Data)
  lds r17, (crc5Data + 1)
  ldi r18, $1f
  ldi r20, $05
  lds r21, crc5Length
  
  crc5Loop:
    mov r19, r16
    cbr r19, $fe
    swap r19
    eor r19, r18
    lsl r18
    sbrc r19, 4
      eor r18, r20
    lsr r17
    ror r16
    dec r21
  brne crc5Loop

  ldi r16, $1f
  eor r18, r16
  cbr r18, $e0
  sts crcOut, r18

  pop r21
  pop r20
  pop r19
  pop r18
  pop r17
  pop r16
ret

crc16:
  push r15 ; data
  push r16 ; data
  push r17 ; lsB of remainder
  push r18 ; msB of remainder

  push r19 ; lsB of polynomial
  push r20 ; msB of polynomial
  push r21 ; length of data in bits
  push r22 ; bit counter

  push r26 ; pointer to data msB
  push r27 ; pointer to data lsB

  ldi r18, $ff ; prime with 1s
  ldi r17, $ff
  ldi r20, $A0 ; load polynomial
  ldi r19, $01
  ldi r27, high(crc16Length) ; set up x pointer
  ldi r26, low(crc16Length)
  ld r21, x+ ; load number of bits

;  ldi r21, $01

  cpi r21, $00
  breq endCrc16Loop
  crc16Loop:
    ld r16, x+  ; load next byte into r16
    ldi r22, $08
    crc16BitLoop:
    clr r15
    lsr r16
    rol r15  ; just hold bit

    eor r15, r17 ; exor msb of remainder with next data bit

    lsr r18
    ror r17  ; shift remainder

    sbrc r15, 0      ; apply exor
      eor r18, r20
    sbrc r15, 0
      eor r17, r19

    dec r21
    breq endCrc16Loop
    dec r22
    brne crc16BitLoop
  rjmp crc16Loop
endCrc16Loop:

  ldi r27, high(crcOut)
  ldi r26, low(crcOut)
  
  ldi r16, $ff ; flip bits of remainder
  eor r18, r16
  eor r17, r16

  st x+, r17
  st x, r18

  pop r27
  pop r26

  pop r22
  pop r21
  pop r20
  pop r19

  pop r18
  pop r17
  pop r16
  pop r15
ret


stuffBits:   ; also adds clock sync ; pid added after
  push r16
  push r17
  push r18
  push r19
  push r20

  push r21
  push r22
  push r26
  push r27

  push r28
  push r29



  ldi r26, low(numBitsOutBS)
  ldi r27, high(numBitsOutBS)

  ldi r28, low(clockSync)
  ldi r29, high(clockSync)

  ldi r16, $80   ; clock sync added
  st y+, r16

  ld r16, y+     ; just to inc y

  ld r18, x+     ; get initial packet size
  ;   r19        ; holds number of shifts of intial byte
  ldi r20, $09   ; holds number of shifts of final byte
  clr r21        ; holds ones in a row
  ; noneedclr r17          ; holds byte to be sent off
  clr r22        ; holds number of bits added
 

 stuffLoop:
    ld r16, x+
    ldi r19, $08
    bitStuffLoop:
      dec r20           ; transfer bit over
      brne noStoAgain
        ldi r20, $08
        st y+, r17
      noStoAgain:
      lsr r17 
      sbrc r16, 0
        sbr r17, (1 << 7)

      sbrc r16, 0
        inc r21
      sbrs r16, 0
        clr r21
      cpi r21, $06
      brlo noExtraBit
; extra bit needed
        clr r21
        inc r22
        dec r20
        brne noNeedToSto
          ldi r20, $08
          st y+, r17
        noNeedToSto:
        lsr r17
      noExtraBit:
 
    dec r18
    breq endStuffLoop
    lsr r16
    dec r19
    brne bitStuffLoop
  rjmp stuffLoop
  endStuffLoop:

    finishUpStuffLoop:
    dec r20
    breq doneWithShifting
    lsr r17
    rjmp finishUpStuffLoop
    doneWithShifting:
      st y, r17

      ldi r18, $10
      add r22, r18 ; adding bits for sync and pid

      lds r18, numBitsOutBS
      add r18, r22
      sts numBitsOutAS, r18

  pop r29
  pop r28

  pop r27
  pop r26
  pop r22
  pop r21

  pop r20
  pop r19
  pop r18
  pop r17
  pop r16
ret
