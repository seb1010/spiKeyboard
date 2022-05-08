packetDecode:  ; used inverted and backwards pid for speed
  push r16
    lds r16, usbIn
    cbr r16, $F0
  sts BmPrevious, r16
  cpi r16, $10
  brlo lessThanTen

    ;values here are greater than $10
    cbr r16, $F1
    cpi r16, $08
    brlo handshakePacket
    rjmp specialPacket

  lessThanTen:
    cbr r16, $F1
    cpi r16, $08
    brlo dataPacket
    rjmp tokenPacket


  handshakePacket:
  rjmp packetDecoded
    

  dataPacket:
  rjmp packetDecoded

  specialPacket:
  rjmp packetDecoded

  tokenPacket:
  rjmp packetDecoded

  packetDecoded:  
  
  pop r16
ret
