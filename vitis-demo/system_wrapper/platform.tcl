# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct /home/pperez/workspace/system_wrapper/platform.tcl
# 
# OR launch xsct and run below command.
# source /home/pperez/workspace/system_wrapper/platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {system_wrapper}\
-hw {/home/pperez/zybo_pcam_extrablocks/system_wrapper.xsa}\
-fsbl-target {psu_cortexa53_0} -out {/home/pperez/workspace}

platform write
domain create -name {standalone_ps7_cortexa9_0} -display-name {standalone_ps7_cortexa9_0} -os {standalone} -proc {ps7_cortexa9_0} -runtime {cpp} -arch {32-bit} -support-app {empty_application}
platform generate -domains 
platform active {system_wrapper}
domain active {zynq_fsbl}
domain active {standalone_ps7_cortexa9_0}
platform generate -quick
platform generate
platform clean
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/pcam_demo1/system_wrapper.xsa}
platform generate
platform config -updatehw {/home/pperez/pcam_demo1/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
domain active {zynq_fsbl}
domain active {standalone_ps7_cortexa9_0}
bsp reload
bsp reload
platform generate
platform generate
platform generate
platform active {system_wrapper}
platform active {system_wrapper}
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/DATA/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_extrablocks/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform generate
bsp reload
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
domain active {zynq_fsbl}
bsp reload
domain active {standalone_ps7_cortexa9_0}
bsp reload
catch {bsp regenerate}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform active {system_wrapper}
domain active {zynq_fsbl}
bsp reload
domain active {standalone_ps7_cortexa9_0}
bsp reload
bsp reload
bsp setlib -name lwip211 -ver 1.3
bsp write
bsp reload
catch {bsp regenerate}
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform config -updatehw {/home/pperez/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
bsp reload
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform clean
platform generate
platform clean
platform generate
platform active {system_wrapper}
platform generate -domains 
platform clean
platform generate
platform generate -domains standalone_ps7_cortexa9_0 
platform active {system_wrapper}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
platform generate
platform active {system_wrapper}
domain active {zynq_fsbl}
bsp reload
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_spaceoptimized/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate -domains 
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate -domains 
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
domain active {zynq_fsbl}
bsp reload
domain active {standalone_ps7_cortexa9_0}
bsp reload
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform generate
platform active {system_wrapper}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_onetileline/system_wrapper.xsa}
platform config -updatehw {/home/pperez/lhe-vhdl/zybo_pcam_fixedimage/system_wrapper.xsa}
platform generate -domains 
platform active {system_wrapper}
platform config -updatehw {/home/pperez/flyingdrones-fpga/vivado-demo/system_wrapper.xsa}
platform generate -domains standalone_ps7_cortexa9_0,zynq_fsbl 
