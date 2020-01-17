*.bin: *.asm
	./dasm current.asm -lcurrent.txt -f3 -v5 -ocurrent.bin

.PHONY: clean
clean:
	rm *.bin *.txt
