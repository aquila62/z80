; tower.asm - Tower of Hanoi  Version 1.0.0
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
; This program performs the iterative solution for the Tower
; of Hanoi computer puzzle.
;
; The source tower A has 2-9 disks.
; The target tower is tower C.
; Tower B is the auxiliary tower.
;
; Usage:
;
; tower [n]
;
; Where n is the number of disks, 2-9
; Default is three disks.
;
; The object of this program is to move all the disks
; on stack A to stack C.
; See Wikipedia for the rules about the Tower of Hanoi.
; This program implements the iterative solution to the problem.
;--------------------------------------------------------------

kcin:  equ 0006h       ; CP/M jump vector for key input
kcout: equ 0009h       ; CP/M jump vector for console output
   org 100h            ; CP/M loads program into TPA at 100h
   jp strt             ; bypass data area
num:    dw 0,0         ; number to print in decimal
stkadr: dw 0,0         ; current pointer in stack
stksz:  db 9,0,0,0     ; maximum number of disks in the stack
stka:   db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; source stack
stkb:   db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; auxiliary stack
stkc:   db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; target stack
sza:    db 9,0         ; index to stack A
szb:    db 0,0         ; index to stack B
szc:    db 0,0         ; index to stack C
popdsk: db 0,0         ; output of the pop routines
srcdsk: db 0,0         ; source disk to be moved
tgtdsk: db 0,0         ; top disk on target stack 
retcd:  db 0,0         ; return code 0=fail 1=success
kount:  dw 0,0         ; move counter
;-------------------- 8 bit division parameters
dvdnd:     dw 0,0      ; dividend
ten:       db 10,0     ; constant 10
divisor:   db 0,0
quotient:  dw 0,0
remainder: db 0,0,0,0
;---------------------------------------------------
; translate table for printing a 4-bit nybble in hex
;---------------------------------------------------
hxtbl:  db '0123456789ABCDEF'
; decimal numbers are printed from a stack 
stk: ds 16             ; decimal number stack
;---------------------------------------------------
strt:                  ; program starts here
   ; initialize the move counter to zero
   xor a
   ld (kount),a
   ld (kount+1),a
   ;----------------------------------------------------
   call getparm        ; optional parm is number of disks
   call bld            ; fill the sieve array with odd numbers
   ;----------------------------------------------------
   ld a,(stksz)        ; is number of disks is even?
   cp 2
   jp z,main2          ; yes, move right
   cp 4
   jp z,main2          ; yes, move right
   cp 6
   jp z,main2          ; yes, move right
   cp 8
   jp z,main2          ; yes, move right
   call mvleft         ; no, move disks to left
   call shw            ; print final disk column
   jp eoj
main2:
   call mvrght         ; move disks to right
   call shw            ; print final disk column
;---------------------------------------------------
; end of job
; Jump to address zero to reset CP/M
;---------------------------------------------------
eoj:
   jp 0h
   nop
   nop
   nop
   nop
;---------------------------------------------
; populate stack A with n disks
; where n defaults to 3
; or n is the run parameter, 2-9
; stacks B and C are empty
;---------------------------------------------
bld:
   push af
   push bc
   push hl
   ; 9 is biggest, 2 is smallest
   ; source = stka, target = stkc, auxiliary = stkb
   ; runtime parameter determines how many disks
   ld hl,stka+1
   ld a,(stksz)
   ld (sza),a
bld2:
   ld (hl),a
   inc hl
   dec a
   or a
   jp nz,bld2
   call shw
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; move the disks to the left
; first move the one disk to the left
; then move another disk to an available pile
; total moves is 2^n - 1, where n is #disks
;-------------------------------------------------------
mvleft:
   push af
   push bc
   push hl
mvleft2:
   ld a,(sza)
   or a
   jp nz,mvleft2b
   ld a,(szb)
   or a
   jp z,mvleft9
mvleft2b:
   ld bc,(kount)
   inc bc
   ld (kount),bc
   call mv1ac
   ld a,(retcd)
   or a
   jp nz,mvleft3
   call mv1cb
   ld a,(retcd)
   or a
   jp nz,mvleft3
   call mv1ba
mvleft3:
   call putkount
   call shw
   call pause
   jp mvleft2
mvleft9:
   pop hl
   pop bc
   pop af
   ret
