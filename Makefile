# ==============================================================================
# Master Automation Makefile: 5 Simple Reg-to-Reg Combinational Circuits
# Flow: Functional Simulation -> Genus Synthesis -> Conformal LEC -> Innovus Placement
# ==============================================================================

SHELL       := /bin/bash
DESIGNS     := reg2reg_multiplier reg2reg_adder reg2reg_comparator reg2reg_mux reg2reg_decoder
SIM_DIR     := sim_build
REPORT_DIR  := reports
NETLIST_DIR := netlist
PNR_DIR     := pnr

.PHONY: all help sim sim-all clean \
        synth synth-all \
        lec lec-all \
        place place-all

# Default Target
all: help

help:
	@echo "=================================================================="
	@echo " 5 Simple Reg-to-Reg Circuits Automation Flow"
	@echo "=================================================================="
	@echo " Simulation Targets (Icarus Verilog):"
	@echo "   make sim-all            - Run all 5 self-checking testbenches"
	@echo "   make sim-mult           - Run tb_reg2reg_multiplier (2-bit multiplier)"
	@echo "   make sim-adder          - Run tb_reg2reg_adder (4-bit adder)"
	@echo "   make sim-comp           - Run tb_reg2reg_comparator (4-bit comparator)"
	@echo "   make sim-mux            - Run tb_reg2reg_mux (4-to-1 mux)"
	@echo "   make sim-dec            - Run tb_reg2reg_decoder (2-to-4 decoder)"
	@echo ""
	@echo " Cadence Genus Synthesis Targets (Foundry 90nm slow.lib @ 200 MHz):"
	@echo "   make synth-all          - Synthesize all 5 circuits sequentially"
	@echo "   make synth-mult         - Synthesize reg2reg_multiplier"
	@echo "   make synth-adder        - Synthesize reg2reg_adder"
	@echo "   make synth-comp         - Synthesize reg2reg_comparator"
	@echo "   make synth-mux          - Synthesize reg2reg_mux"
	@echo "   make synth-dec          - Synthesize reg2reg_decoder"
	@echo ""
	@echo " Cadence Conformal Logic Equivalence Checking (LEC) Targets:"
	@echo "   make lec-all            - Run LEC on all 5 synthesized netlists"
	@echo "   make lec-mult           - Run LEC for reg2reg_multiplier"
	@echo "   make lec-adder          - Run LEC for reg2reg_adder"
	@echo "   make lec-comp           - Run LEC for reg2reg_comparator"
	@echo "   make lec-mux            - Run LEC for reg2reg_mux"
	@echo "   make lec-dec            - Run LEC for reg2reg_decoder"
	@echo ""
	@echo " Cadence Innovus Placement Targets:"
	@echo "   make place-all          - Run Innovus placement for all 5 circuits"
	@echo "   make place-mult         - Run placement for reg2reg_multiplier"
	@echo "   make place-adder        - Run placement for reg2reg_adder"
	@echo "   make place-comp         - Run placement for reg2reg_comparator"
	@echo "   make place-mux          - Run placement for reg2reg_mux"
	@echo "   make place-dec          - Run placement for reg2reg_decoder"
	@echo ""
	@echo " Maintenance Targets:"
	@echo "   make clean              - Delete simulation builds, logs, and temp files"
	@echo "=================================================================="

# --- Simulation Targets ---
sim: sim-all

sim-all: sim-mult sim-adder sim-comp sim-mux sim-dec
	@echo "=================================================================="
	@echo " ALL 5 TESTBENCHES COMPLETED AND PASSED!"
	@echo "=================================================================="

sim-mult:
	@mkdir -p $(SIM_DIR)
	iverilog -g2012 -o $(SIM_DIR)/tb_mult.vvp rtl/reg2reg_multiplier.v tb/tb_reg2reg_multiplier.v
	vvp $(SIM_DIR)/tb_mult.vvp

sim-adder:
	@mkdir -p $(SIM_DIR)
	iverilog -g2012 -o $(SIM_DIR)/tb_adder.vvp rtl/reg2reg_adder.v tb/tb_reg2reg_adder.v
	vvp $(SIM_DIR)/tb_adder.vvp

