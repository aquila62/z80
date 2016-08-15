; typ.asm - Print a text file to the console   Version 1.0.0
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

; This program was inspired by the Digital Research sample
; file copy program
;
; text file browser program
;
; at the ccp level, the command usage:
;
; typ a:x.y
;
; Example:
;
; typ typ.asm
;
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
	ld sp,stack+127    ; set local stack
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
	; this logic doesn't get exercised
	; because the putblk routine looks for a CTL-Z
	cp 0h              ; end of file?
	jp nz,boot         ; reboot CP/M
;
; not end of file, print the record to the console
;
	call putblk
	jp copy            ; loop until eof
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
; print one record to the console
; the record buffer is at 080h
;
putblk:
	push af
	push bc
	push hl
	ld hl,80h           ; address of buffer
	ld c,80h            ; length of buffer
putblk2:
	ld a,(hl)           ; get current character in buffer
	inc hl              ; point to next character
	cp 01ah             ; is the character CTL-Z
	jp z,putblk3        ; yes go to end of job
	cp 0ah              ; is the character UNIX eol
	jp nz,putblk4       ; no, print character to console
	call puteol         ; yes, print a CP/M end of line sequence
	call cin            ; pause at end of line
	cp 01ah             ; did you type CTL-Z
	jp nz,putblk5       ; no, continue
	jp boot             ; yes, end of job, reboot CP/M
putblk4:
	call cout           ; print a character to the console
putblk5:
	dec c               ; decrement block counter
	ld a,c              ; compare from the A register
	or a                ; test for end of block
	jp nz,putblk2       ; not end of block, print next character
	pop hl              ; end of block, return
	pop bc
	pop af
	ret
putblk3:                    ; end of file
	pop hl              ; reboot CP/M
	pop bc
	pop af
	jp boot
;
; memory dump
;
hxmem:
	push af
	push bc
	push de
	push hl
	ld d,0
	ld e,16
hxmem2:
	ld a,(hl)
	call puthexa
	inc hl
	dec bc
	ld a,c
	cp 0
	jp nz,hxmem3
	ld a,b
	cp 0
	jp nz,hxmem3
	jp hxmem4
hxmem3:
	dec e
	ld a,e
	cp 0
	jp nz,hxmem2
	call puteol
	ld e,16
	jp hxmem2
hxmem4:
	call puteol
	pop hl
	pop de
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
stack:
	ds 128                 ; 64 level stack
	end
