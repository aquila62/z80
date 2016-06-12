CC=z80asm

rlca.com:			rlca.asm
		$(CC) -o rlca.com rlca.asm

clean:
		rm -f rlca.com
