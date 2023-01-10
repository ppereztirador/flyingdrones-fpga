# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: /home/pperez/workspace/pcam_vdma_hdmi_blocks_system/_ide/scripts/debugger_pcam_vdma_hdmi_blocks-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source /home/pperez/workspace/pcam_vdma_hdmi_blocks_system/_ide/scripts/debugger_pcam_vdma_hdmi_blocks-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent Zybo Z7 210351B10297A" && level==0 && jtag_device_ctx=="jsn-Zybo Z7-210351B10297A-23727093-0"}
fpga -file /home/pperez/workspace/pcam_vdma_hdmi_blocks/_ide/bitstream/system_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw /home/pperez/workspace/system_wrapper/export/system_wrapper/hw/system_wrapper.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source /home/pperez/workspace/pcam_vdma_hdmi_blocks/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow /home/pperez/workspace/pcam_vdma_hdmi_blocks/Debug/pcam_vdma_hdmi_blocks.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con
