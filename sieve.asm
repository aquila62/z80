; sieve.asm - Sieve of Eratosthenes   Version 1.0.0
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
; This program creates a list of prime numbers from 2 up to
; 2039.
;
; The algorithm used is called the "Sieve of Eratosthenes".
;
; When debugging, quit the program,
; by pressing 'q' during a pause.
;
; The limit of 2039 is chosen, so that the prime number list
; can fit easily on a single screen.
;
; The program starts with a list of odd numbers from 3 to
; 2047.  All numbers that are multiples of a prime number
; are changed to zero on the list.  Finally the numbers left
; over on the list are prime numbers.
;
; The prime numbers left on the list are printed in decimal
; format.  Leading zeros are not printed.  Word wrap is
; not used.  Some numbers overflow onto a second line.
;
; One heuristic, that is not used in this program, is to start
; zeroing with the square of a candidate prime number.
;--------------------------------------------------------------

kcin:  equ 0006h       ; CP/M jump vector for key input
kcout: equ 0009h       ; CP/M jump vector for console output
   org 100h            ; CP/M loads the program at 100h
   jp strt             ; bypass data area
prm:    dw 0,0         ; current prime number candidate
gap:    dw 0,0         ; gap in bytes between multiples
addr:   dw 0,0         ; address of prime + 2p in array sv
curadr: dw 0,0         ; current address in array sv
dmpadr: dw 0,0         ; dump address in array sv
num:    dw 0,0         ; number to print in decimal
stkadr: dw 0,0         ; current pointer in stack
stksz:  db 0,0,0,0     ; number of digits in the stack
;-------------------- 8 bit division
dvdnd:     dw 0,0
ten:       db 10,0
divisor:   db 0,0
quotient:  dw 0,0
remainder: db 0,0,0,0
;---------------------------------------------------
; translate table for printing a 4-bit nybble in hex
;---------------------------------------------------
hxtbl:  db '0123456789ABCDEF'
; decimal numbers are printed from a stack 
stk: ds 16             ; decimal number stack
sv: ds 8192            ; sieve array of odd numbers
svend: ds 32           ; marker for the end of the array
;---------------------------------------------------
strt:                  ; program starts here
   call bld            ; fill the sieve array with odd numbers
   call xout           ; zero out multiples of prime numbers
   call shw            ; print remaining prime numbers
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
; build the sieve array
; fill the sieve array with odd numbers from
; 3 to 2047.
; fill the rest of the sieve array with hex ff.
; hex ff marks the end of the odd number list.
;---------------------------------------------
bld:
   push af
   push bc
   push hl
   ; initialize prm to 3
   ld a,3h
   ld (prm),a
   xor a
   ld (prm+1),a
   ; initialize gap to 6
   ; this represents the gap for prime number 3
   ; the gap is twice as many bytes as the prime number
   ; so that the gap for 5 is 10
   ld a,6h
   ld (gap),a
   xor a
   ld (gap+1),a
   ; set the pointer to the location of a candidate
   ; prime number in the sieve array.
   ld hl,sv
   ld (addr),hl
;---------------------------------------------
; main odd number loop in bld
;---------------------------------------------
lp:
   ; in bld, prm is a candidate prime number
   ; it is all the odd numbers from 3 to 2039
   ; place the next odd number in its ordinal
   ; place in the odd number array
   ld bc,(prm)
   ld hl,(addr)
   ld (hl),c
   inc hl
   ld (hl),b
   inc hl
   ld (addr),hl
   ; add 2 to the current odd number
   ; to get the next odd number
   ld bc,(prm)
   inc bc
   inc bc
   ld (prm),bc
   ; check prm to see if end of list has been reached.
   ; 800 hex is 2048.
   ; all numbers are stored in little endian format
   ld a,(prm+1)
   cp 08h
   jp nz,lp      ; add next odd number to list
;---------------------------------------------
; end of odd number list at 2047
; now add hex ff to mark the end of of the list 
; terminate adding hex ff at 8192. 
;---------------------------------------------
bld1:
   ld a,0ffh
   ld (hl),a
   inc hl
   ld a,h
   cp 020h           ; end of list at 8192 (2000 hex)?
   jp m,bld1         ; no, repeat adding hex ff to array
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; routine to cross out odd numbers that are multiples
; of a prime number
;-------------------------------------------------------
xout:
   push af
   push bc
   push hl
   ; initialize prm to 3
   ld a,3h
   ld (prm),a
   ; initialize the gap to 6 (the gap for 3)
   ld a,6h
   ld (gap),a
   xor a
   ld (prm+1),a
   ld (gap+1),a
   ; point to the beginning of the sieve array
   ld hl,sv
   ld (addr),hl
;-------------------------------------------------------
; outer loop
; each iteration represents a candidate prime number
; and its multiples
;-------------------------------------------------------
xout1:
   ; point to the first multiple of prm
   ; curadr is the pointer to the first multiple
   ld bc,(gap)
   ld hl,(addr)
   add hl,bc
   ld (curadr),hl
