CC=z80asm

twr.com:			twr.asm
		$(CC) -ltwr.lst -o twr.com twr.asm

clean:
		rm -f twr.com twr.lst
