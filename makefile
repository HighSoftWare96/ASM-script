EXE= run
AS= as
LD= ld
FLAGS= --32 -gstabs
OBJ= elaboratoASM.o write_output.o valutazione.o atoi.o

$(EXE): $(OBJ)
	$(LD) -o $(EXE) $(OBJ) -m elf_i386
write_output.o: write_output.s
	$(AS) $(FLAGS) -o write_output.o write_output.s
atoi.o: atoi.s
	$(AS) $(FLAGS) -o atoi.o atoi.s
valutazione.o: valutazione.s
	$(AS) $(FLAGS) -o valutazione.o valutazione.s
elaboratoASM.o: elaboratoASM.s
	$(AS) $(FLAGS) -o elaboratoASM.o elaboratoASM.s
clean:
	rm -f *.o
