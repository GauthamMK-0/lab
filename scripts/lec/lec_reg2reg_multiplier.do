// ==============================================================================
// Cadence Conformal LEC Dofile: reg2reg_multiplier (2-bit Multiplier)
// Verification: Golden RTL (rtl/reg2reg_multiplier.v) vs Revised Netlist (netlist/reg2reg_multiplier_netlist.v)
// ==============================================================================

// Step 1: Initialize Log File
set log file reports/lec_reg2reg_multiplier.log -replace

// Step 2: Read Foundry 90nm Standard Cell Liberty Library (slow.lib)
read library -liberty -both /home/cadence/install/FOUNDRY/digital/90nm/dig/lib/slow.lib

// Step 3: Load & Elaborate Golden RTL Design
read design -verilog -golden -noelaborate rtl/reg2reg_multiplier.v
elaborate design -golden -root reg2reg_multiplier

// Step 4: Load & Elaborate Revised Gate-Level Netlist
read design -verilog -revised -noelaborate netlist/reg2reg_multiplier_netlist.v
elaborate design -revised -root reg2reg_multiplier

// Step 5: Switch System Mode from Setup to LEC
set system mode lec

// Step 6: Map Key Points and Identify Compare Points
map key points
add compare points -all

// Step 7: Run Formal Equivalence Comparison
compare

// Step 8: Generate Detailed Verification & Diagnosis Reports
report verification -verbose > reports/lec_reg2reg_multiplier_verify.rpt
report compare data -class nonequivalent > reports/lec_reg2reg_multiplier_noneq.rpt
report statistics > reports/lec_reg2reg_multiplier_stats.rpt

// Step 9: Open GUI for Interactive Inspection (uncomment 'exit -force' for batch exit)
set gui on
// exit -force
