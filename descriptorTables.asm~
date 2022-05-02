deviceDescriptor:
.dw $0112  ; 18 bytes, device descriptor
.dw $0002  ; usb 2.0
.dw $0000  ; device class and subclass
.dw $0800  ; max packet size
.dw $6d80  ; vendor id
.dw $80c8  ; product id
.dw $0368  ; release number
.dw $0402  ; index of manufacture and product string
.dw $0100  ; index of serial number and number of configurations


configurationDescriptor:
.dw $0209 ; length of 9 bytes, configuration descriptor
.dw $0022 ; total length 22 bytes
.dw $0101 ; configuration value and number of interfaces
.dw $A000 ; index of string descriptor bm of config charactoristics
.dw $3200 ; max power 100 mA

interfaceDescriptor:
.dw $0309 ; descriptor length, descriptor type
.dw $0000 ; interface number, alternate setting
.dw $0301 ; number of endpoints, interface class HID
.dw $0101 ; subclass (keyboard), protocol (boot)
.dw $0000 ; index of string descriptor

endPointDescriptor:
.dw $0507 ; length, descriptor type
.dw $0381 ; endpoint 1 in, interrupt type endpoint
.dw $0800 ; max packet size
.dw $000A ; b interval

HidDescriptor:
.dw $2109  ; length and descriptor type
.dw $0101   ; bcd hid
.dw $0100  ; country code and number of descriptors
.dw $3F22  ; report type, total length of report
.dw $0000  ; 

reportDescriptor:
.dw $0105   ; usage page
.dw $0906   ; keyboard
.dw $01a1
.dw $0705

.dw $e019
.dw $e729
.dw $0015
.dw $0125

.dw $0175
.dw $0895
.dw $0281
.dw $0195

.dw $0875
.dw $0181
.dw $0595
.dw $0175

.dw $0805
.dw $0119
.dw $0529
.dw $0291

.dw $0195
.dw $0375
.dw $0191
.dw $0695

.dw $0875
.dw $0015
.dw $6525
.dw $0705

.dw $0019
.dw $6529
.dw $0081
.dw $C000


