;
;
;
;
; Welcome to the common packets page
; This page quickly sets up things like ACK and NAK
;


prepAck:
  push r16

  ldi r16, $10
  sts numBitsOutAS, r16
  ldi r16, $80
  sts clockSync, r16
  ldi r16, $D2
  sts pidOut, r16

  pop r16
ret

prepNak:
  push r16

  ldi r16, $10
  sts numBitsOutAS, r16
  ldi r16, $80
  sts clockSync, r16
  ldi r16, $5A
  sts pidOut, r16

  pop r16
ret