;---------------------------------------------
; move the disks to the right
; first move the one disk to the right
; then move another disk to an available pile
; total moves is 2^n - 1, where n is #disks
;---------------------------------------------
mvrght:
   push af
   push bc
   push hl
mvrght4:
   ld a,(sza)
   or a
   jp nz,mvrght4b
   ld a,(szb)
   or a
   jp z,mvrght9
mvrght4b:
   ld bc,(kount)
   inc bc
   ld (kount),bc
   call mv1ab
   ld a,(retcd)
   or a
   jp nz,mvrght5
   call mv1bc
   ld a,(retcd)
   or a
   jp nz,mvrght5
   call mv1ca
mvrght5:
   call putkount
   call shw
   call pause
   jp mvrght4
mvrght9:
   pop hl
   pop bc
   pop af
   ret
;---------------------------------------------
; move the 1 disk from stack A to stack B
;---------------------------------------------
mv1ab:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   ld (retcd),a
   ld hl,stka
   ld b,0
   ld a,(sza)
   or a
   jp z,mv1ab9
   ld c,a
   add hl,bc
   ld a,(hl)
   cp 1
   jp nz,mv1ab9
   ld (srcdsk),a
   call popa
   call pushb
   ld a,1
   ld (retcd),a
   call mvac
   ld a,(retcd)
   or a
   jp nz,mv1ab9
   call mvca
mv1ab9:
   pop hl
   pop bc
   pop af
   ret
;---------------------------------------------
; move the 1 disk from stack A to stack C
;---------------------------------------------
mv1ac:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   xor a
   ld (retcd),a
   ld hl,stka
   ld b,0
   ld a,(sza)
   or a
   jp z,mv1ac9
   ld c,a
   add hl,bc
   ld a,(hl)
   cp 1
   jp nz,mv1ac9
   ld (srcdsk),a
   call popa
   call pushc
   ld a,1
   ld (retcd),a
   ld a,(sza)
   or a
   jp nz,mv1ac3
   ld a,(szb)
   or a
   jp z,mv1ac9
mv1ac3:
   call mvab
   ld a,(retcd)
   or a
   jp nz,mv1ac9
   call mvba
mv1ac9:
   pop hl
   pop bc
   pop af
   ret
;---------------------------------------------
; move the 1 disk from stack B to stack A
;---------------------------------------------
mv1ba:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   xor a
   ld (retcd),a
   ld hl,stkb
   ld b,0
   ld a,(szb)
   or a
   jp z,mv1ba9
   ld c,a
   add hl,bc
   ld a,(hl)
   cp 1
   jp nz,mv1ba9
   ld (srcdsk),a
   call popb
   call pusha
   ld a,1
   ld (retcd),a
   call mvbc
   ld a,(retcd)
   or a
   jp nz,mv1ba9
   call mvcb
mv1ba9:
   pop hl
   pop bc
   pop af
   ret
;---------------------------------------------
; move the 1 disk from stack B to stack C
;---------------------------------------------
mv1bc:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   ld (retcd),a
   ld hl,stkb
   ld b,0
   ld a,(szb)
   or a
   jp z,mv1bc9
   ld c,a
   add hl,bc
   ld a,(hl)
   cp 1
   jp nz,mv1bc9
   ld (srcdsk),a
   call popb
   call pushc
   ld a,1
   ld (retcd),a
   ld a,(sza)
   or a
   jp nz,mv1bc3
   ld a,(szb)
   or a
   jp z,mv1bc9
mv1bc3:
   call mvba
   ld a,(retcd)
   or a
   jp nz,mv1bc9
   call mvab
mv1bc9:
   pop hl
   pop bc
   pop af
   ret
;---------------------------------------------
; move the 1 disk from stack C to stack A
;---------------------------------------------
mv1ca:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   xor a
   ld (retcd),a
   ld hl,stkc
   ld b,0
   ld a,(szc)
   or a
   jp z,mv1ca3
   ld c,a
   add hl,bc
   ld a,(hl)
   cp 1
   jp nz,mv1ca3
   ld (srcdsk),a
   call popc
   call pusha
   ld a,1
   ld (retcd),a
   call mvcb
   ld a,(retcd)
   or a
   jp nz,mv1ca3
   call mvbc
mv1ca3:
   pop hl
   pop bc
   pop af
   ret
