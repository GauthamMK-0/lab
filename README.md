# Register-to-Register Combinational Circuits: ASIC Synthesis, LEC & Placement Flow

This repository contains **5 simple register-to-register combinational circuits** utilizing D flip-flops, self-checking testbenches, Cadence Genus logic synthesis TCL scripts, Cadence Conformal LEC dofiles, and Cadence Innovus physical placement scripts mapped to the Foundry 90nm standard cell technology library referenced in `mt_npu`.

---

## 1. Directory Structure

```
/root/research/lab/
├── Makefile                                # Unified build, simulation, synth, LEC & placement runner
├── README.md                               # Complete flow documentation
├── rtl/                                    # Synthesizable RTL source files
│   ├── reg2reg_multiplier.v                # Circuit 1: 2-bit Multiplier
│   ├── reg2reg_adder.v                     # Circuit 2: 4-bit Full Adder
│   ├── reg2reg_comparator.v                # Circuit 3: 4-bit Magnitude Comparator
│   ├── reg2reg_mux.v                       # Circuit 4: 4-to-1 Multiplexer
│   └── reg2reg_decoder.v                   # Circuit 5: 2-to-4 Decoder with Enable
├── tb/                                     # Self-checking testbenches
│   ├── tb_reg2reg_multiplier.v
│   ├── tb_reg2reg_adder.v
│   ├── tb_reg2reg_comparator.v
│   ├── tb_reg2reg_mux.v
│   └── tb_reg2reg_decoder.v
├── sdc/                                    # Timing constraints (200 MHz / 5.0 ns clock period)
│   ├── reg2reg_multiplier.sdc
│   ├── reg2reg_adder.sdc
│   ├── reg2reg_comparator.sdc
│   ├── reg2reg_mux.sdc
│   └── reg2reg_decoder.sdc
├── scripts/
│   ├── synth/                              # Cadence Genus logic synthesis scripts
│   │   ├── synth_reg2reg_multiplier.tcl
│   │   ├── synth_reg2reg_adder.tcl
│   │   ├── synth_reg2reg_comparator.tcl
│   │   ├── synth_reg2reg_mux.tcl
│   │   ├── synth_reg2reg_decoder.tcl
│   │   └── synth_all.tcl
│   ├── lec/                                # Cadence Conformal LEC dofiles
│   │   ├── lec_reg2reg_multiplier.do
│   │   ├── lec_reg2reg_adder.do
│   │   ├── lec_reg2reg_comparator.do
│   │   ├── lec_reg2reg_mux.do
│   │   ├── lec_reg2reg_decoder.do
│   │   └── run_all_lec.sh
│   └── innovus/                            # Cadence Innovus physical placement flow
│       ├── mmmc_reg2reg_multiplier.tcl
│       ├── mmmc_reg2reg_adder.tcl
│       ├── mmmc_reg2reg_comparator.tcl
│       ├── mmmc_reg2reg_mux.tcl
│       ├── mmmc_reg2reg_decoder.tcl
│       ├── place_common.tcl
│       ├── place_reg2reg_multiplier.tcl
│       ├── place_reg2reg_adder.tcl
│       ├── place_reg2reg_comparator.tcl
│       ├── place_reg2reg_mux.tcl
│       ├── place_reg2reg_decoder.tcl
│       └── place_all.tcl
```

---

## 2. Microarchitecture of the 5 Simple Circuits

Each circuit adheres to the classic synchronous **Register-to-Register (Reg-to-Reg)** structure:
$$\text{Input Pins} \xrightarrow{} \text{Input DFFs (Stage 1)} \xrightarrow{} \text{Combinational Logic Cone} \xrightarrow{} \text{Output DFFs (Stage 2)} \xrightarrow{} \text{Output Pins}$$

All timing paths are isolated purely between flip-flop registers, guaranteeing clean STA closure, simple LEC key-point mapping, and reliable standard cell placement.

