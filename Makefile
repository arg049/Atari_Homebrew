*.bin: *.asm
	./dasm.Darwin.x86 playfield.asm -lplayfield.txt -f3 -v5 -oplayfield.bin

.PHONY: clean
clean:
	rm *.bin *.txt