;---------------------------------------------
; move the 1 disk from stack C to stack B
;---------------------------------------------
mv1cb:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   xor a
   ld (retcd),a
   ld hl,stkc
   ld b,0
   ld a,(szc)
   or a
   jp z,mv1cb3
   ld c,a
   add hl,bc
   ld a,(hl)
   cp 1
   jp nz,mv1cb3
   ld (srcdsk),a
   call popc
   call pushb
   ld a,1
   ld (retcd),a
   call mvac
   ld a,(retcd)
   or a
   jp nz,mv1cb3
   call mvca
mv1cb3:
   pop hl
   pop bc
   pop af
   ret
;------------------------------------------------
; move the alternate disk from stack A to stack B
;------------------------------------------------
mvab:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   ld (tgtdsk),a
   ld (retcd),a
   ld hl,stka
   ld b,0
   ld a,(sza)
   or a
   jp z,mvab3
   ld c,a
   add hl,bc
   ld a,(hl)
   or a
   jp z,mvab3
   ld (srcdsk),a
   ld hl,stkb
   ld b,0
   ld a,(szb)
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (tgtdsk),a
   ld a,(tgtdsk)
   or a
   jp z,mvab2
   ld b,a
   ld a,(srcdsk)
   cp b
   jp p,mvab3
mvab2:
   call popa
   ld a,(srcdsk)
   call pushb
   ld a,1
   ld (retcd),a
   ld bc,(kount)
   inc bc
   ld (kount),bc
mvab3:
   pop hl
   pop bc
   pop af
   ret
;------------------------------------------------
; move the alternate disk from stack A to stack C
;------------------------------------------------
mvac:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   ld (tgtdsk),a
   ld (retcd),a
   ld hl,stka
   ld b,0
   ld a,(sza)
   or a
   jp z,mvac3
   ld c,a
   add hl,bc
   ld a,(hl)
   or a
   jp z,mvac3
   ld (srcdsk),a
   ld hl,stkc
   ld b,0
   ld a,(szc)
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (tgtdsk),a
   ld a,(tgtdsk)
   or a
   jp z,mvac2
   ld b,a
   ld a,(srcdsk)
   cp b
   jp p,mvac3
mvac2:
   call popa
   ld a,(srcdsk)
   call pushc
   ld a,1
   ld (retcd),a
   ld bc,(kount)
   inc bc
   ld (kount),bc
mvac3:
   pop hl
   pop bc
   pop af
   ret
;------------------------------------------------
; move the alternate disk from stack B to stack A
;------------------------------------------------
mvba:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   ld (tgtdsk),a
   ld (retcd),a
   ld hl,stkb
   ld b,0
   ld a,(szb)
   or a
   jp z,mvba3
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (srcdsk),a
   ld hl,stka
   ld b,0
   ld a,(sza)
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (tgtdsk),a
   ld a,(tgtdsk)
   or a
   jp z,mvba2
   ld b,a
   ld a,(srcdsk)
   cp b
   jp p,mvba3
mvba2:
   call popb
   ld a,(srcdsk)
   call pusha
   ld a,1
   ld (retcd),a
   ld bc,(kount)
   inc bc
   ld (kount),bc
mvba3:
   pop hl
   pop bc
   pop af
   ret
;------------------------------------------------
; move the alternate disk from stack B to stack C
;------------------------------------------------
mvbc:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   ld (tgtdsk),a
   ld (retcd),a
   ld hl,stkb
   ld b,0
   ld a,(szb)
   or a
   jp z,mvbc3
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (srcdsk),a
   ld hl,stkc
   ld b,0
   ld a,(szc)
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (tgtdsk),a
   ld a,(tgtdsk)
   or a
   jp z,mvbc2
   ld b,a
   ld a,(srcdsk)
   cp b
   jp p,mvbc3
mvbc2:
   call popb
   ld a,(srcdsk)
   call pushc
   ld a,1
   ld (retcd),a
   ld bc,(kount)
   inc bc
   ld (kount),bc
mvbc3:
   pop hl
   pop bc
   pop af
   ret
;------------------------------------------------
; move the alternate disk from stack C to stack A
;------------------------------------------------
mvca:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   ld (tgtdsk),a
   ld (retcd),a
   ld hl,stkc
   ld b,0
   ld a,(szc)
   or a
   jp z,mvca3
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (srcdsk),a
   ld hl,stka
   ld b,0
   ld a,(sza)
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (tgtdsk),a
   ld a,(tgtdsk)
   or a
   jp z,mvca2
   ld b,a
   ld a,(srcdsk)
   cp b
   jp p,mvca3
