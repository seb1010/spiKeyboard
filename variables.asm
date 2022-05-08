;
; This page contains user defined variables
;
; These are specific to this program
;
;
;############### Start Variables ###################

.define usbDataReceived ; set 1 by usbDataIn

.define descriptorIndexHigh $0116
.define descriptorIndexLow  $0117

.define packetReady $0118

.define numConfigBytesSent $011c
.define usbIn $012c
.define numBitsOutAS, $0151
.define clockSync $0152
.define PidOut $0153
.define stackStart $0100
.define numBitsOutBS $0145

.define usbDataOutBS $0146

.define numBitsOutAS $0151

.define crcOut $0129

.define crc5Data $0127
.define crc5Length $0126
.define crc16Length $011E
.define crc16Data $011F

.define BmPrevious $0119
; This address is a mess and also critical
; 0000 -> reserved ; 0001 -> Data2 ; 0010 -> Data1 ; 0011 -> Data0
; 0100 -> Setup  0101 ->  0110 -> 0111 ->
; 

