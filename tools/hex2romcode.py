code = """00c00093
0140b103
00517233
00616433
002204b3
407300b3
"""

code_lines = code.split("\n")

rom_cnt = 0
rom_lines = ""

for i in code_lines:
    if i == "":
        continue
    for j in range(0, 4):
        rom_lines += "rom[%d] = 8'h%s%s;\r\n" % (
            rom_cnt + j,
            i[7 - 2 * j - 1],
            i[7 - 2 * j],
        )
    rom_lines += "\r\n"
    rom_cnt += 4

print(rom_lines)