;-------------------------------------------------------
; inner loop to zero out multiples of primes
;-------------------------------------------------------
xout2:
   ; is current multiple beyond end of list?
   ld hl,(curadr)
   inc hl
   ld a,(hl)
   cp 0ffh
   jp z,xout3       ; yes, process next prime number
xout2b:             ; no, not end of list
   ; zero out the current multiple of prm
   ld hl,(curadr)
   xor a
   ld (hl),a
   inc hl
   ld (hl),a
   ; now point to the next multiple of prm
   ld bc,(gap)
   ld hl,(curadr)
   add hl,bc
   ld (curadr),hl
   jp xout2             ; repeat inner loop
; add 2 to odd number prime prm
; add 4 to gap between multiples
; add 2 to starting address in sieve array
xout3:
   ; add 2 to odd number prime prm
   ld bc,(prm)
   inc bc
   inc bc
   ld (prm),bc
   ; add 4 to gap between multiples
   ld hl,(gap)
   ld b,0h
   ld c,4h
   add hl,bc
   ld (gap),hl
   ; add 2 to starting address in sieve array
   ; starting address is the address of the
   ; candidate prime number prm
   ld hl,(addr)
   ld c,2h
   ld b,0
   add hl,bc
   ld (addr),hl
   ; no more odd prime numbers to process?
   ld hl,(addr)
   inc hl
   ld a,(hl)
   cp 0ffh
   jp z,xout4         ; yes, print out prime number list
xout3b:        ; no, is current prime number candidate zero?
   ld hl,(addr)
   ld a,(hl)
   or a
   jp nz,xout1        ; no, zero out its multiples
   inc hl
   ld a,(hl)
   or a
   jp nz,xout1        ; no, zero out its multiples
   ;
   jp xout3           ; yes, try the next candidate prime
; end of xout routine, now print out prime number list
xout4:                ; end of xout routine
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; routine to print prime number list in decimal
; bypass all odd numbers on list that are zeroed out
;-------------------------------------------------------
shw:
   push af
   push bc
   push hl
   ; print the lowest numbers by hand
   ; to ease the division logic in putdec
   ld a,'2'
   call coutspc
   ld a,'3'
   call coutspc
   ld a,'5'
   call coutspc
   ld a,'7'
   call coutspc
   ld hl,sv+8           ; point to #11 in sieve list
   ld (addr),hl
; main print loop
; one iteration for each valid prime number
shw2:
   ld hl,(addr)         ; point to current number in list
   ; the bc register contains the prime number
   ld c,(hl)
   inc hl
   ld b,(hl)
   inc hl
   ld (addr),hl         ; point to next number in list
   ; is the candidate prime number zero?
   ld a,c
   or a
   jp nz,shw3        ; no, check for end of list
   ld a,b
   or a
   jp z,shw2         ; yes, check if end of list
; check if end of list is reached 
shw3:
   ld a,b
   cp 0ffh             ; end of list?
   jp z,shw5           ; yes, go to end of job
   call putdec         ; no, print bc register in decimal
   ld a,b
   cp 0ffh             ; end of list? (redundant check)
   jp nz,shw2          ; no, print next prime
shw5:                  ; end of prime number list
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; debug routine to print sieve array in hex
;-------------------------------------------------------
dmpsv:
   push af
   push bc
   push hl
   ld hl,sv
   ld (dmpadr),hl
dmpsv1:
   ld hl,(dmpadr)
   ld a,(hl)
   ld b,a
   inc hl
   ld a,(hl)
   cp 0ffh
   jp z,dmpsv2
   call puthex
   ld a,b
   call puthexa
   call pause
   inc hl
   ld (dmpadr),hl
   jp dmpsv1
dmpsv2:
   ld hl,(dmpadr)
   ld a,(hl)
   ld b,a
   inc hl
   ld a,(hl)
   call puthex
   ld a,b
   call puthex
   call puteol
   ld a,'D'
   call cout
   call puteol
   call pause
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; print addr variable in hex, followed by space
;-------------------------------------------------------
putaddr:
   push af
   ld a,(addr+1)
   call puthex
   ld a,(addr)
   call puthexa
   pop af
   ret
;-------------------------------------------------------
; print curadr pointer and data that it points to
;-------------------------------------------------------
putcuradr:
   push af
   push bc
   push hl
   ld a,(curadr+1)
   call puthex
   ld a,(curadr)
   call puthexa
   ld hl,(curadr)
   ld a,(hl)
   ld b,a
   inc hl
   ld a,(hl)
   call puthex
   ld a,b
   call puthexa
   call pause
   pop hl
   pop bc
   pop af
   ret
;-------------------------------------------------------
; print contents of prm variable
;-------------------------------------------------------
putprm:
   push af
   ld a,(prm+1)
   call puthex
   ld a,(prm)
   call puthexa
   pop af
   ret
;-------------------------------------------------------
; print contents of gap variable
;-------------------------------------------------------
putgap:
   push af
   ld a,(gap+1)
   call puthex
   ld a,(gap)
   call puthexa
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
