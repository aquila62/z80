; lfsr.asm - Linear Feedback Shift Register Generator  Version 1.0.0
; Copyright (C) 2016 aquila62 at github.com

; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License as
; published by the Free Software Foundation; either version 2 of
; the License, or (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program; if not, write to:

   ; Free Software Foundation, Inc.
   ; 59 Temple Place - Suite 330
   ; Boston, MA 02111-1307, USA.

;--------------------------------------------------------------
; This program prints the output of a linear feedback shift
; register.  The output from each LFSR cycle is a zero or one
; bit translated into ASCII '0' or '1'.
; The LFSR in this program is 16 bits.  Therefore the period
; length of this LFSR is 65535, or (2^16)-1.
;
; This LFSR comes from the following website
; http://www.xilinx.com/support/documentation/
; application_notes/xapp052.pdf
;
; The seed for this LFSR is any non-zero 16-bit random number.
; This program prompts for each byte of the seed.
; The prompt is a question mark.  You reply by entering a key
; from the keyboard, and that key is echoed back to you.
; Upon receiving the seed from the keyboard, the program
; generates one cycle at a time, followed by a pause.  Press
; any key to print the next cycle, and so on.
; To quit the program, press 'q' during the pause.
;--------------------------------------------------------------

kcin:  equ 0006h       ; CP/M jump vector for key input
kcout: equ 0009h       ; CP/M jump vector for console output
   org 100h            ; CP/M loads the program at 100h
   jp strt             ; bypass data area
seed:  dw 0,0          ; LFSR seed
state: dw 0,0          ; LFSR state during each cycle
; out = bit1 ^ bit2 ^ bit3 ^ bit4
out:   db 0,0,0,0      ; boolean output from one cycle
bit1:  db 0            ; bit 12 of LFSR
bit2:  db 0            ; bit  3 of LFSR
bit3:  db 0            ; bit  1 of LFSR
bit4:  db 0            ; bit  0 of LFSR
; translate table for printing a nybble in hex
hxtbl:  db '0123456789ABCDEF'
seedp:  db 'Enter seed: ',0
strt:                  ; program starts here
   call getsd          ; prompt for seed, read seed
   ;---------------------------------------------
   ; copy seed to state
   ;---------------------------------------------
   ld a,(seed)
   ld (state),a
   ld a,(seed+1)
   ld (state+1),a
   ;---------------------------------------------
   ; main program loop, one iteration for each
   ; cycle of the LFSR
   ;---------------------------------------------
lp:
   ;---------------------------------------------
   ; Copy 4 bits from the LFSR
   ; These 4 bits will be xor'd together to
   ; create the output from the LFSR cycle
   ; The state is shifted one bit to the right.
   ; The output bit is or'd into the high order
   ; bit of the state.
   ;---------------------------------------------
   ld a,(state+1)      ; load bit 12 of the state
   and 010h            ; is bit 12 on?
   jp z,.zro1          ; no, bit1 = 0
   ld a,1              ; yes, bit1 = 1
   ld (bit1),a
   jp .bt1
.zro1:
   xor a               ; bit1 = 0
   ld (bit1),a
.bt1:
   ld a,(state)        ; load bit 3 of the state
   and 08h             ; is bit 3 on?
   jp z,.zro2          ; no, bit2 = 0
   ld a,1              ; yes, bit2 = 1
   ld (bit2),a
   jp .bt2
.zro2:
   xor a               ; bit2 = 0
   ld (bit2),a
.bt2:
   ld a,(state)        ; load bit 1 of the state
   and 02h             ; is bit 1 on?
   jp z,.zro3          ; no, bit3 = 0
   ld a,1              ; yes, bit3 = 1
   ld (bit3),a
   jp .bt3
.zro3:
   xor a               ; bit3 = 0
   ld (bit3),a
.bt3:
   ld a,(state)        ; load bit 0 of the state
   and 01h             ; is bit 0 on?
   jp z,.zro4          ; no, bit4 = 0
   ld a,1              ; yes, bit4 = 1
   ld (bit4),a
   jp .bt4
.zro4:
   xor a               ; bit4 = 0
   ld (bit4),a
.bt4:
   ;---------------------------------------------
   ; xor the 4 bits from the LFSR
   ; Those 4 bits of the LFSR are:  12,3,1,0
   ;---------------------------------------------
   ld a,(bit1)
   ld b,a
   ld a,(bit2)
   xor b
   ld b,a
   ld a,(bit3)
   xor b
   ld b,a
   ld a,(bit4)
   xor b
   and a,1
   ld (out),a         ; save the xor result in "out"
   ;-----------------------------------
   ; print the output of the LFSR cycle
   ;-----------------------------------
   call putbit
   ;-----------------------------------
   ; pause for a keyboard entry
   ;-----------------------------------
   call cin
   cp 'q'         ; if 'q' is entered
   jp z,eoj       ; quit
   cp 01ah        ; if CTL-Z is entered
   jp z,eoj       ; quit
   ;---------------------------------------------
   ; Shift the 16-bit state one bit to the right
   ;---------------------------------------------
   ld a,(state+1)
   srl a
   ld (state+1),a
   ld a,(state)
   rr a
   ld (state),a
   ;---------------------------------------------
   ; "or" the output bit from the LFSR into the
   ; high order bit of the state.
   ;---------------------------------------------
   ld a,(out)
   and 1
   jp z,.byp
   ld a,(state+1)
   or 080h
   ld (state+1),a
.byp:
   jp lp           ; repeat the main loop
   ;---------------------------------------------
   ; end of job
   ; Jump to address zero to reset CP/M
   ;---------------------------------------------
eoj:
   jp 0h
   nop
   nop
   nop
   nop
   ;---------------------------------------------
   ; Prompt for seed
   ; Read seed from keyboard
   ;---------------------------------------------
getsd:
   push af
   push bc
   push hl
   ld hl,seedp
.sd2:
   ld a,(hl)
   or a
   jp z,.sd3
   call cout
   inc hl
   jp .sd2
.sd3:
   call cin
   cp 01ah
   jp z,eoj
   ld (seed),a
   call cout
   call cin
   cp 01ah
   jp z,eoj
   ld (seed+1),a
   call cout
   call puteol
   pop hl
   pop bc
   pop af
   ret
   ;---------------------------------------------
   ; Translate a bit to ASCII and print to the
   ; console.
   ;---------------------------------------------
putbit:
   push af
   add a,030h
   call cout
   pop af
   ret
   ;---------------------------------------------
   ; print one space
   ;---------------------------------------------
putspc:
   push af
   ld a,020h
   call cout
   pop af
   ret
   ;---------------------------------------------
   ; Convert a byte to hex and print it
   ; to the console.
   ; Then print one space.
   ;---------------------------------------------
puthexa:
   call puthex
   call putspc
   ret
   ;---------------------------------------------
   ; Print the BC register in hex
   ;---------------------------------------------
putbc:
   push af
   ld a,b
   call puthex
   ld a,c
   call puthex
   call putspc
   pop af
   ret
   ;---------------------------------------------
   ; Print the HL register in hex
   ;---------------------------------------------
puthl:
   push af
   ld a,h
   call puthex
   ld a,l
   call puthex
   call putspc
   pop af
   ret
   ;---------------------------------------------
   ; Print one byte in hex
   ;---------------------------------------------
puthex:
   push af
   push bc
   ld b,a
   srl a
   srl a
   srl a
   srl a
   call putnbl
   ld a,b
   and 0fh
   call putnbl
   pop bc
   pop af
   ret
   ;---------------------------------------------
   ; Print 4 bits in hex
   ; A half byte is called a nybble
   ;---------------------------------------------
putnbl:
   push af
   push bc
   push hl
   ld b,0
   ld c,a
   ld hl,hxtbl
   add hl,bc
   ld a,(hl)
   call cout
   pop hl
   pop bc
   pop af
   ret
   ;---------------------------------------------
   ; Print end of line sequence
   ; end of line in CP/M is CR and LF
   ;---------------------------------------------
puteol:
   push af
   ld a,13
   call cout
   ld a,10
   call cout
   pop af
   ret
   ;---------------------------------------------
   ; Read one byte from the keyboard
   ;---------------------------------------------
cin:
   push bc
   push de
   push hl
   ld de,kcin
   call ios
   pop hl
   pop de
   pop bc
   ; returns character in reg a
   ret
   ;---------------------------------------------
   ; Print one ASCII byte to the console
   ;---------------------------------------------
cout:
   push bc
   push de
   push hl
   ld c,a
   ld de,kcout
   call ios
   pop hl
   pop de
   pop bc
   ret
   ;---------------------------------------------
   ; CP/M input/output service routine
   ;---------------------------------------------
ios:
   ld hl,(01h)
   add hl,de
   jp (hl)
