# ==============================================================================
# Cadence Innovus Physical Design Script: reg2reg_multiplier (2-bit Multiplier)
# Verified against Cadence Innovus v21.15-s110_1 log in mt_npu:
#   mt_npu/models/pipelined/heterogeneous_fission/netlist/innovus.log
#   mt_npu/models/pipelined/heterogeneous_fission/netlist/innovus.cmd
#   mt_npu/models/pipelined/heterogeneous_fission/netlist/cts.tcl
# ==============================================================================

set DESIGN_NAME  "reg2reg_multiplier"
set NETLIST_FILE "netlist/${DESIGN_NAME}_netlist.v"
set MMMC_FILE    "scripts/innovus/mmmc_${DESIGN_NAME}.tcl"

if {[info exists ::env(CADENCE_FOUNDRY_LEF)]} {
    set LEF_FILE $::env(CADENCE_FOUNDRY_LEF)
} else {
    set LEF_FILE "/home/cadence/install/FOUNDRY/digital/90nm/dig/lef/gsclib090_translated.lef"
}

if {![file exists $NETLIST_FILE]} {
    error "ERROR: Synthesized netlist $NETLIST_FILE not found. Please run Genus synthesis first!"
}

file mkdir reports
file mkdir pnr
file mkdir pnr/DBS

# ------------------------------------------------------------------------------
# 1. Design Initialization & Sanity Check (innovus.cmd lines 16-29)
# ------------------------------------------------------------------------------
set_global _enable_mmmc_by_default_flow $CTE::mmmc_default
suppressMessage ENCEXT-2799

set init_gnd_net   VSS
set init_lef_file  $LEF_FILE
set init_verilog   $NETLIST_FILE
set init_mmmc_file $MMMC_FILE
set init_pwr_net   VDD
set init_top_cell  $DESIGN_NAME

init_design
checkDesign -all

# ------------------------------------------------------------------------------
# 2. Floorplanning (innovus.cmd lines 34-35: gsclib090site, 70% density, 20um margins)
# ------------------------------------------------------------------------------
setIoFlowFlag 0
floorPlan -coreMarginsBy die -site gsclib090site -r 1 0.7 20 20 20 20
fit

# ------------------------------------------------------------------------------
# 3. Global Net Connections & Power Planning (innovus.cmd lines 39-85)
# ------------------------------------------------------------------------------
globalNetConnect VDD -type pgpin -pin VDD -inst * -module {}
globalNetConnect VSS -type pgpin -pin VSS -inst * -module {}
globalNetConnect VDD -type tiehi -inst * -module {}
globalNetConnect VSS -type tielo -inst * -module {}

set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0

setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 \
    -skip_crossing_trunks none -stacked_via_top_layer Metal9 -stacked_via_bottom_layer Metal1 \
    -via_using_exact_crossover_size 1 -orthogonal_only true \
    -skip_via_on_pin { standardcell } -skip_via_on_wire_shape { noshape }

addRing -nets {VDD VSS} -type core_rings -follow core \
    -layer {top Metal9 bottom Metal9 left Metal8 right Metal8} \
    -width {top 4 bottom 4 left 4 right 4} \
    -spacing {top 4 bottom 4 left 4 right 4} \
    -offset {top 4 bottom 4 left 4 right 4} \
    -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None

setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false \
    -rows_without_stripes_only false -extend_to_closest_target none \
    -stop_at_last_wire_for_area false -partial_set_thru_domain false \
    -ignore_nondefault_domains false -trim_antenna_back_to_shape none \
    -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width \
    -stacked_via_top_layer Metal9 -stacked_via_bottom_layer Metal1 \
    -via_using_exact_crossover_size false -split_vias false -orthogonal_only true \
    -allow_jog { padcore_ring block_ring } -skip_via_on_pin { standardcell } \
    -skip_via_on_wire_shape { noshape }

addStripe -nets {VDD VSS} -layer Metal9 -direction horizontal -width 4 -spacing 4 \
    -number_of_sets 6 -start_from bottom -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal9 \
    -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal9 \
    -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None

setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false \
    -rows_without_stripes_only false -extend_to_closest_target none \
    -stop_at_last_wire_for_area false -partial_set_thru_domain false \
    -ignore_nondefault_domains false -trim_antenna_back_to_shape none \
    -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width \
    -stacked_via_top_layer Metal9 -stacked_via_bottom_layer Metal1 \
    -via_using_exact_crossover_size false -split_vias false -orthogonal_only true \
    -allow_jog { padcore_ring block_ring } -skip_via_on_pin { standardcell } \
    -skip_via_on_wire_shape { noshape }

addStripe -nets {VDD VSS} -layer Metal8 -direction vertical -width 4 -spacing 4 \
    -number_of_sets 6 -start_from left -switch_layer_over_obs false \
    -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit Metal9 \
    -padcore_ring_bottom_layer_limit Metal1 -block_ring_top_layer_limit Metal9 \
    -block_ring_bottom_layer_limit Metal1 -use_wire_group 0 -snap_wire_center_to_grid None

setSrouteMode -viaConnectToShape { noshape }
sroute -connect { blockPin padPin padRing corePin floatingStripe } \
    -layerChangeRange { Metal1(1) Metal9(9) } \
    -blockPinTarget { nearestTarget } \
    -padPinPortConnect { allPort oneGeom } \
    -padPinTarget { nearestTarget } \
    -corePinTarget { firstAfterRowEnd } \
    -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } \
    -allowJogging 1 \
    -crossoverViaLayerRange { Metal1(1) Metal9(9) } \
    -nets { VDD VSS } \
    -allowLayerChange 1 \
    -blockPin useLef \
    -targetViaLayerRange { Metal1(1) Metal9(9) }

