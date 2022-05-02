.device attiny45
.org 0x0000

.define crc16Length $011e
.define crc5Length $0126
.define crc5Data $0127
.define crcOut $0129
.define numBitsInBDS $012b
.define numBitsInADS $0139
.define usbDataInADSStart $013a
.define numBitsOutBS 0x0145
.define numBitsOutAS 0x0151
.define clockSync 0x0152


reset:
ldi r16, $01   ; set sp
out $3e, r16
out $3d, r16

ldi r28, low(numBitsOutBS)
ldi r29, high(numBitsOutBS)

ldi r16, $40 ; num bits
st y+, r16

ldi r16, $80
st y+, r16

ldi r16, $06
st y+, r16

ldi r16, $00
st y+, r16

ldi r16, $01
st y+, r16

ldi r16, $00
st y+, r16

ldi r16, $00
st y+, r16

ldi r16, $12
st y+, r16

ldi r16, $00
st y+, r16

rcall movOutToCrc16Mem
rcall crc16

rcall appendWithCrc16

;ldi r16, $C3
;sts $0153, r16
;rcall stuffBits

ldi r16, $80
sts $0152, r16
ldi r16, $D2
sts $0153, r16
ldi r16, $10
sts $0151, r16

rcall usbOut

;lds r7, crcOut
;rcall spiOut
;rcall plzWait

;lds r7, crcOut + 1
;rcall spiOut
;rcall plzWait

;rcall plzWait

rjmp reset

usbOut:
  ldi r28, low(clockSync)
  ldi r29, high(clockSync)
  lds r20, numBitsOutAS
  inc r20
  in r17, $1b   ; input port A
  cbr r17, (1 << 0)  ; D+ low
  sbr r17, (1 << 1 ) ; D- high
  out $1b, r17

  in r16, $1a  
  sbr r16, $03  ; D+ and D- to outputs
  out $1a, r16

  ldi r19, $03
  clr r1
  clr r2

  ld r16, y+
  rjmp nibbleOutLoop

  newByte:
  out $1b, r17
  ld r16, y+
  nibbleOutLoop:
    inc r1
    dec r20               ; bit 0 out
    breq endByteOutLoop
    sbrs r16, 0
      eor r17, r19
    out $1b, r17
    nop
    nop
    nop

    dec r20
    breq endByteOutLoop
     
    sbrs r16, 1           ; bit 1 out
      eor r17, r19
    out $1b, r17
    nop   
    nop
    nop

    dec r20
    breq endByteOutLoop

    sbrs r16, 2           ; bit 2 out
      eor r17, r19
    out $1b, r17
    
    sbrs r16, 3
      eor r17, r19
    dec r20               ; bit 3 out
    breq endByteOutLoopPlus          
    sbrs r1, 0            ; load new byte
      rjmp newByte
    swap r16
    out $1b, r17

  rjmp nibbleOutLoop
  endByteOutLoopPlus:
    nop
  endByteOutLoop:

     cbr r17, $03
     out $1b, r17

     ldi r16, $fc
     wasteLoop:
      inc r16
     brne wasteLoop
     
     in r16, $1a
     cbr r16, $03
     sbr r17, (1 << 1)
     out $1b, r17 ; D- high
     out $1a, r16 ; tristate outputs
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
  
ret

destuffBits:
  push r16
  push r17
  push r18
  push r19

  push r20
  push r21
  push r26
  push r27

  push r28
  push r29

  ldi r26, low(numBitsInBDS)
  ldi r27, high(numBitsInBDS)

  ldi r28, low(usbDataInADSStart)
  ldi r29, high(usbDataInADSStart)

  ; r16 holds bds
  ; r17 holds ads
  ld r18, x+ ; holds numBits
ldi r18, $09
  ldi r19, $08 ; bits in bds 
  ldi r20, $08 ; bits in ads
  clr r21      ; ones in a row
  clr r22      ; bits removed

  destuffLoop:
    ld r16, x+
    ldi r19, $08
    destuffBitLoop:
      cpi r21, $06
      breq bitToRemove
       ;noBitToRemove
        dec r20
        lsr r16
        ror r17
        rjmp noBitsToRem
      bitToRemove:
        lsr r16
        inc r22
        clr r21
      noBitsToRem:

      sbrs r17, 7
        clr r21
      sbrc r17, 7
        inc r21

      cpi r20, $00
      brne noStoHere
        st y+, r17
        ldi r20, $08
      noStoHere:

      dec r18
      breq endDestuffLoop
      dec r19
      brne destuffBitLoop
  rjmp destuffLoop
  endDestuffLoop:
    mov r7, r20
    cpi r20, $08
    breq allDoneDestuff
      finishUpDSLoop:
;        lsr r17
        dec r20
        brne finishUpDSLoop
        st y, r17   
    allDoneDestuff:

  lds r18, numBitsInBDS
  sub r18, r22
  sts numBitsInADS, r18

;lds r16, $013a
;mov r7, r16
;rcall spiOut

  pop r29
  pop r28
  pop r27
  pop r26

  pop r21
  pop r20
  pop r19
  pop r18

  pop r17
  pop r16
ret

spiOut:  ; sends r7 out
  push r7
  push r16
  push r17
  push r18
  ldi r18, $08

  sbi $1a, 2               ; pa2 and 3 to outputs
  sbi $1a, 3
 
  in r17, $1b
    
  bitSpiLoop:
    cbr r17, $0c
    sbrc r7, 7
      sbr r17, (1 << 2)
    out $1b, r17 ; data on pin. clock low
    lsl r7
    sbi $1b, 3   ; clock high

  dec r18
  brne bitSpiLoop

  pop r18
  pop r17
  pop r16
  pop r7
ret

plzWait:
  push r16
  push r17
  push r18
  clr r16
  clr r17
  ldi r18, $FD

  countLoop2:
    inc r16
    brne countLoop2
    inc r17
    brne countLoop2
    inc r18
    brne countLoop2

  pop r18
  pop r17
  pop r16
ret

deviceDesciptor:
.dw $0112  ; 18 bytes, device descriptor
.dw $0002  ; usb 2.0
.dw $0000  ; device class and subclass
.dw $0800  ; max packet size
.dw $6d80  ; vendor id
.dw $80c8  ; product id
.dw $0368  ; release number
.dw $0402  ; index of manufacture and product string
.dw $0100  ; index of serial number and number of configurations





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

