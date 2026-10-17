# ==============================================================================
# Cadence Innovus Common Placement Procedure
# Verified against Cadence Innovus Stylus Common UI & Legacy Encounter UI
# ==============================================================================

proc run_innovus_placement {design_name} {
    puts "=================================================================="
    puts " Launching Cadence Innovus Placement Flow for: $design_name"
    puts "=================================================================="

    set netlist_file "netlist/${design_name}_netlist.v"
    set mmmc_file    "scripts/innovus/mmmc_${design_name}.tcl"

    # Foundry LEF search path referenced from mt_npu
    if {[info exists ::env(CADENCE_FOUNDRY_LEF)]} {
        set lef_file $::env(CADENCE_FOUNDRY_LEF)
    } else {
        set lef_file "/home/cadence/install/FOUNDRY/digital/90nm/dig/lef/all.lef"
    }

    # Verify input netlist exists
    if {![file exists $netlist_file]} {
        error "ERROR: Synthesized netlist $netlist_file not found. Please run synthesis first!"
    }

    file mkdir reports
    file mkdir pnr

    # Detect if running in Stylus Common UI (innovus -stylus) or Legacy UI
    set is_stylus 0
    if {[info commands is_common_ui] ne "" && [is_common_ui]} {
        set is_stylus 1
    }

    if {$is_stylus} {
        puts ">>> Detected Cadence Innovus Stylus Common UI Mode"

        # 1. Design Initialization
        set_db init_netlist_files [list $netlist_file]
        set_db init_top_cell $design_name
        set_db init_lef_files [list $lef_file]
        set_db init_power_nets {VDD}
        set_db init_ground_nets {VSS}

        read_mmmc $mmmc_file
        init_design

        # 2. Floorplanning: 70% core utilization, 10um margin
        create_floorplan -core_utilization 0.70 -aspect_ratio 1.0 -core_margin {10.0 10.0 10.0 10.0}

        # 3. Global Net Connections for Power & Ground
        connect_global_net VDD -type pg_pin -pin_base_name VDD -inst_base_name *
        connect_global_net VSS -type pg_pin -pin_base_name VSS -inst_base_name *
        connect_global_net VDD -type tie_hi
        connect_global_net VSS -type tie_lo

        # 4. Standard Cell Placement & Pre-CTS Timing Optimization
        set_db place_opt_congestion_effort high
        place_opt_design

        # 5. Placement Validation & Reports
        check_place -report reports/check_place_${design_name}.rpt
        report_timing > reports/placement_timing_${design_name}.rpt
        report_power  > reports/placement_power_${design_name}.rpt
        report_area   > reports/placement_area_${design_name}.rpt
        report_qor    > reports/placement_qor_${design_name}.rpt

        # 6. Database and DEF Export
        write_def -floorplan -netlist -routing pnr/${design_name}_placed.def
        write_db pnr/${design_name}_placed.db

    } else {
        puts ">>> Detected Cadence Innovus Legacy / Encounter UI Mode"

        # 1. Design Initialization
        set ::init_verilog $netlist_file
        set ::init_top_cell $design_name
        set ::init_lef_file $lef_file
        set ::init_pwr_net {VDD}
        set ::init_gnd_net {VSS}
        set ::init_mmmc_file $mmmc_file

        init_design

        # 2. Floorplanning: 70% core utilization, 10um margins
        floorPlan -coreMarginsBy die -site CoreSite -r 1.0 0.70 10.0 10.0 10.0 10.0

        # 3. Global Net Connections
        globalNetConnect VDD -type pgpin -pin VDD -inst * -module {}
        globalNetConnect VSS -type pgpin -pin VSS -inst * -module {}
        globalNetConnect VDD -type tiehi -inst * -module {}
        globalNetConnect VSS -type tielo -inst * -module {}

        # 4. Placement & Pre-CTS Optimization
        setPlaceMode -congEffort high -timingDriven true
        place_opt_design

        # 5. Verification Reports
        checkPlace -report reports/check_place_${design_name}.rpt
        timeDesign -preCTS -outDir reports/timeDesign_preCTS_${design_name}
        report_timing > reports/placement_timing_${design_name}.rpt
        catch { reportPower > reports/placement_power_${design_name}.rpt }
        catch { reportDensity > reports/placement_density_${design_name}.rpt }

        # 6. Export Placed DEF & Design Save
        defOut -floorplan -netlist -routing pnr/${design_name}_placed.def
        saveDesign pnr/${design_name}_placed.enc
    }

    puts "=================================================================="
    puts " Innovus Placement Completed Successfully for: $design_name"
    puts " Output files: pnr/${design_name}_placed.def and reports/"
    puts "=================================================================="
}
