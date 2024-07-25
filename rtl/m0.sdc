create_clock -name clk -period 41.6 -waveform {20.8 41.6} [get_ports {clk}] -add
derive_pll_clocks
rename_clock -name {24} -source [get_ports {sys_clk}] -master_clock {sys_clk} [get_pins {clk_gen_inst/pll_inst.clkc[0]}]
rename_clock -name {96} -source [get_ports {sys_clk}] -master_clock {sys_clk} [get_pins {clk_gen_inst/pll_inst.clkc[2]}]
rename_clock -name {148} -source [get_ports {sys_clk}] -master_clock {sys_clk} [get_pins {clk_gen_inst/pll_inst.clkc[3]}]
rename_clock -name {200} -source [get_ports {sys_clk}] -master_clock {sys_clk} [get_pins {clk_gen_inst/pll_inst.clkc[4]}]