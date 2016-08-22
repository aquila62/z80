; hx.asm - Print memory in hex   Version 1.0.0
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

; Usage:

; hx address

; where address is in hex

; Example:

; hx 0100

kcin:  equ 0006h
kcout: equ 0009h
   org 100h
   xor a,a
   ld (kount),a
   call getparm
lp:
   ld hl,(addr)
   call puthl
lp2:
   ld a,(hl)
   call puthexa
   inc hl
   ld (addr),hl
   ld a,(kount)
   inc a
   ld (kount),a
   cp 16
   jp m,lp2
   call puteol
   xor a
   ld (kount),a
   call cin
   cp 01ah
   jp z,eoj
   jp lp
eoj:
   jp 0h
   nop
   nop
   nop
   nop
getparm:
   push af
   push bc
   push hl
   xor a,a
   ld h,a
   ld l,a
   ld (addr),hl
   ld a,(080h)
   dec a
   ld (len),a
   add a,081h
   ld (endprm),a
   ld hl,081h
   ld (prmch),hl
byp1:
   ld hl,(prmch)
   ld a,(hl)
   cp 020h
   jp nz,prm2
   inc hl
   ld (prmch),hl
   jp byp1
prm2:
   ld hl,(prmch)
   ld a,(hl)
   cp 0
   jp z,prm3
   cp 020h
   jp z,prm3
   call hx2bin
   ld bc,(addr)
   sla c
   rl  b
   sla c
   rl  b
   sla c
   rl  b
   sla c
   rl  b
   ld (addr),bc
   ld a,(bindgt)
   ld c,a
   ld b,0h
   ld hl,(addr)
   add hl,bc
   ld (addr),hl
   ld hl,(prmch)
   inc hl
   ld (prmch),hl
   ld a,(ofst)
   inc a
   ld (ofst),a
   jp prm2
prm3:
   pop hl
   pop bc
   pop af
   ret
hx2bin:           ; output in bindgt
   push af
   push hl
   cp 030h
   jp m,badhx
   cp 067h
   jp p,badhx
   cp 061h
   jp m,hx2bin2
   sub a,0x20
hx2bin2:
   cp 047h
   jp p,badhx
   cp 041h
   jp m,hx2bin3
   sub a,07h
hx2bin3:
   cp 040h
   jp p,badhx
   sub 030h
   ld hl,bintbl
   ld c,a
   ld b,0
   add hl,bc
   ld a,(hl)
   ld (bindgt),a
   pop hl
   pop af
   ret
badhx:
   pop hl
   pop af
   call cout
   call putspc
   ld a,'?'
   call cout
   jp eoj
puthexa:
   call puthex
   call putspc
   ret
putbc:
   push af
   ld a,b
   call puthex
   ld a,c
   call puthex
   call putspc
   pop af
   ret
puthl:
   push af
   ld a,h
   call puthex
   ld a,l
   call puthex
   call putspc
   pop af
   ret
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
puteol:
   push af
   ld a,13
   call cout
   ld a,10
   call cout
   pop af
   ret
putspc:
   push af
   ld a,020h
   call cout
   pop af
   ret
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
ios:
   ld hl,(01h)
   add hl,de
   jp (hl)
   nop
   nop
   nop
   nop
addr:   dw 0
prmch:  dw 0
endprm: dw 0
bindgt: db 0,0
kount:  db 0,0
hxtbl:  db '0123456789ABCDEF'
bintbl: db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
len:    db 0,0
ofst:   db 0,0
prmend: db 0,0
   nop
   nop
   nop
   nop
