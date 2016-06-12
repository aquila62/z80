CC=z80asm

rrca.com:			rrca.asm
		$(CC) -o rrca.com rrca.asm

clean:
		rm -f rrca.com
