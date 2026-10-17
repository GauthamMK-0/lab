# ==============================================================================
# Cadence Innovus Master Placement Script: Run placement for all 5 simple designs
# ==============================================================================

source scripts/innovus/place_common.tcl

set designs {
    reg2reg_multiplier
    reg2reg_adder
    reg2reg_comparator
    reg2reg_mux
    reg2reg_decoder
}

puts "=================================================================="
puts " Starting Batch Placement for all 5 Simple Reg-to-Reg Circuits"
puts "=================================================================="

foreach d $designs {
    puts ">>> [clock format [clock seconds]] Placing: $d"
    run_innovus_placement $d
    puts ">>> Completed: $d"
}

puts "=================================================================="
puts " All 5 Circuits Placed Successfully!"
puts "=================================================================="