### Circuit 1: `reg2reg_multiplier` (2-bit Multiplier)
* **Inputs**: `clk`, `rst_n`, `a [1:0]`, `b [1:0]`
* **Outputs**: `p [3:0]`
* **Operation**: Multiplies two 2-bit unsigned integers producing a 4-bit product ($0 \le P \le 9$).
* **Registers**:
  - Stage 1: Input DFFs for `a [1:0]` and `b [1:0]`
  - Combinational: $P = A \times B$
  - Stage 2: Output DFFs for `p [3:0]`

### Circuit 2: `reg2reg_adder` (4-bit Full Adder)
* **Inputs**: `clk`, `rst_n`, `a [3:0]`, `b [3:0]`, `cin`
* **Outputs**: `sum [3:0]`, `cout`
* **Operation**: Adds two 4-bit numbers with carry-in.
* **Registers**:
  - Stage 1: Input DFFs for `a [3:0]`, `b [3:0]`, `cin`
  - Combinational: $\{C_{out}, Sum\} = A + B + C_{in}$
  - Stage 2: Output DFFs for `sum [3:0]`, `cout`

### Circuit 3: `reg2reg_comparator` (4-bit Magnitude Comparator)
* **Inputs**: `clk`, `rst_n`, `a [3:0]`, `b [3:0]`
* **Outputs**: `eq`, `gt`, `lt`
* **Operation**: Compares two 4-bit numbers: equal ($A = B$), greater ($A > B$), less ($A < B$).
* **Registers**:
  - Stage 1: Input DFFs for `a [3:0]`, `b [3:0]`
  - Combinational: 4-bit comparison logic
  - Stage 2: Output DFFs for `eq`, `gt`, `lt`

### Circuit 4: `reg2reg_mux` (4-to-1 Multiplexer)
* **Inputs**: `clk`, `rst_n`, `d [3:0]`, `sel [1:0]`
* **Outputs**: `y`
* **Operation**: Routes one of 4 input lines $D[0..3]$ to output based on 2-bit select code.
* **Registers**:
  - Stage 1: Input DFFs for `d [3:0]`, `sel [1:0]`
  - Combinational: 4:1 multiplexer logic
  - Stage 2: Output DFF for `y`

### Circuit 5: `reg2reg_decoder` (2-to-4 Decoder with Enable)
* **Inputs**: `clk`, `rst_n`, `in [1:0]`, `en`
* **Outputs**: `out [3:0]`
* **Operation**: Decodes 2-bit binary code into active-high one-hot output when enabled ($en=1$); forces zeros when disabled ($en=0$).
* **Registers**:
  - Stage 1: Input DFFs for `in [1:0]`, `en`
  - Combinational: 2-to-4 decoder logic
  - Stage 2: Output DFFs for `out [3:0]`

---

## 3. Technology File Locations (Referenced from `mt_npu`)

As configured in the `mt_npu` project (`/root/research/mt_npu/models/*/synth_*.tcl`):
* **Standard Cell Liberty Timing File**:
  `/home/cadence/install/FOUNDRY/digital/90nm/dig/lib/slow.lib`
* **Standard Cell Physical LEF File**:
  `/home/cadence/install/FOUNDRY/digital/90nm/dig/lef/all.lef`
* **Clock Frequency**: 200 MHz ($T_{\text{clk}} = 5.000\text{ ns}$).

---

## 4. Execution Commands

### Step 1: Run Functional Verification (Testbenches)
```bash
make sim-all
```
*Runs all 5 testbenches with `iverilog` in batch mode. All 5 testbenches are self-checking and report passing status.*

### Step 2: Cadence Genus Synthesis
```bash
# Synthesize all 5 simple circuits
make synth-all

# Or synthesize single circuit:
make synth-mult
```

### Step 3: Cadence Conformal LEC
```bash
# Run LEC on all designs
make lec-all

# Or run individual LEC dofile:
make lec-mult
```

### Step 4: Cadence Innovus Placement
```bash
# Run Innovus placement on all designs
make place-all

# Or run individual placement:
make place-mult
```
