;
; Welcome to the usb setup file
;
; This file contains subroutines that handle enumeration and such
; This may have sub files as it is expected that this will be 50%
;    of the effort for this project (yikes)
;
;
;

usbSetupMain:
  push r16
  push r17
  push r18

  trySetupLoop:
    parseLoop:
      waitForNext ; waiting for setup packet
      lds r17, pidIn
      cpi r17, $C3
      breq itsDataPacket
      cpi r17, $4B
      breq itsDataPacket
      cpi r17, $69
      breq itsInPacket
    rjmp parseLoop
     
    itsDataPacket:
      sendAck
      lds r16, (pidIn + 2)
      sts preDataType, r17
      cpi r16, $05
      breq acceptAddress
      cpi r16, $06
      breq getDescriptor
      cpi r16, $09        ; set configuration , just send emptyDataPacket
      breq acceptAddress
    rjmp trySetupLoop

    acceptAddress:
      rcall sendAddress
    rjmp trySetupLoop

    getDescriptor:
      lds r16, (pidIn + 4) ; descriptorType
      ldi r31, high(descriptorTOC * 2)
      ldi r30, low(descriptorTOC * 2)
 
      cpi r16, $21       ; HID descriptors break my cute system
      brne skipLowering
        ldi r16, $06     ; reassign 0x21 -> 0x06
      skipLowering:

cpi r16, $02
brne keepOn
sbi $19, 7
keepOn:

      dec r16
      lsl r16
      add r30, r16
      brcc noIncReqhere
        inc r31
      noIncReqHere:
      rcall sendDescriptor     
    rjmp trySetupLoop
      
  rjmp trySetupLoop
  itsInPacket:      

  pop r18
  pop r17
  pop r16
ret

sendAddress:
  push r16
  push r28
  push r29

  ldi r28, low(numBitsOutAS)
  ldi r29, high(numBitsOutAS)
  
  ldi r16, $20  ; includes pid and clock sync
  st y+, r16

  ldi r16, $80
  st y+, r16
  ldi r16, $4B
  st y+, r16
  clr r16
  st y+, r16
  st y+, r16

  acceptAddressLoop:
    waitForNext
    rcall usbOut
;    waitForNext           ;***************** FIX ME ***********
;    ldi r16, PidIn
;    cpi r16, $D2
;  brne acceptAddressLoop
  
  pop r29
  pop r28
  pop r16
ret

sendDescriptor:
  push r16
  push r18  ; holds number of bytes to be sent total
  push r19  ; holds bytes in packet
  push r28
  push r29  ; points to sram
  push r30  ; points to pm
  push r31

  lpm r18, z+  ; descriptor pointer low
  lpm r16, z   ; descriptor pointer high

  mov r30, r18 ; load z pointer with correct location
  mov r31, r16 ;  

  lsl r30      ; 
  rol r31      ; word to byte

  lpm r18, z



  loadSramLoop:
    cpi r18, $01
    brlo endLoadSramLoop
    ldi r29, high(usbDataOutBS)
    ldi r28, low(usbDataOutBS)
    clr r19
    loadPacketLoop:
      cpi r19, $08
      brsh endLoadPacket   ; case where we run out of packet
      cpi r18, $01
      brlo endLoadPacket   ; case where we run out of data
      dec r18
      inc r19
      lpm r16, z+
      st y+, r16
    rjmp loadPacketLoop
  endLoadPacket:
  mov r16, r19
  lsl r16
  lsl r16
  lsl r16  ; multiply by 8
  sts numBitsOutBS, r16
  rcall prepDataOutMain

  sendConfigLoop:
    waitForNext
    lds r16, pidIn
    cpi r16, $D2
    breq endSendConfigLoop
    rcall usbOut
  rjmp sendConfigLoop
  endSendConfigLoop:

  rjmp loadSramLoop
  endLoadSramLoop:

  pop r31
  pop r30
  pop r29
  pop r28
  pop r19
  pop r18
  pop r16

ret
