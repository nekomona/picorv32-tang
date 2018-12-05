#include <stdint.h>
#include <stdbool.h>

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

#define reg_spictrl (*(volatile uint32_t*)0x02000000)
#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data (*(volatile uint32_t*)0x02000008)
#define reg_leds (*(volatile uint32_t*)0x03000000)

// --------------------------------------------------------

extern uint32_t flashio_worker_begin;
extern uint32_t flashio_worker_end;

void flashio(uint8_t *data, int len, uint8_t wrencmd)
{
	uint32_t func[&flashio_worker_end - &flashio_worker_begin];

	uint32_t *src_ptr = &flashio_worker_begin;
	uint32_t *dst_ptr = func;

	while (src_ptr != &flashio_worker_end)
		*(dst_ptr++) = *(src_ptr++);

	((void(*)(uint8_t*, uint32_t, uint32_t))func)(data, len, wrencmd);
}

extern uint32_t isp_flasher_begin;
extern uint32_t isp_flasher_end;

void run_isp()
{
	uint8_t buffer_page[260];
	
	uint32_t funcio[&flashio_worker_end - &flashio_worker_begin];
	uint32_t funcisp[&isp_flasher_end - &isp_flasher_begin];

	uint32_t *src_ptr = &flashio_worker_begin;
	uint32_t *dst_ptr = funcio;

	while (src_ptr < &flashio_worker_end)
		*(dst_ptr++) = *(src_ptr++);
	
	src_ptr = &isp_flasher_begin;
	dst_ptr = funcisp;
	
	while (src_ptr < &isp_flasher_end)
		*(dst_ptr++) = *(src_ptr++);
	
	((void(*)(uint8_t*,  uint32_t*))funcisp)(buffer_page, funcio);
}

void set_flash_qspi_flag()
{
	//set to winbond instruction set
	uint8_t buffer_rd1[2] = {0x05, 0};
	flashio(buffer_rd1, 2, 0);

	uint8_t buffer_rd2[2] = {0x35, 0};
	flashio(buffer_rd2, 2, 0);

	uint8_t buffer_wr[3] = {0x01, buffer_rd1[1], buffer_rd2[1] | 2};
	flashio(buffer_wr, 3, 0x06);
}

// --------------------------------------------------------

void putchar(char c)
{
	if (c == '\n')
		putchar('\r');
	reg_uart_data = c;
}

void print(const char *p)
{
	while (*p)
		putchar(*(p++));
}

void print_hex(uint32_t v, int digits)
{
	for (int i = 7; i >= 0; i--) {
		char c = "0123456789abcdef"[(v >> (4*i)) & 15];
		if (c == '0' && i >= digits) continue;
		putchar(c);
		digits = i;
	}
}

void print_dec(uint32_t v)
{
	if (v >= 100) {
		print(">=100");
		return;
	}

	if      (v >= 90) { putchar('9'); v -= 90; }
	else if (v >= 80) { putchar('8'); v -= 80; }
	else if (v >= 70) { putchar('7'); v -= 70; }
	else if (v >= 60) { putchar('6'); v -= 60; }
	else if (v >= 50) { putchar('5'); v -= 50; }
	else if (v >= 40) { putchar('4'); v -= 40; }
	else if (v >= 30) { putchar('3'); v -= 30; }
	else if (v >= 20) { putchar('2'); v -= 20; }
	else if (v >= 10) { putchar('1'); v -= 10; }

	if      (v >= 9) { putchar('9'); v -= 9; }
	else if (v >= 8) { putchar('8'); v -= 8; }
	else if (v >= 7) { putchar('7'); v -= 7; }
	else if (v >= 6) { putchar('6'); v -= 6; }
	else if (v >= 5) { putchar('5'); v -= 5; }
	else if (v >= 4) { putchar('4'); v -= 4; }
	else if (v >= 3) { putchar('3'); v -= 3; }
	else if (v >= 2) { putchar('2'); v -= 2; }
	else if (v >= 1) { putchar('1'); v -= 1; }
	else putchar('0');
}

char getchar_prompt(char *prompt)
{
	int32_t c = -1;

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));

	if (prompt)
		print(prompt);

	if (prompt)
		reg_leds = ~0;

	while (c == -1) {
		__asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
		if (cycles > 12000000) {
			if (prompt)
				print(prompt);
			cycles_begin = cycles_now;
			if (prompt)
				reg_leds = ~reg_leds;
		}
		c = reg_uart_data;
	}
	if (prompt)
		reg_leds = 0;
	return c;
}

char getchar()
{
	return getchar_prompt(0);
}

// --------------------------------------------------------

void cmd_read_flash_id()
{
	uint8_t buffer[4] = { 0x9F, /* zeros */ };
	flashio(buffer, 4, 0);

	for (int i = 1; i <= 3; i++) {
		putchar(' ');
		print_hex(buffer[i], 2);
	}
	putchar('\n');
}


// --------------------------------------------------------

