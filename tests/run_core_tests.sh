#!/bin/bash
# Aftermask Core Loop Tests
echo "=== Aftermask Core Loop Tests ==="
echo ""
echo "--- v3 Integration Test (Python) ---"
PYTHONIOENCODING=utf-8 python3 tests/aftermask_v3.py 2>&1
