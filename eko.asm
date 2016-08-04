; eko.asm - Echo ASCII keyboard characters   Version 1.0.0
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

kcin:  equ 0006h
kcout: equ 0009h
   org 100h
lp:
   call cin
   cp 01ah
   jp z,eoj
   call cout
   jp lp
eoj:
   jp 0h
   nop
   nop
   nop
   nop
cin:
   push bc
   push de
   ld de,kcin
   call ios
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
