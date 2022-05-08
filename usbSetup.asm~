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

waitForToken:
  lds r16, usbDataReceived   ; runs in circles waiting for input
  cpi r16, $01
  brlo waitForToken

  sbi $19, 7
  clr r16
  sts usbDataReceived, r16   ; clear data recieved


waitForOut:

waitForIn:

  pop r16
ret
