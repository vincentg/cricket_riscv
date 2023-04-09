all:
	as -o main.o main.s
	ld -o main main.o
clean:
	rm -f main main.o