sim-comp:
	@mkdir -p $(SIM_DIR)
	iverilog -g2012 -o $(SIM_DIR)/tb_comp.vvp rtl/reg2reg_comparator.v tb/tb_reg2reg_comparator.v
	vvp $(SIM_DIR)/tb_comp.vvp

sim-mux:
	@mkdir -p $(SIM_DIR)
	iverilog -g2012 -o $(SIM_DIR)/tb_mux.vvp rtl/reg2reg_mux.v tb/tb_reg2reg_mux.v
	vvp $(SIM_DIR)/tb_mux.vvp

sim-dec:
	@mkdir -p $(SIM_DIR)
	iverilog -g2012 -o $(SIM_DIR)/tb_dec.vvp rtl/reg2reg_decoder.v tb/tb_reg2reg_decoder.v
	vvp $(SIM_DIR)/tb_dec.vvp

# --- Cadence Genus Synthesis Targets ---
synth: synth-all

synth-all:
	@mkdir -p $(REPORT_DIR) $(NETLIST_DIR)
	genus -f scripts/synth/synth_all.tcl -log genus_batch.log

synth-mult:
	@mkdir -p $(REPORT_DIR) $(NETLIST_DIR)
	genus -f scripts/synth/synth_reg2reg_multiplier.tcl -log genus_mult.log

synth-adder:
	@mkdir -p $(REPORT_DIR) $(NETLIST_DIR)
	genus -f scripts/synth/synth_reg2reg_adder.tcl -log genus_adder.log

synth-comp:
	@mkdir -p $(REPORT_DIR) $(NETLIST_DIR)
	genus -f scripts/synth/synth_reg2reg_comparator.tcl -log genus_comp.log

synth-mux:
	@mkdir -p $(REPORT_DIR) $(NETLIST_DIR)
	genus -f scripts/synth/synth_reg2reg_mux.tcl -log genus_mux.log

synth-dec:
	@mkdir -p $(REPORT_DIR) $(NETLIST_DIR)
	genus -f scripts/synth/synth_reg2reg_decoder.tcl -log genus_dec.log

# --- Cadence Conformal LEC Targets ---
lec: lec-all

lec-all:
	@mkdir -p $(REPORT_DIR)
	./scripts/lec/run_all_lec.sh

lec-mult:
	@mkdir -p $(REPORT_DIR)
	lec -nogui -dofile scripts/lec/lec_reg2reg_multiplier.do

lec-adder:
	@mkdir -p $(REPORT_DIR)
	lec -nogui -dofile scripts/lec/lec_reg2reg_adder.do

lec-comp:
	@mkdir -p $(REPORT_DIR)
	lec -nogui -dofile scripts/lec/lec_reg2reg_comparator.do

lec-mux:
	@mkdir -p $(REPORT_DIR)
	lec -nogui -dofile scripts/lec/lec_reg2reg_mux.do

lec-dec:
	@mkdir -p $(REPORT_DIR)
	lec -nogui -dofile scripts/lec/lec_reg2reg_decoder.do

# --- Cadence Innovus Placement Targets ---
place: place-all

place-all:
	@mkdir -p $(REPORT_DIR) $(PNR_DIR)
	innovus -nowin -batch -files scripts/innovus/place_all.tcl

place-mult:
	@mkdir -p $(REPORT_DIR) $(PNR_DIR)
	innovus -nowin -batch -files scripts/innovus/place_reg2reg_multiplier.tcl

place-adder:
	@mkdir -p $(REPORT_DIR) $(PNR_DIR)
	innovus -nowin -batch -files scripts/innovus/place_reg2reg_adder.tcl

place-comp:
	@mkdir -p $(REPORT_DIR) $(PNR_DIR)
	innovus -nowin -batch -files scripts/innovus/place_reg2reg_comparator.tcl

place-mux:
	@mkdir -p $(REPORT_DIR) $(PNR_DIR)
	innovus -nowin -batch -files scripts/innovus/place_reg2reg_mux.tcl

place-dec:
	@mkdir -p $(REPORT_DIR) $(PNR_DIR)
	innovus -nowin -batch -files scripts/innovus/place_reg2reg_decoder.tcl

# --- Cleanup Target ---
clean:
	rm -rf $(SIM_DIR) *.log *.cmd* fv/ *.shm *.vvp
