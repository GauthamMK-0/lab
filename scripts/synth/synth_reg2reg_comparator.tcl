# ==============================================================================
# Cadence Genus Synthesis TCL Script: reg2reg_comparator (4-bit Magnitude Comparator)
# Verified against Cadence Genus v21.14-s082_1 log in mt_npu (genus_hdf_top.log3)
# Target Foundry Library: 90nm bulk CMOS (/home/cadence/install/FOUNDRY/digital/90nm/dig/lib/slow.lib)
# ==============================================================================

set DESIGN_NAME "reg2reg_comparator"

# --- Design & Path Configurations (from mt_npu/synth_hdf.tcl & genus_hdf_top.log3) ---
set_db use_scan_seqs_for_non_dft false

if {[info exists ::env(CADENCE_FOUNDRY_LIB)]} {
    set_db init_lib_search_path [list $::env(CADENCE_FOUNDRY_LIB)]
} else {
    set_db init_lib_search_path {/home/cadence/install/FOUNDRY/digital/90nm/dig/lib/}
}

# Target design RTL directory
set_db init_hdl_search_path {./rtl}

# Read target technology library (slow.lib: PVT 1.0, 0.9V, 125C)
read_libs slow.lib

# --- Read RTL Source ---
read_hdl -v2001 [list ${DESIGN_NAME}.v]

# --- Elaborate Top-Level Design ---
elaborate ${DESIGN_NAME}
init_design

# --- Load Timing Constraints (200 MHz / 5.000 ns clock period) ---
if {[file exists ./sdc/${DESIGN_NAME}.sdc]} {
    read_sdc ./sdc/${DESIGN_NAME}.sdc
} elseif {[file exists ${DESIGN_NAME}.sdc]} {
    read_sdc ${DESIGN_NAME}.sdc
} else {
    # Default fallback matching mt_npu/synth_hdf.tcl (200 MHz / 5.000 ns clock on clk)
    create_clock -name clk -period 5.000 [get_ports clk]
    set_clock_uncertainty 0.050 [get_clocks clk]
    set_clock_transition  0.050 [get_clocks clk]
    set_input_delay  0.500 -clock clk [all_inputs -no_clocks]
    set_output_delay 0.500 -clock clk [all_outputs]
    set_driving_cell -lib_cell INVX1 [all_inputs -no_clocks]
    set_load 0.010 [all_outputs]
}

# --- Synthesis Effort Controls (from genus_hdf_top.log3) ---
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

# --- Synthesis Execution ---
syn_generic
syn_map
syn_opt

# --- Timing, Power (Joules Engine), Area, Gates, and QoR Reports ---
file mkdir reports
report_timing > reports/timing_${DESIGN_NAME}.rpt
report_power  > reports/power_${DESIGN_NAME}.rpt
report_area   > reports/area_${DESIGN_NAME}.rpt
report_qor    > reports/qor_${DESIGN_NAME}.rpt
report_gates  > reports/gates_${DESIGN_NAME}.rpt

# --- Netlist, SDC & Gate-Level SDF Generation (for Conformal LEC & Innovus PnR) ---
file mkdir netlist
write_hdl > netlist/${DESIGN_NAME}_netlist.v
write_sdc > netlist/${DESIGN_NAME}_netlist.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > netlist/${DESIGN_NAME}_netlist.sdf

puts "=================================================================="
puts " \[SYNTHESIS EXECUTIVE SUMMARY: ${DESIGN_NAME} @ 200 MHz\]"
puts "=================================================================="
report_qor
report_area
report_timing
puts "=================================================================="
puts " Genus Synthesis Finished Successfully! Check reports/ and netlist/ for details."
puts "=================================================================="
