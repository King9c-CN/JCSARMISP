create_clock -name clk -period 41.6 -waveform {20.8 41.6} [get_ports {clk}] -add
derive_pll_clocks