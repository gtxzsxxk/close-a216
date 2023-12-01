code = """3e800093
0080026f
7d008113
3e808093
00020067
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
