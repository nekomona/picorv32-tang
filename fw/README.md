Requires RV32IMC toolchain

Compile and link:

    riscv32-unknown-elf-gcc -march=RV32IMC -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -nostdlib -o firmware.elf start.s isp_flasher.s firmware.c
	
Translate into verilog format:

    riscv32-unknown-elf-objcopy.exe -O verilog firmware.elf fw.out
	