saveDesign pnr/${DESIGN_NAME}_power.enc

# ------------------------------------------------------------------------------
# 4. Pre-Place Optimization, Standard Cell Placement & Pre-CTS Opt (innovus.cmd lines 86-104)
# ------------------------------------------------------------------------------
timeDesign -prePlace -setup -outDir reports/timingReports_${DESIGN_NAME}
optDesign -prePlace -setup
optDesign -prePlace

setPlaceMode -fp false
place_design
timeDesign -preCTS -outDir reports/timingReports_${DESIGN_NAME}

setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setNanoRouteMode -quiet -droutePostRouteSpreadWire 1
setNanoRouteMode -quiet -droutePostRouteWidenWireRule LEFDefaultRouteSpec_gpdk090
setNanoRouteMode -quiet -timingEngine {}
setUsefulSkewMode -noBoundary false -maxAllowedDelay 1

setPlaceMode -reset
setPlaceMode -congEffort auto -timingDriven 1 -clkGateAware 1 -powerDriven 0 \
    -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 1 \
    -moduleAwareSpare 0 -preserveRouting 1 -rmAffectedRouting 0 \
    -checkRoute 0 -swapEEQ 0
setPlaceMode -fp false
place_design
optDesign -preCTS

checkPlace reports/check_place_${DESIGN_NAME}.rpt
defOut -floorplan -netlist -routing pnr/${DESIGN_NAME}_placed.def
saveDesign pnr/${DESIGN_NAME}_placed.enc

# ------------------------------------------------------------------------------
# 5. Clock Tree Synthesis (CCOpt) & Post-CTS Optimization (cts.tcl & innovus.cmd lines 111-176)
# ------------------------------------------------------------------------------
add_ndr -width {Metal1 0.14 Metal2 0.16 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.46 Metal9 0.46 } \
        -spacing {Metal1 0.14 Metal2 0.16 Metal3 0.14 Metal4 0.14 Metal5 0.14 Metal6 0.14 Metal7 0.14 Metal8 0.46 Metal9 0.46 } \
        -name 2w2s
create_route_type -name clkroute -non_default_rule 2w2s \
    -bottom_preferred_layer Metal5 -top_preferred_layer Metal6
set_ccopt_property route_type clkroute -net_type trunk
set_ccopt_property route_type clkroute -net_type leaf
set_ccopt_property buffer_cells {CLKBUFX6 CLKBUFX8 CLKBUFX12}
set_ccopt_property inverter_cells {CLKINVX6 CLKINVX8 CLKINVX12}
set_ccopt_property clock_gating_cells TLATNTSCA*
set_ccopt_property target_max_trans 0.5

create_ccopt_clock_tree_spec -file pnr/ccopt_${DESIGN_NAME}.spec
source pnr/ccopt_${DESIGN_NAME}.spec
ccopt_design -cts

saveDesign pnr/DBS/${DESIGN_NAME}_cts.enc
report_ccopt_clock_trees -file reports/clk_trees_${DESIGN_NAME}.rpt
report_ccopt_skew_groups -file reports/skew_groups_${DESIGN_NAME}.rpt

timeDesign -postCTS -setup -hold -outDir reports/timingReports_${DESIGN_NAME}
optDesign -postCTS -setup -hold
optDesign -postCTS -hold

global dbgLefDefOutVersion
set dbgLefDefOutVersion 5.8
defOut -floorplan -netlist -routing pnr/${DESIGN_NAME}_cts.def
saveDesign pnr/${DESIGN_NAME}_cts.enc

# ------------------------------------------------------------------------------
# 6. NanoRoute Global/Detail Routing, Fillers & Post-Route Opt (innovus.cmd lines 189-223)
# ------------------------------------------------------------------------------
setNanoRouteMode -quiet -routeTopRoutingLayer 9
setNanoRouteMode -quiet -routeBottomRoutingLayer 1
setNanoRouteMode -quiet -drouteEndIteration 1
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
routeDesign -globalDetail

addFiller -cell FILL1 FILL2 FILL4 FILL8 FILL16 -prefix FILLER

timeDesign -postRoute -setup -hold -outDir reports/timingReports_${DESIGN_NAME}
setAnalysisMode -analysisType onChipVariation -cppr both
timeDesign -postRoute -setup -hold -outDir reports/timingReports_${DESIGN_NAME}
optDesign -postRoute -setup -hold

report_timing -machine_readable -max_paths 10000 -max_slack 0.75 -path_exceptions all -late > reports/${DESIGN_NAME}_top.mtarpt
report_timing > reports/placement_timing_${DESIGN_NAME}.rpt

saveDesign pnr/${DESIGN_NAME}_routed.enc
set dbgLefDefOutVersion 5.8
defOut -floorplan -netlist -routing pnr/${DESIGN_NAME}.def
defOut -floorplan -netlist -routing pnr/${DESIGN_NAME}_routed.def

report_power > reports/placement_power_${DESIGN_NAME}.rpt

puts "=================================================================="
puts " Innovus Physical Design Completed Successfully for: $DESIGN_NAME"
puts "=================================================================="
