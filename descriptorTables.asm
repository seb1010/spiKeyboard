deviceDescriptor:
.dw $0112  ; 18 bytes, device descriptor
.dw $0110  ; usb 1.1
.dw $0000  ; device class and subclass
.dw $0800  ; max packet size
.dw $1a2c  ; vendor id
.dw $2124  ; product id
.dw $0110  ; release number
.dw $0000  ; index of manufacture and product string
.dw $0100  ; index of serial number and number of configurations


configurationDescriptor:
.dw $0209 ; length of 9 bytes, configuration descriptor
.dw $003B ; total length 22 bytes
.dw $0102 ; configuration value and number of interfaces
.dw $A000 ; index of string descriptor bm of config charactoristics
.dw $0932 ; max power 100 mA
;interfaceDescriptor 0

.dw $0900 ; descriptor length, descriptor type
.dw $ ; interface number, alternate setting
.dw $ ; number of endpoints, interface class HID
.dw $ ; subclass (keyboard), protocol (boot)
.dw $ ; index of string descriptor
;HidDescriptor 0
.dw $2109  ; length and descriptor type
.dw $0110   ; bcd hid
.dw $0100  ; country code and number of descriptors
.dw $3622  ; report type, total length of report
.dw $0000  ; 


endPointDescriptor:
.dw $0507 ; length, descriptor type
.dw $0381 ; endpoint 1 in, interrupt type endpoint
.dw $0800 ; max packet size
.dw $000A ; b interval

reportDescriptor0:
.dw $0105   ; usage page
.dw $0609   ; keyboard
.dw $01a1
.dw $0805

.dw $0119
.dw $0329
.dw $0015
.dw $0125

.dw $0175
.dw $0395
.dw $0291
.dw $0595

.dw $0191
.dw $0705
.dw $0e19
.dw $e729

.dw $0895
.dw $0875
.dw $0195
.dw $0181

.dw $0181
.dw $0019
.dw $9129
.dw $ff26

.dw $9500
.dw $8106
.dw $c000


reportDescriptor1:
.dw $0c05
.dw $0109
.dw $011a
.dw $0185

.dw $1502
.dw $2600
.dw $02c3
.dw $0195

.dw $1075
.dw $0081
.dw $05c0
.dw $0901

.dw $a180
.dw $8501
.dw $1902
.dw $2981

.dw $2583
.dw $7501
.dw $9501
.dw $8103

.dw $9502
.dw $8105
.dw $c001

