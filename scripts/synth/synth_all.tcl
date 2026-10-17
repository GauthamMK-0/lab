# ==============================================================================
# Cadence Genus Master Synthesis Script: Synthesizes all 5 simple circuits
# ==============================================================================

set designs {
    reg2reg_multiplier
    reg2reg_adder
    reg2reg_comparator
    reg2reg_mux
    reg2reg_decoder
}

puts "=================================================================="
puts " Starting Batch Synthesis for all 5 Simple Reg-to-Reg Circuits"
puts "=================================================================="

foreach d $designs {
    puts ">>> [clock format [clock seconds]] Synthesizing: $d"
    source scripts/synth/synth_${d}.tcl
    puts ">>> Completed: $d"
}

puts "=================================================================="
puts " All 5 Circuits Synthesized Successfully!"
puts "=================================================================="
