// ==============================================================================
// Cadence Conformal LEC Dofile: reg2reg_comparator (4-bit Comparator)
// Verification: Golden RTL (rtl/reg2reg_comparator.v) vs Revised Netlist (netlist/reg2reg_comparator_netlist.v)
// ==============================================================================

// Step 1: Initialize Log File
set log file reports/lec_reg2reg_comparator.log -replace

// Step 2: Read Foundry 90nm Standard Cell Liberty Library (slow.lib)
read library -liberty -both /home/cadence/install/FOUNDRY/digital/90nm/dig/lib/slow.lib

// Step 3: Load & Elaborate Golden RTL Design
read design -verilog -golden -noelaborate rtl/reg2reg_comparator.v
elaborate design -golden -root reg2reg_comparator

// Step 4: Load & Elaborate Revised Gate-Level Netlist
read design -verilog -revised -noelaborate netlist/reg2reg_comparator_netlist.v
elaborate design -revised -root reg2reg_comparator

// Step 5: Switch System Mode from Setup to LEC
set system mode lec

// Step 6: Map Key Points and Identify Compare Points
map key points
add compare points -all

// Step 7: Run Formal Equivalence Comparison
compare

// Step 8: Generate Detailed Verification & Diagnosis Reports
report verification -verbose > reports/lec_reg2reg_comparator_verify.rpt
report compare data -class nonequivalent > reports/lec_reg2reg_comparator_noneq.rpt
report statistics > reports/lec_reg2reg_comparator_stats.rpt

// Step 9: Exit
exit -force
