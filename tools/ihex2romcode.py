hexfile = """:1000000093810100172102001301C1FF138501E054
:10001000938581E093028014630CB50003A3020072
:10002000232065009382420013054500E318B5FEC6
:10003000138581E0938581E093020015630CB50080
:1000400003A3020003230500938242001305450029
:10005000E318B5FEEF00C005130101FD2326810260
:1000600013040103232EA4FC232604FE83A701E02E
:100070002324F4FE6F00C0018327C4FE938717007A
:100080002326F4FE832784FE938717002324F4FE9F
:10009000832784FE83C70700E39007FE8327C4FEFF
:1000A000138507000324C1021301010367800000C8
:1000B000130101FE232E1100232C810013040102E1
:1000C00083A701E013850700EFF01FF92324A4FEA6
:1000D000B7470140938707801307500023A4E70028
:1000E000232604FE6F00400403A701E08327C4FE1B
:1000F000B307F70003C70700B7470140938707809E
:1001000023A2E70013000000B74701409387078050
:1001100083A7070093F70704E38807FE8327C4FE3D
:10012000938717002326F4FE0327C4FE832784FE4B
:08013000E34CF7FA6FF0DFFA6F
:1001380048656C6C6F20576F726C64210D0A000063
:08014800380100000000000076
:00000001FF

"""

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

print(quartus_hex)
