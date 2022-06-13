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
      cpi r16, $09      ; set configuration , just send emptyDataPacket
      breq acceptAddress
      cpi r16, $0A      ; set configuration , just send emptyDataPacket
      breq acceptAddress
    rjmp trySetupLoop

    acceptAddress:
      rcall sendAddress
    rjmp trySetupLoop

    getDescriptor:

cpi r16, $02 ; testcode to trigger on configuration descriptor
brne keepOn
sbi $19, 7
keepOn:

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
  push r17
  push r18
  push r19
  push r28
  push r29


  lds r17, (pidIn + 1)
  lds r18, (pidIn)
  lds r19, (pidIn + 2)
 
  loadEmptyDataPacket: 
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
	lds r16, pidIn
	cpi r16, $69
	breq sendMrDataPacket
	cpi r16, $D2
	breq weAreDoneHere
	cpi r16, $4B
	brne acceptAddressLoop
	sendAck
  rjmp loadEmptyDataPacket

  sendMrDataPacket:
    rcall usbOut
  rjmp acceptAddressLoop
  weAreDoneHere:
  
  pop r29
  pop r28
  pop r19
  pop r18
  pop r17
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

  ;parseDescriptorType:
    lds r16, (pidIn + 4) ; grab descriptorType
    lds r19, (pidIn + 5) ; descriptor index
	lds r18, (pidIn + 7) ; get descriptor length
	lds r29, (pidIn + 1) ; looking for get report
	lds r28, (pidIn + 3) ; looking for get report

    cpi r29, $A1  ; this is a bit hacky as this isn't a descriptor
	brne notGetReport
	  cpi r28, $01
	  brne notGetInputReport
	    ldi r18, $03
	    ldi r30, low(getInputReport)
	    ldi r31, high(getInputReport)
	  rjmp readyToSendDescriptor
	  notGetInputReport: ; so output report
	    ldi r18, $02
	    ldi r30, low(getOutputReport)
	    ldi r31, high(getOutputReport)
	  rjmp readyToSendDescriptor
	notGetReport:

    cpi r16, $01
    brne notDeviceDescriptor
	  ldi r30, low(deviceDescriptor)
	  ldi r31, high(deviceDescriptor)
	  cpi r18, $12   ; if the descriptor is longer than 18 bytes -> 18
	  brlo deviceLengthOk
	  ldi r18, $12
	  deviceLengthOk:
    rjmp readyToSendDescriptor
    notDeviceDescriptor:

    cpi r16, $02
    brne notConfigurationDescriptor
	  ldi r30, low(configurationDescriptor)
	  ldi r31, high(configurationDescriptor)
    rjmp readyToSendDescriptor
    notConfigurationDescriptor:
  
    cpi r16, $22
    brne notReportDescriptor
	  cpi r19, $01
	  breq sendReportDescriptor1
;cli
;rcall usbDataOutOnUart
;rjmp dedLoop
        ldi r30, low(ReportDescriptor0)
	    ldi r31, high(ReportDescriptor0)
      rjmp readyToSendDescriptor

	  sendReportDescriptor1:
	    ldi r30, low(ReportDescriptor1)
	    ldi r31, high(ReportDescriptor1) 
    notReportDescriptor:
  
  readyToSendDescriptor:

  lsl r30  ; turns word pointer to byte pointer
  rol r31
    

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
;cli
;rcall outOnUart
;rcall dedLoop
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
