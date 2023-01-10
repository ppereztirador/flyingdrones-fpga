onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib hop_mem_gen_opt

do {wave.do}

view wave
view structure
view signals

do {hop_mem_gen.udo}

run -all

quit -force
