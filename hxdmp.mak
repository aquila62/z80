CC=z80asm

hxdmp.com:			hxdmp.asm
		$(CC) hxdmp.asm -o hxdmp.com

clean:
		rm -f hxdmp.com
