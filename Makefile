SRC = $(wildcard *.v test/*.v)

all: top_module

top_module: $(SRC)
	iverilog -o wave $(SRC)
	vvp -n wave
	gtkwave wave.vcd