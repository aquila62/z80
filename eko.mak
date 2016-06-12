CC=z80asm

eko.com:			eko.asm
		$(CC) eko.asm -o eko.com

clean:
		rm -f eko.com
