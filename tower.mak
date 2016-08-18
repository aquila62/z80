CC=z80asm

tower.com:			tower.asm
		$(CC) -ltower.lst -o tower.com tower.asm

clean:
		rm -f tower.com tower.lst
