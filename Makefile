all:
	as -o cricket.o cricket.s
	gcc -o cricket cricket.o
debug:
	as -g -o cricket.o cricket.s
	gcc -g -o cricket cricket.o
clean:
	rm -f cricket cricket.o

cross:
	/usr/bin/riscv64-linux-gnu-as cricket.s -o cricket.o
	riscv64-linux-gnu-gcc -o cricket cricket.o -Wl,-rpath=/usr/riscv64-linux-gnu/lib/
