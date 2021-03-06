.device attiny45

.include "definitions.asm"


reset:
sbi $1a, 2

ldi r16, high(deviceDescriptor)
sts descriptorIndexHigh, r16

ldi r16, low(deviceDescriptor)
sts descriptorIndexLow, r16


resetLoop:
clr r16
sts numConfigBytesSent, r16

rcall loadDescriptor
rcall usbDataOutOnUart
rcall plzWait
rcall plzWait

rcall loadDescriptor
rcall usbDataOutOnUart
rcall plzWait
rcall plzWait

rcall loadDescriptor
rcall usbDataOutOnUart
rcall plzWait
rcall plzWait


rjmp resetLoop

.include "uart9600.asm"

loadDescriptor:
  push r16
  push r18
  push r28
  push r29
  push r30
  push r31

  ldi r29, high(usbIn)
  ldi r28, low(usbIn)

  lds r30, descriptorIndexLow
  lds r31, descriptorIndexHigh
  lsl r30
  rol r31      ; multiply by 2

  lpm r18, z

  lds r16, numConfigBytesSent
  add r30, r16
  ldi r16, $00
  adc r31, r16
 
  sub r18, r16
  cpi r18, $08
  brlo noClearBitsLpm
    ldi r18, $08
  noClearBitsLpm:
ldi r18, $08
 
  lds r16, numConfigBytesSent
  add r16, r18
  sts numConfigBytesSent, r16    ; updating for next time
  
 
  loadDescriptorLoop:
    cpi r18, $00
    breq endLoadDescriptorLoop
    lpm r16, z+
    st y+, r16

    dec r18
  rjmp loadDescriptorLoop
  endLoadDescriptorLoop:

  

  pop r31
  pop r30
  pop r29
  pop r28
  pop r18
  pop r16
ret

plzWait:
push r16
push r17
push r18
clr r16
clr r17
ldi r18, $00
waitLoop:
inc r16
brne waitLoop
inc r17
brne waitLoop
inc r18
brne waitLoop
pop r18
pop r17
pop r16
ret


.include "descriptorTables.asm"

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
nop
nop
nop
