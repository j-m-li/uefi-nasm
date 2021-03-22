
all: 
	nasm -f bin bootx64.asm -o bootx64.efi
	mkdir -p  M/EFI/BOOT/
	cp bootx64.efi M/EFI/BOOT/
	qemu-system-x86_64 -cpu qemu64 -bios OVMF.fd -drive driver=vvfat,rw=on,dir=M/

clean:
	rm -f *.o *.so *.efi
	rm -f M/EFI/BOOT/*.efi
	rm -f M/NvVars
