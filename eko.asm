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
