CC=z80asm

ascii.com:			ascii.asm
		$(CC) -o ascii.com ascii.asm

clean:
		rm -f ascii.com
