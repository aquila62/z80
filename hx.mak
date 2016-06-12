CC=z80asm

hx.com:				hx.asm
		$(CC) -o hx.com hx.asm

clean:
		rm -f hx.com
