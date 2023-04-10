all:
	as -o cricket.o cricket.s
	gcc -o cricket cricket.o
debug:
	as -g -o cricket.o cricket.s
	gcc -g -o cricket cricket.o
clean:
	rm -f cricket cricket.o
