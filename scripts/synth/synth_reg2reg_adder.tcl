# ==============================================================================
# Cadence Genus Synthesis TCL Script: reg2reg_adder (4-bit Adder)
# Target Foundry Library: 90nm bulk CMOS (slow.lib)
# ==============================================================================

set DESIGN_NAME "reg2reg_adder"

# --- Design & Path Configurations ---
set_db use_scan_seqs_for_non_dft false

# Library search path referenced from mt_npu
if {[info exists ::env(CADENCE_FOUNDRY_LIB)]} {
    set_db init_lib_search_path [list $::env(CADENCE_FOUNDRY_LIB)]
} else {
    set_db init_lib_search_path {/home/cadence/install/FOUNDRY/digital/90nm/dig/lib/}
}

# Target design directory
set_db init_hdl_search_path {./rtl}

# Read target technology library
read_libs slow.lib

# --- Read RTL Source ---
read_hdl -v2001 [list ./rtl/${DESIGN_NAME}.v]

# --- Elaborate Top Level Design ---
elaborate ${DESIGN_NAME}
init_design

# --- Load Timing Constraints ---
if {[file exists ./sdc/${DESIGN_NAME}.sdc]} {
    read_sdc ./sdc/${DESIGN_NAME}.sdc
} else {
    create_clock -name clk -period 5.000 [get_ports clk]
    set_clock_uncertainty 0.050 [get_clocks clk]
    set_clock_transition  0.050 [get_clocks clk]
    set_input_delay  0.500 -clock clk [all_inputs -no_clocks]
    set_output_delay 0.500 -clock clk [all_outputs]
    set_driving_cell -lib_cell INVX1 [all_inputs -no_clocks]
    set_load 0.010 [all_outputs]
}

# --- Synthesis Effort Controls ---
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

# --- Synthesis Execution ---
syn_generic
syn_map
syn_opt

# --- Timing, Power, Area, and Summary Reports ---
file mkdir reports
report_timing > reports/timing_${DESIGN_NAME}.rpt
report_power  > reports/power_${DESIGN_NAME}.rpt
report_area   > reports/area_${DESIGN_NAME}.rpt
report_qor    > reports/qor_${DESIGN_NAME}.rpt
report_gates  > reports/gates_${DESIGN_NAME}.rpt
catch { report_summary > reports/summary_${DESIGN_NAME}.rpt }

# --- Netlist & Gate-Level Files Generation ---
file mkdir netlist
write_hdl > netlist/${DESIGN_NAME}_netlist.v
write_sdc > netlist/${DESIGN_NAME}_netlist.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > netlist/${DESIGN_NAME}_netlist.sdf

puts "=================================================================="
puts " \[SYNTHESIS EXECUTIVE SUMMARY: ${DESIGN_NAME} @ 200 MHz\]"
puts "=================================================================="
report_qor
report_area
puts "=================================================================="
puts " Genus Synthesis Finished Successfully! Check reports/ and netlist/."
puts "=================================================================="
