# flyngdrones-fpga
Implementation of the LHE codec in Xilinx FPGAs

## Requirements

These projects work with Vivado and Vitis IDE version 2020.2 and the Digilent Zybo-Z20 development board. Digilent's Vivado library (https://github.com/Digilent/vivado-library) is necessary to synthesize some of the video processing IP cores.

## File structure

Each of the folders contains either a Vivado or Vitis project. Unpack to use.

* `vivado-demo`: Vivado project and VHDL sources for the PR demo
* `vitis-demo`: Vitis project and C sources for the PR demo
* `vivado-onetileline`: Vivado project for processing one line of tiles
* `test-code`: Python and C code with an implementation of LHE. Includes functions to create and display test images, to test the encoding pipeline and to generate the hop look-up table.
