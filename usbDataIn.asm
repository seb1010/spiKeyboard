; Welcome to the USB Data In file
;
; This file has a very simple job
; Detects, reads and slams into memory one packet then calls decode function
;     Specific addresses are used for this purpose
;         usbIn has a address associated in the definitions file
;     data stored starts at the PID sync is discared
;     NRZI is decoded
;     bits are not destuffed
;     counter is used 
;     allows processing to be done while waiting for the sync to finish
;
; Thanks for reading


pcint0:
  push r16

  ldi r16, $00
  out $32, r16  ; clear timer
  ldi r16, $1D
  out $36, r16  ; compare match a
  ldi r16, $01
  out $33, r16  ; starts timer
  ldi r16, (1 << 1)
  out $39, r16  ; enables interrupts for compare match a
  
  cbi $12, 0    ; disable pin change interrupts
  ldi r16, ( 1 << 4)
  out $3A, r16  ; clears PCIF0

  pop r16
reti

timer0CompA:
  push r16
  in r16, $3f ; stores sreg
  push r16
  push r17

  in r17, $19    ; just get ready for bit 0
  cbr r17, $fc

    ldi r16, $00
    out $33, r16 ; stop timer

  push r18
  push r28 ; save 4 cycles here


  in r16, $19  ; grab bit 0 of byte 0
    cbr r16, $fc
    clr r18
    eor r17, r16
    sbrs r17, 0
    sbr r18, (1 << 0)
  push r29     ; just using time wisely

  in r17, $19  ; grab bit 1 of byte 0
  cbr r17, $fc
  nop
  eor r16, r17
  sbrs r16, 0
  sbr r18, (1 << 1)
  ldi r29, high(pidIn)    ; just using time wisely
  ldi r28, low(pidIn)     ; set correct y pointer

  usbInLoop:
    in r16, $19  ; grab bit 2 of byte n
    cbr r16, $fc
    breq endPacket
    eor r17, r16
    sbrs r17, 0
    sbr r18, (1 << 2)
    cpi r28, $39       ; overflow limiting in event of error
    brcc usbInError

    in r17, $19  ; grab bit 3 of byte n
    cbr r17, $fc
    breq endPacket
    eor r16, r17
    sbrs r16, 0
    sbr r18, (1 << 3)
    nop
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
  usbInError:            ;  eventually add something here lol
  rjmp reset             ; this is ugly it is designed to reset this device when the reset pulse is given by the host, yes it's ugly

  endPacket:
    st y+, r18

   lds r16, packetReady  ; this function defaults to naking in packets
   cpi r16, $01          ; this is not elegant, but required to keep
   brsh dontSendNak      ; bus turn around times within spec

   lds r16, pidIn        ; only nak in packets
   cpi r16, $69
   brne dontSendNak          

     sendNak
     rjmp doneNotSending
   dontSendNak:
     ldi r16, $01
     sts usbDataReceived, r16  ; noting that new packet was received
   doneNotSending: 

;  inc r24
;  cpi r24, $03
;  brne wegood2
;  cli
;  rcall usbDataOutOnUart
;  rjmp dedLoop
;  wegood2:

  ldi r16, ( 1 << 0)
  sts usbDataReceived, r16
  pop r29
  pop r28
  pop r18
  pop r17
  pop r16
  out SREG, r16
  pop r16
  sbi $12, 0
reti
