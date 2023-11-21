transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/fpga/a216/rtl {D:/fpga/a216/rtl/irom.v}

vlog -vlog01compat -work work +incdir+D:/fpga/a216/simulation/modelsim {D:/fpga/a216/simulation/modelsim/irom.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  irom_vlg_tst

add wave *
view structure
view signals
run -all
