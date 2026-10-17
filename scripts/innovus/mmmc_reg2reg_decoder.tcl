# ==============================================================================
# MMMC Timing View Setup: reg2reg_decoder (2-to-4 Decoder)
# Target Foundry Library: 90nm slow.lib @ 200 MHz
# ==============================================================================

if {[info exists ::env(CADENCE_FOUNDRY_LIB)]} {
    set FOUNDRY_LIB_DIR $::env(CADENCE_FOUNDRY_LIB)
} else {
    set FOUNDRY_LIB_DIR "/home/cadence/install/FOUNDRY/digital/90nm/dig/lib"
}

# 1. Define Library Set (Worst-Case Timing)
create_library_set -name slow_lib \
    -timing [list ${FOUNDRY_LIB_DIR}/slow.lib]

# 2. Define Constraint Mode (SDC)
create_constraint_mode -name functional_mode \
    -sdc_files [list ./sdc/reg2reg_decoder.sdc]

# 3. Define RC Parasitic Corner
create_rc_corner -name rc_worst \
    -temperature 125 \
    -preRoute_res 1.0 -preRoute_cap 1.0 \
    -postRoute_res 1.0 -postRoute_cap 1.0

# 4. Define Delay Corner
create_delay_corner -name delay_slow \
    -library_set slow_lib \
    -rc_corner rc_worst

# 5. Define Analysis View
create_analysis_view -name view_setup \
    -constraint_mode functional_mode \
    -delay_corner delay_slow

# 6. Set Active Analysis Views for Innovus
set_analysis_view -setup [list view_setup] -hold [list view_setup]
