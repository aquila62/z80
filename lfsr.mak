CC=z80asm

lfsr.com:			lfsr.asm
		$(CC) lfsr.asm -o lfsr.com

clean:
		rm -f lfsr.com
