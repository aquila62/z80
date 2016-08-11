CC=z80asm

sieve.com:			sieve.asm
		$(CC) -lsieve.lst -o sieve.com sieve.asm

clean:
		rm -f sieve.com sieve.lst
