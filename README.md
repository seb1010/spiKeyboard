# spiKeyboard
currently working (but only just :) )

## Bugs
* I think there is a issue with a register not being pushed and being used else where, but I have not tracked it down yet

## Overview
This device enumerates as a keyboard over low speed usb, but it has a UART interface (yes it is poorly named). It is set to 600 baud, but in theory higher rates are possible. It is designed to transfer data from dataloging devices directly into a spreadsheet without any software required on the host side. Based on a ATTINY44 running on 12 MHz

## Use Case
This is intended for people like me who don't know any software, but still want to be able to collect data from custom devices
A subroutine to send uart packets is trivial to write, so this device allows any microcontroller to easily send data directly to a file on a pc

## Files
I need to update this and orgainze the files in a reasonable way
* Main.asm this has the interrupt vectors and calls the other functions
* usbDataIn.asm 
** contains the ISRs for pin change on usb pins
** handles all data collection
** also automatically sends nak packet depending on the state of a byte in sram
* 
* debugFunctions.asm I can likely drop this one at this point

## SRAM Map
* I need to add this at some point
* Due this being a project that I spent a few days or weeks on at a time over the span of many years the SRAM is a total mess
* Luckily the micro I chose had tonns of SRAM (256 Bytes) so even with my very inefficient code there is plent spare


## Operation
### TL;DR of HID enumeration
* Host "plz send device descriptor"
* Client "Here you go"
* Host "please reset yourself"
* Host "please send device descriptor
* Client "Here you go"
* Host "Please send configuration descriptor"
* Client "here you go" (but also send interface and endpoint descriptors also report descriptors)


### Challenges
This all seems very simple, the main issues I ran into is things are not well documented. The spec is hundreds of pages long plus there is the HID spec, but it's just not that helpful for someone who doesn't understand how usb works
* There are all sorts of random questions that the host askes, that don't have obvious answers
* There is a max bus turn around time of 7.5 bit times. 
** This doesn't give me very any cycles to figure out the correct response load of the output buffer and send out the data
* I had a hell of a time figuring out the CRC calculations
** The therory is simple enough, but actually implemeting it was not easy for me. There are random details like preloading the registers will all 1s and such that took we a while to figure out


## Background
This is a project I have been working on for many years. I first got subroutines to read and write USB packets in maybe 2019. Then in college I wrote the subroutines to calculate the CRCs and do bit stuffing. Finaally as an old man I sorted out the usb protocal enough to get this working on at least one computer. As you can see I very much stuggled with this project.
