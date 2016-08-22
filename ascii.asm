; ascii.asm - Print ASCII characters in sequence  Version 1.0.0
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
; This program prints the ASCII character set
; with 16 characters per line.
; From this output it is possible to determine the
; hex code for each character.
; The first line starts at hex 020h.
;--------------------------------------------------------------

kcin:  equ 0006h       ; CP/M branch vector for keyboard input
kcout: equ 0009h       ; CP/M branch vector for console  output
   org 100h            ; CP/M start address
   ;-----------------------------------------------------------
   ; Initialize kount to zero
   ; kount is used to determine end of line
   ;-----------------------------------------------------------
   xor a,a
   ld (kount),a
   ;-----------------------------------------------------------
   ; Start ASCII print out at space
   ; bindgt contains the ASCII character to print
   ;-----------------------------------------------------------
   ld a,020h
   ld (bindgt),a
lp:                         ; ASCII character loop
   ld a,(bindgt)            ; load current character in A
   cp 128                   ; test for end of ASCII alphabet
   jp p,eoj                 ; if end of alphabet, stop run
   call cout                ; print current character
   call putspc              ; print one space
   ;----------------------------------------------------
   ; point to next ASCII character
   ;----------------------------------------------------
   inc a
   ld (bindgt),a
   ;----------------------------------------------------
   ; increment kount
   ; if kount == 16, print end of line sequence
   ; otherwise repeat loop
   ;----------------------------------------------------
   ld a,(kount)
   inc a
   ld (kount),a
   cp 16
   jp m,lp
   xor a,a
   ld (kount),a
   call puteol
   jp lp
eoj:                       ; end of job
   jp 0h                   ; reset CP/M
   nop
   nop
   nop
   nop
;----------------------------------------------------------
; print A register in hexadecimal
;----------------------------------------------------------
puthexa:
   call puthex
   call putspc
   ret
;----------------------------------------------------------
; print BC register in hexadecimal
;----------------------------------------------------------
putbc:
   push af
   ld a,b
   call puthex
   ld a,c
   call puthex
   call putspc
   pop af
   ret
;----------------------------------------------------------
; print HL register in hexadecimal
;----------------------------------------------------------
puthl:
   push af
   ld a,h
   call puthex
   ld a,l
   call puthex
   call putspc
   pop af
   ret
;----------------------------------------------------------
; print A register in hexadecimal
;----------------------------------------------------------
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
;----------------------------------------------------------
; print 4-bit nibble in hexadecimal
;----------------------------------------------------------
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
;----------------------------------------------------------
; print \r\n end of line sequence
;----------------------------------------------------------
puteol:
   push af
   ld a,13
   call cout
   ld a,10
   call cout
   pop af
   ret
;----------------------------------------------------------
; print one space
;----------------------------------------------------------
putspc:
   push af
   ld a,020h
   call cout
   pop af
   ret
;----------------------------------------------------------
; read keyboard with wait, without echo
;----------------------------------------------------------
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
;----------------------------------------------------------
; print A register in ASCII to console
;----------------------------------------------------------
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
;----------------------------------------------------------
; CP/M input/output branch vector
; return address is on stack
; returns to caller of cin or cout
;----------------------------------------------------------
ios:
   ld hl,(01h)
   add hl,de
   jp (hl)
   nop
   nop
   nop
   nop
bindgt: db 0,0          ; current ASCII character
kount:  db 0,0          ; count for end of line
hxtbl:  db '0123456789ABCDEF'      ; hex translate table
   nop
   nop
   nop
   nop
