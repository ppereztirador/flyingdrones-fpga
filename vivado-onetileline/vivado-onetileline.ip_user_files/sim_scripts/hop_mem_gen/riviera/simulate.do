onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+hop_mem_gen -L xilinx_vip -L xpm -L blk_mem_gen_v8_4_4 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.hop_mem_gen xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {hop_mem_gen.udo}

run -all

endsim

quit -force
