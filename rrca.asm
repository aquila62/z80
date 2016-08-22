; rrca.asm - Test rotate left with carry   Version 1.0.0
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

;------------------------------------------------------------
; This program illustrates the rrca instruction
; For each iteration of the loop, the one bit in register A
; shifts one bit to the right.
;------------------------------------------------------------

kcin:  equ 0006h         ; CP/M branch vector for keyboard input
kcout: equ 0009h         ; CP/M branch vector for console  output
   org 100h              ; CP/M start address
   ld a,080h             ; initialize the A register
   ld (accumulator),a    ; save A in memory
lp:                          ; loop based on keyboard input
   ld a,(accumulator)        ; last state of A register
   call puthexa              ; print A register in hex
   rrca                      ; rotate A to the right with carry
   ld (accumulator),a        ; save the A register state
   call cin                  ; pause for keyboard input
   cp 01ah                   ; CTL-Z goes to end of job
   jp z,eoj
   jp lp                     ; repeat loop
eoj:                         ; end of job
   jp 0h                     ; reset CP/M
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
accumulator: db 0,0                  ; save area for A register
hxtbl:  db '0123456789ABCDEF'        ; hex translate table
   nop
   nop
   nop
   nop
