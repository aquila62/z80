; twr.asm - Tower of Hanoi  Version 1.0.0
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
; This program performs the recursive solution to the Tower
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
stka:   db 9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0       ; source stack
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
parm1:  dw 0,0         ; temporary parm 1
parm2:  dw 0,0         ; temporary parm 2
parm3:  dw 0,0         ; temporary parm 3
parm4:  dw 0,0         ; temporary parm 4
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
ufmsg:  db 'Stack underflow',13,10,0
; decimal numbers are printed from a stack 
stk: ds 16             ; decimal number stack
;---------------------------------------------------
strt:                  ; program starts here
   ; initialize the move counter to zero
   xor a
   ld (kount),a
   ld (kount+1),a
   ld hl,8000h         ; set stack address at 8000h
   ld sp,hl
   ;----------------------------------------------------
   call getparm        ; optional parm is number of disks
   call bld            ; fill the sieve array with odd numbers
   ;----------------------------------------------------
   ; movedsk(n,src,tgt,aux);
   ;----------------------------------------------------
   ld hl,stkb          ; 4th parm = auxiliary stack
   push hl
   ld hl,stkc          ; 3th parm = target stack
   push hl
   ld hl,stka          ; 2nd parm = source stack
   push hl
   ld a,(stksz)        ; 1st parm = number of disks
   ld c,a              ; bc = number of disks
   ld b,0
   push bc             ; 1st parm = number of disks
   call movedsk
   pop bc              ; pop 1st parm
   pop bc              ; pop 2nd parm
   pop bc              ; pop 3rd parm
   pop bc              ; pop 4th parm
   ;----------------------------------------------------
   ; 2^n-1 moves have been made
   ; now show the final state
   ;----------------------------------------------------
   call shw            ; print final disk state
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
   xor a
   ld (stkb),a      ; stack b is empty
   ld (stkc),a      ; stack c is empty
   ld a,(stksz)     ; number of disks
   ld (stka),a      ; store in stack a header
   ld hl,stka+1     ; largest disk address
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
; recursive move routine
; See Wikipedia article on the Tower of Hanoi
; Parameters:
;    number of disks
;    source stack
;    target stack
;    auxiliary stack
; Step 1. movedsk(n-1,source,auxiliary,target);
; Step 2. move disk n from source to target
; Step 3. movedsk(n-1,auxiliary,target,source);
;-------------------------------------------------------
movedsk:
   push af
   push bc
   push de
   push hl
   ;-------------------------------------------------
   ; if (n < 1) return;
   ;-------------------------------------------------
   ld hl,10          ; number of disks input parm
   add hl,sp         ; sp + 10 = 1st input parm
   ld c,(hl)         ; load number of disks (1-9)
   ld b,0            ; b = 0
   ld a,c            ; small number 1-9
   or a              ; zero?
   jp z,movedsk9     ; yes, n == 0, return
   jp m,movedsk9     ; yes, n < 0,return
   ;-------------------------------------------------
   ; n > 0:
   ; step 1. movedsk(n-1,src,aux,tgt);
   ;-------------------------------------------------
   ld hl,10+4        ; target stack input parm
   add hl,sp         ; sp + 10 + 4 = 3rd input parm
   ld c,(hl)         ; load the target stack address
   inc hl            ; point to high order byte
   ld b,(hl)         ; load the target stack address
   ld (parm4),bc     ; new 4th parm (new auxiliary stack)
   ;-------------------------------------------------
   ld hl,10+6        ; auxiliary stack input parm
   add hl,sp         ; sp + 10 + 6 = 4th input parm
   ld c,(hl)         ; load the auxiliary stack address
   inc hl            ; point to high order byte
   ld b,(hl)         ; load the auxiliary stack address
   ld (parm3),bc     ; new 3rd parm (new target stack)
   ;-------------------------------------------------
   ld hl,10+2        ; source stack input parm
   add hl,sp         ; sp + 10 + 2 = 2nd input parm
   ld c,(hl)         ; load the source stack address
   inc hl            ; point to high order byte
   ld b,(hl)         ; load the source stack address
   ld (parm2),bc     ; new 2nd parm (new source stack)
   ;-------------------------------------------------
   ld hl,10          ; number of disks input parm
   add hl,sp         ; sp + 10 = 1st input parm
   ld c,(hl)         ; load number of disks
   ld b,0            ; b = 0
   dec bc            ; number of disks minus one
   ld (parm1),bc     ; new 1st parm (number of disks = n-1)
   ;--------------------------------------------------
   ; push the 4 parameters and make the recursive call
   ;--------------------------------------------------
   ld bc,(parm4)
   push bc
   ld bc,(parm3)
   push bc
   ld bc,(parm2)
   push bc
   ld bc,(parm1)
   push bc
   call movedsk      ; recursived call
   pop bc            ; pop 1st parm
   pop bc            ; pop 2nd parm
   pop bc            ; pop 3rd parm
   pop bc            ; pop 4th parm
   ;-------------------------------------------------
   ; step 2. target.append(source.pop());
   ;-------------------------------------------------
   ld hl,10+2        ; source stack input parm
   add hl,sp         ; sp + 10 + 2 = 2nd input parm
   ld c,(hl)         ; load the source stack address
   inc hl            ; point to high order byte
   ld b,(hl)         ; load the source stack address
   ld h,b            ; load source stack address into hl
   ld l,c            ; load source stack address into hl
   ld a,(hl)         ; load header of source stack into a reg
   ld c,a            ; bc = offset into source stack
   ld b,0
   add hl,bc         ; hl + bc = top of source stack address
   ld a,(hl)         ; get disk from top of source stack
   ld (popdsk),a     ; save the disk in popdsk
   xor a             ; a = 0
   ld (hl),a         ; top of source stack = 0
   ;-------------------------------------------------
   ; get source stack header address
   ;-------------------------------------------------
   ld hl,10+2        ; source stack input parm
   add hl,sp         ; sp + 10 + 2 = 2nd input parm
   ld c,(hl)         ; load the source stack address
   inc hl            ; point to high order byte
   ld b,(hl)         ; load the source stack address
   ld h,b            ; load source stack address into hl
   ld l,c            ; load source stack address into hl
   ld a,(hl)         ; load header of source stack into a reg
   or a              ; is stack length zero?
   jp nz,movedsk2    ; no, no underflow
   call undrflow     ; yes, underflow message
   jp eoj            ; yes, terminate
