stuffBits:   ; also adds clock sync ; pid added after
  push r16
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
  ; r17          ; holds byte to be sent off
  clr r22        ; holds number of bits added
 

  ldi r18, $50

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
;  lds r17, $0153
;  mov r7, r17
;  rcall spiOut
  


  pop r29
  pop r28

  pop r27
  pop r26
  pop r22
  pop r21

  pop r20
  pop r19
  pop r18
  pop r16
ret
