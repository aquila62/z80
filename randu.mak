CC=z80asm

randu.com:			randu.z80
		$(CC) -o randu.com randu.z80

clean:
		rm -f randu.com
