; hxdmp.asm - Dump a file in hex and ASCII   Version 1.0.0
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

;---------------------------------------------------------
; This program was inspired by the Digital Research sample
; file copy program
;
; Dump a file in hex and ASCII
;
; at the ccp level, the command usage:
;
; hxdmp a:x.y
;
; Example:
;
; hxdmp hx.com
;
; The program pauses after every 8 lines of output
;
; press CTL-Z to quit
;---------------------------------------------------------

kcin:   equ 0006h     ; keyboard input routine
kcout:  equ 0009h     ; console output routine
boot:   equ 0000h     ; system reboot
bdos:   equ 0005h     ; bdos entry point
fcb1:   equ 005ch     ; first file name
sfcb:   equ fcb1      ; source fcb
dbuff:  equ 0080h     ; default buffer
tpa:    equ 0100h     ; beginning of tpa transient program area
;
printf: equ 9         ; print buffer func#
openf:  equ 15        ; open file func#
closef: equ 16        ; close file func#
deletef: equ 19       ; delete file func#
readf:  equ 20        ; sequential read func#
writef: equ 21        ; sequential write func#
makef:  equ 22        ; make file func#  (create file)
;
	org tpa            ; beginning of tpa
	ld sp,stack+126    ; set local stack
;
; source fcb is ready
;
	ld de,sfcb         ; source file
	call open          ; error if 255
	ld de,nofile       ; ready message
	inc a              ; 255 becomes 0
	cp 0h
	jp z,finis         ; done if no file
;
; source file open
; copy until end of file on source
; end of file is an 01ah character in the text
;
copy:
	ld de,sfcb         ; source
	call read          ; read next record
	cp 0h              ; end of file?
	jp nz,boot         ; reboot CP/M
;
; not end of file, dump the record with 8 lines of hex
;
	call dmp
	call cin
	cp 01ah
	jp nz,copy
	jp boot
;
; write message given in de, reboot
;
finis:
	ld c,printf
	call bdos          ; write message
	jp boot            ; reboot system
;
; system interface subroutines
; (all return directly from bdos)
;
open:
	ld c,openf
	jp bdos
;
close:
	ld c,closef
	jp bdos
;
delete:
	ld c,deletef
	jp bdos
;
read:
	ld c,readf
	jp bdos
;
write:
	ld c,writef
	jp bdos
;
make:
	ld c,makef
	jp bdos
;
; dump 8 lines in hex
;
dmp:
	push af
	push bc
	push hl
	ld c,8
	ld hl,dbuff
dmp2:
	call hxmem
	ld a,l
	add 16
	ld l,a
	dec c
	ld a,c
	cp 0h
	jp nz,dmp2
	pop hl
	pop bc
	pop af
	ret
;
; memory dump   hl=addr to dump
;
hxmem:
	push af
	push bc
	push hl
	ld (addr),hl
	call putofst
	ld c,16
hxmem2:
	ld a,(hl)
	inc hl
	call puthex
	dec c
	ld a,c
	cp 12
	jp nz,hxmem6
	call putspc
	jp hxmem2
hxmem6:
	cp 8
	jp nz,hxmem7
	call putspc
	call putspc
	jp hxmem2
hxmem7:
	cp 4
	jp nz,hxmem8
	call putspc
	jp hxmem2
hxmem8:
	cp 0
	jp nz,hxmem2
	call putspc
	call putspc
	call putast         ; print *
	ld hl,(addr)
	ld c,16
hxmem3:
	; print only 020h to 07eh in ASCII
	ld a,(hl)
	inc hl
	cp 020h
	jp m,hxmem4
	cp 07fh
	jp p,hxmem4
	call cout
	jp hxmem5
hxmem4:
	call putspc     ; otherwise print space
hxmem5:
	dec c
	ld a,c
	cp 0h
	jp nz,hxmem3
	call putast
	call puteol
	pop hl
	pop bc
	pop af
	ret
;
; print offset in file in hex big endian format
;
putofst:
	push af
	push bc
	push hl
	ld hl,ofst+2
	ld c,3
putofst2:
	ld a,(hl)
	call puthex
	dec hl
	dec c
	ld a,c
	cp 0
	jp nz,putofst2
	call putspc
	call putspc
	; add 16 to offset in little endian format
	ld hl,ofst
	ld a,(hl)
	add 16
	ld (hl),a
	jp nc,putofst3
	inc hl
	ld a,(hl)
	adc a,0
	ld (hl),a
	jp nc,putofst3
	inc hl
	ld a,(hl)
	adc a,0
	ld (hl),a
putofst3:
	pop hl
	pop bc
	pop af
	ret
;
; print A register in hex
;
puthexa:
   call puthex
   call putspc
   ret
;
; print BC register in hex
;
putbc:
   push af
   ld a,b
   call puthex
   ld a,c
   call puthex
   call putspc
   pop af
   ret
;
; print HL register in hex
;
puthl:
   push af
   ld a,h
   call puthex
   ld a,l
   call puthex
   call putspc
   pop af
   ret
;
; print A register in hex without trailing space
;
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
;
; print A register nibble in hex
;
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
;
; print \r (0dh)
;
putret:
   push af
   ld a,13
   call cout
   pop af
   ret
;
; print \r\n (0dh 0ah)  end of line in CP/M
;
puteol:
   push af
   ld a,13
   call cout
   ld a,10
   call cout
   pop af
   ret
;
; print one space
;
putspc:
   push af
   ld a,020h
   call cout
   pop af
   ret
;
; print asterisk
;
putast:
   push af
   ld a,'*'
   call cout
   pop af
   ret
;
; read one character from keyboard with wait
;
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
;
; print one character to console
;
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
;
; interface to CP/M i/o routines
;
ios:
   ld hl,(01h)
   add hl,de
   jp (hl)
;
; console messages
;
nofile:
	db 'File not found.$'
	db 0
hxtbl:  db '0123456789ABCDEF'
	db 0,0,0,0
;
; data areas
;
addr:	dw 0,0
ofst:	dw 0,0,0,0
stack:
	ds 128                 ; 64 level stack
	end
