// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Thu Sep 15 17:10:41 2022
// Host        : 55EPS98L232LINU running 64-bit Ubuntu 20.04.5 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/pperez/lhe-vhdl/zybo_pcam_fixedimage/zybo_pcam_fixedimage.srcs/sources_1/ip/hop_mem_gen/hop_mem_gen_stub.v
// Design      : hop_mem_gen
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2020.2" *)
module hop_mem_gen(clka, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[14:0],dina[7:0],clkb,enb,addrb[14:0],doutb[7:0]" */;
  input clka;
  input [0:0]wea;
  input [14:0]addra;
  input [7:0]dina;
  input clkb;
  input enb;
  input [14:0]addrb;
  output [7:0]doutb;
endmodule