movedsk2:
   dec a             ; subtract 1 from stack length
   ld (hl),a         ; store source stack header
   ;-------------------------------------------------
   ; push source disk on target stack
   ;-------------------------------------------------
   ld hl,10+4        ; target stack input parm
   add hl,sp         ; sp + 10 + 4 = 3rd input parm
   ld c,(hl)         ; load the target stack address
   inc hl            ; point to high order byte
   ld b,(hl)         ; load the target stack address
   ld h,b            ; load target stack address into hl
   ld l,c            ; load target stack address into hl
   ld a,(hl)         ; load target stack length into a reg
   ld b,0            ; bc = offset to top of target stack
   ld c,a
   add hl,bc         ; top of target stack
   inc hl            ; extend target stack
   ld a,(popdsk)     ; a = source disk
   ld (hl),a         ; save source disk on top of target stack
   ;-------------------------------------------------
   ; increase target stack length header
   ;-------------------------------------------------
   ld hl,10+4        ; target stack input parm
   add hl,sp         ; sp + 10 + 4 = 3rd input parm
   ld c,(hl)         ; load the target stack address
   inc hl            ; point to high order byte
   ld b,(hl)         ; load the target stack address
   ld h,b            ; load target stack address into hl
   ld l,c            ; load target stack address into hl
   ld a,(hl)         ; load target stack length into a reg
   inc a             ; add 1 to stack length
   ld (hl),a         ; save new length in target stack header
   ;-------------------------------------------------
   ld bc,(kount)     ; bc = move count
   inc bc            ; bc += 1
   ld (kount),bc     ; kount += 1
   call putkount     ; print the move count
   call shw          ; print the state
   call pause        ; pause for keyboard input
   ;-------------------------------------------------
   ; step 3. movedsk(n-1,aux,tgt,src);
   ;-------------------------------------------------
   ld hl,10+2        ; source stack input parm
   add hl,sp         ; sp + 10 + 2 = 2nd input parm
   ld c,(hl)         ; load the source stack address
   inc hl            ; point to high order byte
   ld b,(hl)         ; load the source stack address
   ld (parm4),bc     ; new 4th parm (new auxiliary stack)
   ;-------------------------------------------------
   ld hl,10+4        ; target stack input parm
   add hl,sp         ; sp + 10 + 4 = 3rd input parm
   ld c,(hl)         ; load the target stack address
   inc hl            ; point to high order byte
   ld b,(hl)         ; load the target stack address
   ld (parm3),bc     ; new 3rd parm (new target stack)
   ;-------------------------------------------------
   ld hl,10+6        ; auxiliary stack input parm
   add hl,sp         ; sp + 10 + 6 = 4th input parm
   ld c,(hl)         ; load the auxiliary stack address
   inc hl            ; point to high order byte
   ld b,(hl)         ; load the auxiliary stack address
   ld (parm2),bc     ; new 2nd parm (new source stack)
   ;-------------------------------------------------
   ld hl,10          ; number of disks input parm
   add hl,sp         ; sp + 10 = 1st input parm
   ld c,(hl)         ; load number of disks (1-9)
   ld b,0            ; b = 0
   dec bc            ; number of disks minus one
   ld (parm1),bc     ; new 1st parm (new n-1)
   ;--------------------------------------------------
   ; push the 4 parameters and make the recursive call
   ;--------------------------------------------------
   ld bc,(parm4)
   push bc
   ld bc,(parm3)
   push bc
   ld bc,(parm2)
   push bc
   ld bc,(parm1)
   push bc
   call movedsk      ; recursived call
   pop bc            ; pop 1st parm
   pop bc            ; pop 2nd parm
   pop bc            ; pop 3rd parm
   pop bc            ; pop 4th parm
   ;--------------------------------------------------
   ; return from recursive call
   ;--------------------------------------------------
movedsk9:
   pop hl
   pop de
   pop bc
   pop af
   ret
;-------------------------------------------------------
; print underflow message
;-------------------------------------------------------
undrflow:
   push af
   push bc
   push hl
   ld hl,ufmsg
.lp:
   ld a,(hl)
   or a
   jp z,.done
   call cout
   jp .lp
.done:
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
; print A followed by one space
;---------------------------------------------
putbiga:
   push af
   ld a,'A'
   call cout
   ld a,020h
   call cout
   pop af
   ret
;---------------------------------------------
; print B followed by one space
;---------------------------------------------
putbigb:
   push af
   ld a,'B'
   call cout
   ld a,020h
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