mvca2:
   call popc
   ld a,(srcdsk)
   call pusha
   ld a,1
   ld (retcd),a
   ld bc,(kount)
   inc bc
   ld (kount),bc
mvca3:
   pop hl
   pop bc
   pop af
   ret
;------------------------------------------------
; move the alternate disk from stack C to stack B
;------------------------------------------------
mvcb:
   push af
   push bc
   push hl
   xor a
   ld (srcdsk),a
   ld (tgtdsk),a
   ld (retcd),a
   ld hl,stkc
   ld b,0
   ld a,(szc)
   or a
   jp z,mvcb3
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (srcdsk),a
   ld hl,stkb
   ld b,0
   ld a,(szb)
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (tgtdsk),a
   ld a,(tgtdsk)
   or a
   jp z,mvcb2
   ld b,a
   ld a,(srcdsk)
   cp b
   jp p,mvcb3
mvcb2:
   call popc
   ld a,(srcdsk)
   call pushb
   ld a,1
   ld (retcd),a
   ld bc,(kount)
   inc bc
   ld (kount),bc
mvcb3:
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; print 10 dashes in between states
;-------------------------------------------------------
putdash:
   push af
   push bc
   ld b,10
putdash2:
   ld a,'-'
   call cout
   djnz putdash2
   call puteol
   pop bc
   pop af
   ret
;-------------------------------------------------------
; print move kount in decimal
;-------------------------------------------------------
putkount:
   push af
   push bc
   push hl
   call clrstk
   ld bc,(kount)
   ld (dvdnd),bc
   ld a,(ten)
   ld (divisor),a
   call Div8
   ld a,(remainder)
   ld (stk),a
   ld bc,(quotient)
   ld (dvdnd),bc
   ld a,(ten)
   ld (divisor),a
   call Div8
   ld a,(remainder)
   ld (stk+1),a
   ld bc,(quotient)
   ld (dvdnd),bc
   ld a,(ten)
   ld (divisor),a
   call Div8
   ld a,(remainder)
   ld (stk+2),a
   ;--------------------
   ld a,(stk+2)
   or a
   jp nz,putkount2
   ld a,(stk+1)
   or a
   jp nz,putkount3
   jp putkount4
putkount2:
   ld a,(stk+2)
   add a,030h
   call cout
putkount3:
   ld a,(stk+1)
   add a,030h
   call cout
putkount4:
   ld a,(stk)
   add a,030h
   call cout
   call puteol
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; routine to print the three Towers of Hanoi
; This routine prints the state after each pair of moves
; has taken place.
;-------------------------------------------------------
shw:
   push af
   push bc
   push hl
   ld a,'A'
   call coutspc
   ld hl,stka+1
shw2:
   ld a,(hl)
   or a
   jp z,shw2b
   add a,030h
   call coutspc
   inc hl
   jp shw2
shw2b:
   call puteol
   ld a,'B'
   call coutspc
   ld hl,stkb+1
shw3:
   ld a,(hl)
   or a
   jp z,shw3b
   add a,030h
   call coutspc
   inc hl
   jp shw3
shw3b:
   call puteol
   ld a,'C'
   call coutspc
   ld hl,stkc+1
shw4:
   ld a,(hl)
   or a
   jp z,shw4b
   add a,030h
   call coutspc
   inc hl
   jp shw4
shw4b:
   call puteol
   call putdash
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; push a source disk onto the A stack
;-------------------------------------------------------
pusha:
   push af
   push bc
   push hl
   ld hl,stka
   ld b,0
   ld a,(sza)
   ld c,a
   inc c
   add hl,bc
   ld a,(srcdsk)
   ld (hl),a
   ld a,(sza)
   inc a
   ld (sza),a
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; push a source disk onto the B stack
;-------------------------------------------------------
pushb:
   push af
   push bc
   push hl
   ld hl,stkb
   ld b,0
   ld a,(szb)
   ld c,a
   inc c
   add hl,bc
   ld a,(srcdsk)
   ld (hl),a
   ld a,(szb)
   inc a
   ld (szb),a
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; push a source disk onto the C stack
;-------------------------------------------------------
pushc:
   push af
   push bc
   push hl
   ld hl,stkc
   ld b,0
   ld a,(szc)
   ld c,a
   inc c
   add hl,bc
   ld a,(srcdsk)
   ld (hl),a
   ld a,(szc)
   inc a
   ld (szc),a
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; pop the top disk from the A stack
; place the disk in popdsk
; lower the count of sza by 1
; place a zero on the top of the stack where the disk was
; if underflow, terminate job
;-------------------------------------------------------
popa:
   push af
   push bc
   push hl
   ld a,(sza)
   or a
   jp nz,popa2
   call cout
   jp eoj
