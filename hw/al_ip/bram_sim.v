// Verilog netlist created by TD v4.2.511
// Mon Dec  3 20:28:23 2018

`timescale 1ns / 1ps
module bram32_1k  // F:/td_projects/tang_picorv32/al_ip/bram.v(14)
  (
  addra,
  cea,
  clka,
  dia,
  rsta,
  wea,
  doa
  );

  input [9:0] addra;  // F:/td_projects/tang_picorv32/al_ip/bram.v(19)
  input cea;  // F:/td_projects/tang_picorv32/al_ip/bram.v(21)
  input clka;  // F:/td_projects/tang_picorv32/al_ip/bram.v(22)
  input [31:0] dia;  // F:/td_projects/tang_picorv32/al_ip/bram.v(18)
  input rsta;  // F:/td_projects/tang_picorv32/al_ip/bram.v(23)
  input [3:0] wea;  // F:/td_projects/tang_picorv32/al_ip/bram.v(20)
  output [31:0] doa;  // F:/td_projects/tang_picorv32/al_ip/bram.v(16)


  EG_PHY_CONFIG #(
    .DONE_PERSISTN("ENABLE"),
    .INIT_PERSISTN("ENABLE"),
    .JTAG_PERSISTN("DISABLE"),
    .PROGRAMN_PERSISTN("DISABLE"))
    config_inst ();
  // address_offset=0;data_offset=0;depth=1024;width=8;num_section=1;width_per_section=8;section_size=32;working_depth=1024;working_width=9;address_step=1;bytes_in_per_section=1;
  EG_PHY_BRAM #(
    .CEBMUX("0"),
    .CLKBMUX("0"),
    .CSA0("1"),
    .CSA1("1"),
    .CSA2("1"),
    .CSB0("1"),
    .CSB1("1"),
    .CSB2("1"),
    .DATA_WIDTH_A("9"),
    .DATA_WIDTH_B("9"),
    .MODE("SP8K"),
    .OCEAMUX("0"),
    .OCEBMUX("0"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("SYNC"),
    .RSTBMUX("0"),
    .WEBMUX("0"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"))
    inst_1024x32_sub_000000_000 (
    .addra({addra,3'b111}),
    .cea(cea),
    .clka(clka),
    .dia({open_n68,dia[7:0]}),
    .rsta(rsta),
    .wea(wea[0]),
    .doa({open_n82,doa[7:0]}));
  // address_offset=0;data_offset=8;depth=1024;width=8;num_section=1;width_per_section=8;section_size=32;working_depth=1024;working_width=9;address_step=1;bytes_in_per_section=1;
  EG_PHY_BRAM #(
    .CEBMUX("0"),
    .CLKBMUX("0"),
    .CSA0("1"),
    .CSA1("1"),
    .CSA2("1"),
    .CSB0("1"),
    .CSB1("1"),
    .CSB2("1"),
    .DATA_WIDTH_A("9"),
    .DATA_WIDTH_B("9"),
    .MODE("SP8K"),
    .OCEAMUX("0"),
    .OCEBMUX("0"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("SYNC"),
    .RSTBMUX("0"),
    .WEBMUX("0"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"))
    inst_1024x32_sub_000000_008 (
    .addra({addra,3'b111}),
    .cea(cea),
    .clka(clka),
    .dia({open_n113,dia[15:8]}),
    .rsta(rsta),
    .wea(wea[1]),
    .doa({open_n127,doa[15:8]}));
  // address_offset=0;data_offset=16;depth=1024;width=8;num_section=1;width_per_section=8;section_size=32;working_depth=1024;working_width=9;address_step=1;bytes_in_per_section=1;
  EG_PHY_BRAM #(
    .CEBMUX("0"),
    .CLKBMUX("0"),
    .CSA0("1"),
    .CSA1("1"),
    .CSA2("1"),
    .CSB0("1"),
    .CSB1("1"),
    .CSB2("1"),
    .DATA_WIDTH_A("9"),
    .DATA_WIDTH_B("9"),
    .MODE("SP8K"),
    .OCEAMUX("0"),
    .OCEBMUX("0"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("SYNC"),
    .RSTBMUX("0"),
    .WEBMUX("0"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"))
    inst_1024x32_sub_000000_016 (
    .addra({addra,3'b111}),
    .cea(cea),
    .clka(clka),
    .dia({open_n158,dia[23:16]}),
    .rsta(rsta),
    .wea(wea[2]),
    .doa({open_n172,doa[23:16]}));
  // address_offset=0;data_offset=24;depth=1024;width=8;num_section=1;width_per_section=8;section_size=32;working_depth=1024;working_width=9;address_step=1;bytes_in_per_section=1;
  EG_PHY_BRAM #(
    .CEBMUX("0"),
    .CLKBMUX("0"),
    .CSA0("1"),
    .CSA1("1"),
    .CSA2("1"),
    .CSB0("1"),
    .CSB1("1"),
    .CSB2("1"),
    .DATA_WIDTH_A("9"),
    .DATA_WIDTH_B("9"),
    .MODE("SP8K"),
    .OCEAMUX("0"),
    .OCEBMUX("0"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("SYNC"),
    .RSTBMUX("0"),
    .WEBMUX("0"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"))
    inst_1024x32_sub_000000_024 (
    .addra({addra,3'b111}),
    .cea(cea),
    .clka(clka),
    .dia({open_n203,dia[31:24]}),
    .rsta(rsta),
    .wea(wea[3]),
    .doa({open_n217,doa[31:24]}));

endmodule 

