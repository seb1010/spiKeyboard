
;
;  welcome to send data out
;  this files holds just one subroutine
;  takes data stored in sram and spams it out with narzi encodeing
;
;
; ############## code starts here ##########################

usbOut:
  in r17, $1b   ; input port A
  cbi $12, 0
  sbr r17, (1 << 0)
  cbr r17, (1 << 1)
  in r16, $1a  
  sbr r16, $03  ;
  out $1b, r17  ; first bit out takes about 14 cycles 1.5 bit times
  out $1a, r16  ; to outputs
  
  lds r28, (yPointOut + 1)
  lds r29, (yPointOut + 0)
  nop
  ldi r19, $03
  eor r17, r19
  out $1b, r17   ; bit 1 out

  ld r20, y+     ; loads number of bits
  dec r20
  ld r16, y+     ;   inc y
  ldi r16, $80   ; load clk sync

  eor r17, r19
  out $1b, r17   ; bit 2 out
  dec r20
  nop
  nop

  usbOutLoop:
    dec r20   
    breq endByteOutLoop
    sbrs r16, 3
      eor r17, r19
    out $1b, r17         ; bit 3 out


    nop   
    nop
    nop
    dec r20
    breq endByteOutLoop
    sbrs r16, 4        
      eor r17, r19
    out $1b, r17          ; bit 4 out

    nop   
    nop
    nop
    dec r20
    breq endByteOutLoop
    sbrs r16, 5      
      eor r17, r19
    out $1b, r17          ; bit 5 out

    nop   
    nop
    nop
    dec r20
    breq endByteOutLoop
    sbrs r16, 6        
      eor r17, r19
    out $1b, r17          ; bit 6 out

    nop   
    nop
    nop
    dec r20
    breq endByteOutLoop
    sbrs r16, 7        
      eor r17, r19
    out $1b, r17          ; bit 7 out

    nop   
    ld r16, y+
    dec r20
    breq endByteOutLoop
    sbrs r16, 0        
      eor r17, r19
    out $1b, r17          ; bit 0 out

    nop   
    nop
    nop
    dec r20
    breq endByteOutLoop
    sbrs r16, 1        
      eor r17, r19
    out $1b, r17          ; bit 1 out
 
    nop
    nop
    nop
    dec r20
    breq endByteOutLoop
     
    sbrs r16, 2          
      eor r17, r19
    out $1b, r17          ; bit 2 out
    nop

  rjmp usbOutLoop
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
     ldi r19, $fD
     wasteLoop2:
       inc r19
     brne wasteLoop2
     out $1a, r16 ; tristate outputs
     sbi $12, 0
ret
