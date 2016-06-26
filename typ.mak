CC=z80asm

typ.com:			typ.asm
		$(CC) typ.asm -o typ.com

clean:
		rm -f typ.com