uint32_t cmd_benchmark(bool verbose, uint32_t *instns_p)
{
	uint8_t data[256];
	uint32_t *words = (void*)data;

	uint32_t x32 = 314159265;

	uint32_t cycles_begin, cycles_end;
	uint32_t instns_begin, instns_end;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));
	__asm__ volatile ("rdinstret %0" : "=r"(instns_begin));

	for (int i = 0; i < 20; i++)
	{
		for (int k = 0; k < 256; k++)
		{
			x32 ^= x32 << 13;
			x32 ^= x32 >> 17;
			x32 ^= x32 << 5;
			data[k] = x32;
		}

		for (int k = 0, p = 0; k < 256; k++)
		{
			if (data[k])
				data[p++] = k;
		}

		for (int k = 0, p = 0; k < 64; k++)
		{
			x32 = x32 ^ words[k];
		}
	}

	__asm__ volatile ("rdcycle %0" : "=r"(cycles_end));
	__asm__ volatile ("rdinstret %0" : "=r"(instns_end));

	if (verbose)
	{
		print("Cycles: 0x");
		print_hex(cycles_end - cycles_begin, 8);
		putchar('\n');

		print("Instns: 0x");
		print_hex(instns_end - instns_begin, 8);
		putchar('\n');

		print("Chksum: 0x");
		print_hex(x32, 8);
		putchar('\n');
	}

	if (instns_p)
		*instns_p = instns_end - instns_begin;

	return cycles_end - cycles_begin;
}

// --------------------------------------------------------

void cmd_benchmark_all()
{
	uint32_t instns = 0;

	print("default        ");
	reg_spictrl = (reg_spictrl & ~0x007F0000) | 0x00000000;
	print(": ");
	print_hex(cmd_benchmark(false, &instns), 8);
	putchar('\n');

	print("dspi-");
	print_dec(0);
	print("         ");

	reg_spictrl = (reg_spictrl & ~0x007F0000) | 0x00400000;

	print(": ");
	print_hex(cmd_benchmark(false, &instns), 8);
	putchar('\n');

	print("dspi-crm-");
	print_dec(0);
	print("     ");

	reg_spictrl = (reg_spictrl & ~0x007F0000) | 0x00500000;

	print(": ");
	print_hex(cmd_benchmark(false, &instns), 8);
	putchar('\n');

	print("qspi-");
	print_dec(4);
	print("         ");

	reg_spictrl = (reg_spictrl & ~0x007F0000) | 0x00240000;
	
	print(": ");
	print_hex(cmd_benchmark(false, &instns), 8);
	putchar('\n');

	print("qspi-crm-");
	print_dec(4);
	print("     ");

	reg_spictrl = (reg_spictrl & ~0x007F0000) | 0x00340000;

	print(": ");
	print_hex(cmd_benchmark(false, &instns), 8);
	putchar('\n');

	print("instns         : ");
	print_hex(instns, 8);
	putchar('\n');
}

// --------------------------------------------------------

void main()
{
	reg_uart_clkdiv = 206;
	set_flash_qspi_flag();

	while (getchar_prompt("Press ENTER to continue..\n") != '\r') { /* wait */ }

	print("\n");
	print("  ____  _          ____         ____\n");
	print(" |  _ \\(_) ___ ___/ ___|  ___  / ___|\n");
	print(" | |_) | |/ __/ _ \\___ \\ / _ \\| |\n");
	print(" |  __/| | (_| (_) |__) | (_) | |___\n");
	print(" |_|   |_|\\___\\___/____/ \\___/ \\____|\n");
	print("\n");
	print("           On Lichee Tang\n");
	print("\n");


	while (1)
	{
		print("\n");
		print("\n");
		print("SPI State:\n");

		print("  LATENCY ");
		print_dec((reg_spictrl >> 16) & 15);
		print("\n");

		print("  DDR ");
		if ((reg_spictrl & (1 << 22)) != 0)
			print("ON\n");
		else
			print("OFF\n");

		print("  QSPI ");
		if ((reg_spictrl & (1 << 21)) != 0)
			print("ON\n");
		else
			print("OFF\n");

		print("  CRM ");
		if ((reg_spictrl & (1 << 20)) != 0)
			print("ON\n");
		else
			print("OFF\n");

		print("\n");
		print("Select an action:\n");
		print("\n");
		print("   [1] Read SPI Flash ID\n");
		print("   [2] Switch to default mode\n");
		print("   [3] Switch to Dual I/O mode\n");
		print("   [4] Switch to Quad I/O mode\n");
		print("   [5] Toggle continuous read mode\n");
		print("   [6] Run simplistic benchmark\n");
		print("   [7] Toggle R led\n");
		print("   [8] Toggle G led\n");
		print("   [9] Toggle B led\n");
		print("   [0] Benchmark all configs\n");
		print("   [f] Start ISP\n");
		print("\n");

		for (int rep = 10; rep > 0; rep--)
		{
			print("Command> ");
			char cmd = getchar();
			if (cmd > 32 && cmd < 127)
				putchar(cmd);
			print("\n");

			switch (cmd)
			{
			case '1':
				cmd_read_flash_id();
				break;
			case '2':
				reg_spictrl = (reg_spictrl & ~0x007f0000) | 0x00000000;
				break;
			case '3':
				reg_spictrl = (reg_spictrl & ~0x007f0000) | 0x00400000;
				break;
			case '4':
				reg_spictrl = (reg_spictrl & ~0x007f0000) | 0x00240000;
				break;
			case '5':
				if((reg_spictrl & (3 << 21)) != 0)
					reg_spictrl = reg_spictrl ^ 0x00100000;
				break;
			case '6':
				cmd_benchmark(true, 0);
				break;
			case '7':
				reg_leds = reg_leds ^ 0x00000001;
				break;
			case '8':
				reg_leds = reg_leds ^ 0x00000002;
				break;
			case '9':
				reg_leds = reg_leds ^ 0x00000004;
				break;
			case '0':
				cmd_benchmark_all();
				break;
			case 'f':
				run_isp();
				break;
			default:
				continue;
			}

			break;
		}
	}
}

