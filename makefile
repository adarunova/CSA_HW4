# makefile for task.asm
task: main.o input.o in_random.o output.o perimeter.o delete.o
	gcc -g -o task main.o input.o in_random.o output.o perimeter.o delete.o -no-pie
main.o: main.asm macros.mac
	nasm -f elf64 -g -F dwarf main.asm -l main.lst
input.o: input.asm
	nasm -f elf64 -g -F dwarf input.asm -l input.lst
in_random.o: in_random.asm
	nasm -f elf64 -g -F dwarf in_random.asm -l in_random.lst
output.o: output.asm
	nasm -f elf64 -g -F dwarf output.asm -l output.lst
perimeter.o: perimeter.asm
	nasm -f elf64 -g -F dwarf perimeter.asm -l perimeter.lst
delete.o: delete.asm
	nasm -f elf64 -g -F dwarf delete.asm -l delete.lst
