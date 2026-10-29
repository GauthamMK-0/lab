# Version:1.0 MMMC View Definition File
# Do Not Remove Above Line
# ==============================================================================
# MMMC Timing View Setup: reg2reg_mux (4-to-1 Multiplexer)
# Verified against mt_npu/models/pipelined/heterogeneous_fission/netlist/HDFF.view & innovus.log
# Setup (MAX): slow.lib | Hold (MIN): fast.lib | RC (CAP): gpdk090.lef.extended.CapTbl
# ==============================================================================

if {[info exists ::env(CADENCE_FOUNDRY_LIB)]} {
    set FOUNDRY_LIB_DIR $::env(CADENCE_FOUNDRY_LIB)
} else {
    set FOUNDRY_LIB_DIR "/home/cadence/install/FOUNDRY/digital/90nm/dig/lib"
}

if {[info exists ::env(CADENCE_FOUNDRY_CAP)]} {
    set CAP_TABLE_FILE $::env(CADENCE_FOUNDRY_CAP)
} else {
    set CAP_TABLE_FILE "/home/cadence/install/FOUNDRY/digital/90nm/dig/captable/gpdk090.lef.extended.CapTbl"
}

if {[file exists "netlist/reg2reg_mux_netlist.sdc"]} {
    set SDC_FILE "netlist/reg2reg_mux_netlist.sdc"
} elseif {[file exists "reg2reg_mux_netlist.sdc"]} {
    set SDC_FILE "reg2reg_mux_netlist.sdc"
} else {
    set SDC_FILE "./sdc/reg2reg_mux.sdc"
}

create_rc_corner -name CAP \
    -cap_table [list $CAP_TABLE_FILE] \
    -preRoute_res {1.0} -preRoute_cap {1.0} \
    -preRoute_clkres {0.0} -preRoute_clkcap {0.0} \
    -postRoute_res {1.0} -postRoute_cap {1.0} -postRoute_xcap {1.0} \
    -postRoute_clkres {0.0} -postRoute_clkcap {0.0}

create_library_set -name MAX -timing [list ${FOUNDRY_LIB_DIR}/slow.lib]
create_library_set -name MIN -timing [list ${FOUNDRY_LIB_DIR}/fast.lib]

create_constraint_mode -name SDC -sdc_files [list $SDC_FILE]

create_delay_corner -name SET_MAX -library_set {MAX} -rc_corner {CAP}
create_delay_corner -name HOD_MIN -library_set {MIN} -rc_corner {CAP}

create_analysis_view -name SETUP -constraint_mode {SDC} -delay_corner {SET_MAX}
create_analysis_view -name HOD   -constraint_mode {SDC} -delay_corner {HOD_MIN}

set_analysis_view -setup {SETUP} -hold {HOD}
