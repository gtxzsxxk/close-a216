#!/usr/bin/python3

import sys

hex_path = sys.argv[1]

fp = open(hex_path,"r")
hexfile = fp.read()
fp.close()

rom_lines = ""

quartus_hex = ""

word_counter_total = 0

lines = hexfile.split("\n")
for i in lines:
    if len(i) < 4:
        continue
    data_length = int(i[1:3], 16)
    start_addr = int(i[3:7], 16)
    start_addr_div = int(start_addr / 4)
    word_counter = 0
    word_str_tmp = ""
    word_str = ""
    checksum = (
            4 + word_counter_total
    )
    for j in range(0, data_length):
        idx = int(9 + 2 * j)
        one_byte = i[idx : idx + 2]
        data = int(one_byte, 16)
        checksum += data
        rom_lines += "rom[%d] <= 8'h%02x;\r\n" % (start_addr + j, data)
        word_str_tmp += "%02x" % data
        word_counter += 1
        if word_counter == 4:
            word_str = (
                    word_str_tmp[6:8]
                    + word_str_tmp[4:6]
                    + word_str_tmp[2:4]
                    + word_str_tmp[0:2]
            )
            quartus_hex += ":04%04x00%s"%(word_counter_total,word_str)
            word_counter = 0
            word_str_tmp = ""
            word_counter_total += 1
            checksum = (~checksum) + 1
            checksum &= 0xFF
            quartus_hex += "%02x\r\n" % checksum
            checksum = (
                    4 + word_counter_total
            )


    rom_lines += "\r\n"

quartus_hex += ":00000001FF"

fp = open(hex_path,"w")
fp.write(quartus_hex)
fp.close()

print("Quartus hex file generated!")