popa2:
   ld hl,stka
   ld b,0
   ld a,(sza)
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (popdsk),a
   xor a
   ld (hl),a
   ld a,(sza)
   dec a
   ld (sza),a
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; pop the top disk from the B stack
; place the disk in popdsk
; lower the count of szb by 1
; place a zero on the top of the stack where the disk was
; if underflow, terminate job
;-------------------------------------------------------
popb:
   push af
   push bc
   push hl
   ld a,(szb)
   or a
   jp nz,popb2
   call cout
   jp eoj
popb2:
   ld hl,stkb
   ld b,0
   ld a,(szb)
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (popdsk),a
   xor a
   ld (hl),a
   ld a,(szb)
   dec a
   ld (szb),a
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; pop the top disk from the C stack
; place the disk in popdsk
; lower the count of szc by 1
; place a zero on the top of the stack where the disk was
; if underflow, terminate job
;-------------------------------------------------------
popc:
   push af
   push bc
   push hl
   ld a,(szc)
   or a
   jp nz,popc2
   call cout
   jp eoj
popc2:
   ld hl,stkc
   ld b,0
   ld a,(szc)
   ld c,a
   add hl,bc
   ld a,(hl)
   ld (popdsk),a
   xor a
   ld (hl),a
   ld a,(szc)
   dec a
   ld (szc),a
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; read the optional run time parameter
; for total number of disks
; convert the parameter from ASCII to binary
; valid parameters are 2-9
; if invalid, use the default of 3 disks
;-------------------------------------------------------
getparm:
   push af
   push bc
   push hl
   ld a,3
   ld (stksz),a
   ld hl,080h
   ld a,(hl)
   or a
   jp z,getprm9
   inc hl
getprm2:
   ld a,(hl)
   or a
   jp z,getprm9
   cp 020h
   jp z,getprm3
   sub a,030h
   cp 2
   jp m,getprm9
   cp 10
   jp p,getprm9
   ld (stksz),a
   jp getprm9
getprm3:
   inc hl
   jp getprm2
getprm9:
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; Debugging routine to dump the parameter buffer in hex.
;-------------------------------------------------------
dmpbuf:
   push af
   push bc
   push hl
   ld hl,080h
   ld b,(hl)
   inc hl
dmpbuf2:
   ld a,(hl)
   call puthexa
   inc hl
   dec b
   ld a,b
   or a
   jp nz,dmpbuf2
   call puteol
   pop hl
   pop bc
   pop af
   ret
;---------------------------------------------------------
; pause for keyboard input, quit if 'q'
;---------------------------------------------------------
pause:
   push af
   call cin
   cp 01ah
   jp z,eoj
   cp 'q'
   jp z,eoj
   pop af
   ret
;---------------------------------------------------------
; print 16-bit binary number in decimal
; the number to print is in the BC register
; print a space after the number
; The technique used is to divide the number repeatedly by 10
; Each remainder is pushed onto a stack of digits
; The number is printed by popping the stack for each digit.
;---------------------------------------------------------
putdec:
   push af
   push bc
   push de
   push hl
   ; store BC register in variable num
   ld a,c
   ld (num),a
   ld a,b
   ld (num+1),a
   ; point to empty stack
   ld hl,stk
   ld (stkadr),hl
   ; only 4 digits are pushed onto the stack
   ld a,4
   ld (stksz),a
   call clrstk         ; clear the stack to all zeros
; division loop
putdec2:
   ; set up the parameters in the division subroutine
   ld a,(num)
   ld (dvdnd),a
   ld a,(num+1)
   ld (dvdnd+1),a
   xor a
   ld (dvdnd+2),a
   ld a,(ten)
   ld (divisor),a
   call Div8
   ; push the remainder onto the stack
   ld hl,(stkadr)
   ld a,(remainder)
   ld (hl),a
   ; save the quotient for the next iteration
   ld a,(quotient)
   ld (num),a
   ld a,(quotient+1)
   ld (num+1),a
   ; bump the stack pointer
   ld a,(stkadr)
   add a,1
   ld (stkadr),a
   ld a,(stkadr+1)
   adc a,0
   ld (stkadr+1),a
   ; 4 digits on stack?
   ld a,(stksz)
   dec a
   ld (stksz),a
   or a
   jp nz,putdec2      ; no, divide by 10 again
