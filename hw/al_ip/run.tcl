import_device eagle_s20.db  -package BG256 -basic
read_verilog -file F:/td_projects/tang_picorv32/al_ip/pll.v
optimize_rtl
map_macro -nopad
write_verilog F:/td_projects/tang_picorv32/al_ip/pll_sim.v
