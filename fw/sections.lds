SECTIONS {
	.memory : {
		sram = 0;
		. = 0x1000000;
		start*(.text);
		*(.text);
		*(*);
	}
}
