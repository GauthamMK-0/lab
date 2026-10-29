#!/usr/bin/env bash
# ==============================================================================
# Master Execution Script for Cadence Conformal LEC
# ==============================================================================

set -euo pipefail

mkdir -p reports

DESIGNS=(
    "reg2reg_multiplier"
    "reg2reg_adder"
    "reg2reg_comparator"
    "reg2reg_mux"
    "reg2reg_decoder"
)

echo "=================================================================="
echo " Starting Cadence Conformal LEC Verification for All 5 Designs"
echo "=================================================================="

for design in "${DESIGNS[@]}"; do
    echo ">>> Running LEC for: ${design}"
    lec -dofile "scripts/lec/lec_${design}.do" || {
        echo ">>> [WARNING] LEC finished with non-zero exit code or tool unavailable on this host."
    }
done

echo "=================================================================="
echo " LEC Execution Batch Completed. Inspect reports/ for logs."
echo "=================================================================="
