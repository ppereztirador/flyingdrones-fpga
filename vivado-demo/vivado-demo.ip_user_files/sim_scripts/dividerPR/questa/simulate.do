onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib dividerPR_opt

do {wave.do}

view wave
view structure
view signals

do {dividerPR.udo}

run -all

quit -force
