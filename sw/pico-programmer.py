
# coding: utf-8

# compile and linking
# to be optimized
# $ riscv32-unknown-elf-gcc -march=RV32IMC -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -nostdlib -o firmware.elf start.s isp_flasher.s firmware.c
# 
# $ riscv32-unknown-elf-objcopy.exe -O verilog firmware.elf firmware.out     

import serial, sys

if len(sys.argv) != 3 or '-h' in sys.argv:
    print("Usage: python pico-programmer.py <firmware.out file path> <serial port>")
    sys.exit()
    

# read file

filepath = sys.argv[1]
file = open(filepath, 'r', buffering=8192)

lprog = []

lcnt = 0
for line in file:
    # skipping first 1M space
    if lcnt >= 1048577:
        lprog.append(line)
    lcnt = lcnt + 1

file.close()

nproglen = 16 * (len(lprog)-1) + len(lprog[len(lprog)-1].split(' ')) - 1

print("Read program with", nproglen, "bytes")

prog = [0] * nproglen

for i, lstr in enumerate(lprog):
    for j, bprog in enumerate(lstr.split(' ')[0:-1]):
        prog[i*16 + j] = int(bprog, 16)


# open serial and check status
ser = serial.Serial(sys.argv[2], 115200, timeout=0.01)

ser.write(bytes([0x55]))
res = ser.read()

if len(res) == 0 || res[0] != 0x56:
    print("Picorv32-tang not detected or not in isp mode")
    print("Switch to isp mode before")
    ser.close()
    sys.exit()

# begin programming

sectind = 0
pageind = 0
wrtbyte = 0
rembyte = len(prog)
curraddr = 0
pagestep = 256

sectreq = ((rembyte - 1) // 4096) + 1
pagereq = ((rembyte - 1) // pagestep) + 1

print("Total sectors", sectreq)
print("Total pages", pagereq)

for i in range(sectreq):
    saddr = bytes([(curraddr // 65535) & 0xFF, (curraddr // 256) & 0xF0, 0x00])
    
    print("Erasing", i, "at", "0x{:02x}{:02x}{:02x}".format(saddr[0], saddr[1], saddr[2]))
    ser.write(bytes([0x30]))
    
    resp = bytes([0x00])
    wcou = 0
    while resp[0] != 0x31:
        resp = ser.read()
        wcou = wcou + 1
        if len(resp) == 0:
            resp = bytes([0x00])
            if wcou > 10:
                wcou = 0
                ser.write(bytes([0x30]))
        elif resp[0] == 0x31:
            print("Erase processing")
            
    ser.write(saddr)
    resp = bytes([0x00])
    while resp[0] != 0x32:
        resp = ser.read()
        if len(resp) == 0:
            resp = bytes([0x00])
        elif resp[0] == 0x32:
            print("Erase finished")
    
    if (i+1) * 16 >= pagereq:
        for j in range(pagereq - i*16):
            wlen = min(pagestep, rembyte - curraddr)
            wrbuf = [wlen-1]
            wrdat = prog[curraddr:curraddr+wlen]
            chksum = sum(wrdat) & 0xFF
            wrbuf = wrbuf + wrdat
            wrbyte = bytes(wrbuf)
            print(" Writing", curraddr, "to", curraddr+wlen-1)
            print("  chksum", chksum)
            
            ser.write(bytes([0x10]))
            while resp[0] != 0x11:
                resp = ser.read()
                if len(resp) == 0:
                    resp = bytes([0x00])
                elif resp[0] == 0x11:
                    print("  Write processing")
                    
            ser.write(wrbyte)
            resp = bytes([0x00])
            while resp[0] != chksum:
                resp = ser.read()
                if len(resp) == 0:
                    resp = bytes([0x00])
                elif resp[0] == chksum:
                    print("  Chksum get")
                else:
                    print("  Bad chksum", resp[0])
            
            pgbuf = bytes([(curraddr // 65535) & 0xFF, (curraddr // 256) & 0xFF, curraddr & 0xFF])
            print(" Programming", j+i*16, "at", "0x{:02x}{:02x}{:02x}".format(pgbuf[0], pgbuf[1], pgbuf[2]))
                  
            ser.write(bytes([0x40]))
                      
            resp = bytes([0x00])
            while resp[0] != 0x41:
                resp = ser.read()
                if len(resp) == 0:
                    resp = bytes([0x00])
                elif resp[0] == 0x41:
                    print("  Programming processing")
                      
            ser.write(pgbuf)

            resp = bytes([0x00]);
            while resp[0] != 0x42:
                resp = ser.read()
                if len(resp) == 0:
                    resp = bytes([0x00])
                elif resp[0] == 0x42:
                    print("  Programming finished")
            
            curraddr += pagestep
    else:
        for j in range(16):
            wlen = min(pagestep, rembyte - curraddr)
            wrbuf = [wlen-1]
            wrdat = prog[curraddr:curraddr+wlen]
            chksum = sum(wrdat) & 0xFF
            wrbuf = wrbuf + wrdat
            wrbyte = bytes(wrbuf)
            print(" Writing", curraddr, "to", curraddr+wlen-1)
            print("  chksum", chksum)
            
            ser.write(bytes([0x10]))
            while resp[0] != 0x11:
                resp = ser.read()
                if len(resp) == 0:
                    resp = bytes([0x00])
                elif resp[0] == 0x11:
                    print("  Write processing")
                    
            ser.write(wrbyte)
            resp = bytes([0x00])
            while resp[0] != chksum:
                resp = ser.read()
                if len(resp) == 0:
                    resp = bytes([0x00])
                elif resp[0] == chksum:
                    print("  Chksum get")
                else:
                    print("  Bad chksum", resp[0])
            
            pgbuf = bytes([(curraddr // 65535) & 0xFF, (curraddr // 256) & 0xFF, curraddr & 0xFF])
            print(" Programming", j+i*16, "at", "0x{:02x}{:02x}{:02x}".format(pgbuf[0], pgbuf[1], pgbuf[2]))
                  
            ser.write(bytes([0x40]))
                      
            resp = bytes([0x00])
            while resp[0] != 0x41:
                resp = ser.read()
                if len(resp) == 0:
                    resp = bytes([0x00])
                elif resp[0] == 0x41:
                    print("  Programming processing")
                      
            ser.write(pgbuf)

            resp = bytes([0x00])
            while resp[0] != 0x42:
                resp = ser.read()
                if len(resp) == 0:
                    resp = bytes([0x00])
                elif resp[0] == 0x42:
                    print("  Programming finished")
            
            curraddr += pagestep

# reset system

ser.write(bytes([0xF0]))
ser.read()

print("")
print("Flashing completed")

ser.close()