; yes, bypass leading zeros
putdec3:
   ld a,(stk+3)
   or a
   jp nz,putdec4
   ld a,(stk+2)
   or a
   jp nz,putdec5
   ld a,(stk+1)
   or a
   jp nz,putdec6
; after bypassing leading zeros
; print high order thousands digit
putdec4:
   ld a,(stk+3)
   add a,030h
   call cout
; print high order hundreds digit
putdec5:
   ld a,(stk+2)
   add a,030h
   call cout
; print high order tens digit
putdec6:
   ld a,(stk+1)
   add a,030h
   call cout
; print low order units digit
   ld a,(stk)
putdec9:
   add a,030h
   call cout
   call putspc          ; print space
   pop hl
   pop de
   pop bc
   pop af
   ret
;---------------------------------------------------------
; print contents of variable num
;---------------------------------------------------------
putnum:
   push af
   ld a,(num+1)
   call puthex
   ld a,(num)
   call puthexa
   pop af
   ret
;---------------------------------------------------------
; clear the decimal digit stack to all zeros
;---------------------------------------------------------
clrstk:
   push af
   xor a
   ld (stk),a
   ld (stk+1),a
   ld (stk+2),a
   ld (stk+3),a
   pop af
   ret
;---------------------------------------------------------
; print the decimal digit stack
; in big endian format
;---------------------------------------------------------
putstk:
   push af
   push hl
   ld hl,stk+3
   ld a,(hl)
   add a,030h
   call cout
   dec hl
   ld a,(hl)
   add a,030h
   call cout
   dec hl
   ld a,(hl)
   add a,030h
   call cout
   dec hl
   ld a,(hl)
   add a,030h
   call cout
   call putspc
   call pause
   pop hl
   pop af
   ret
;---------------------------------------------------------
; standard z80 division
; of 8-bit number into a 24-bit number
; giving a 16-bit quotient and an 8-bit remainder
; here are the variable names used:
; quotient  = dvdnd / divisor
; remainder = dvdnd % divisor
;---------------------------------------------------------
Div8:                    ; this routine performs the operation HL=HL/D
   push af
   push bc
   push de
   push hl
   ld hl,(dvdnd)
   ld a,(divisor)
   ld d,a
   xor a                  ; clearing the upper 8 bits of AHL
   ld b,16                ; the length of the dividend (16 bits)
Div8Loop:
   add hl,hl              ; advancing a bit
   rla
   ;---------------------------------------------------------
   ; checking if the divisor divides the digits chosen (in A)
   ;---------------------------------------------------------
   cp d
   jp c,Div8NextBit       ; if not, advancing without subtraction
   sub d                  ; subtracting the divisor
   inc l                  ; and setting the next digit of the quotient
Div8NextBit:
   djnz Div8Loop
   ld (quotient),hl
   ld (remainder),a
   pop hl
   pop de
   pop bc
   pop af 
   ret
;----------------------- Div8 ------------------ 
;
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
   push bc
   push hl
   ld a,b
   call puthex
   ld a,c
   call puthex
   call putspc
   pop hl
   pop bc
   pop af
   ret
;---------------------------------------------
; Print the HL register in hex
;---------------------------------------------
puthl:
   push af
   push hl
   ld a,h
   call puthex
   ld a,l
   call puthex
   call putspc
   pop hl
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
; A 4-bit half byte is called a nybble
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
; followed by printing a space
;---------------------------------------------
coutspc:
   call cout
   call putspc
   ret
;---------------------------------------------
; Print one ASCII byte to the console
;---------------------------------------------
cout:
   push af
   push bc
   push de
   push hl
   ld c,a
   ld de,kcout
   call ios
   pop hl
   pop de
   pop bc
   pop af
   ret
;---------------------------------------------
; CP/M input/output service routine
;---------------------------------------------
ios:
   ld hl,(01h)
   add hl,de
   jp (hl)
   nop
   nop
   nop
   nop
   end
