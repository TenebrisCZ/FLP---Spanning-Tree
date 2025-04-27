#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

EXECUTABLE="./flp24-log"
TEST_DIR="tests"
TMP_OUT="tmp.txt"
TMP_NORMALIZED="tmp_normalized.txt"
EXP_NORMALIZED="exp_normalized.txt"

SUCCESS=0
FAIL=0

normalize_output() {
    while IFS= read -r line; do
        for edge in $line; do
            # Normalize each edge
            A=$(echo "$edge" | cut -d'-' -f1)
            B=$(echo "$edge" | cut -d'-' -f2)
            if [[ "$A" > "$B" ]]; then
                echo "$B-$A"
            else
                echo "$A-$B"
            fi
        done | sort | tr '\n' ' '
        echo
    done < "$1" | sort > "$2"
}

# Run tests
for INPUT in "$TEST_DIR"/*.in; do
    BASE=$(basename "$INPUT" .in)
    EXPECTED="$TEST_DIR/$BASE.out"
    
    "$EXECUTABLE" < "$INPUT" > "$TMP_OUT"
    
    # Normalize outputs
    normalize_output "$TMP_OUT" "$TMP_NORMALIZED"
    normalize_output "$EXPECTED" "$EXP_NORMALIZED"
    
    if diff -q "$TMP_NORMALIZED" "$EXP_NORMALIZED" > /dev/null; then
        echo -e "${GREEN}$BASE: SUCCESS${NC}"
        ((SUCCESS++))
    else
        echo -e "${RED}$BASE: FAIL${NC}"
        echo -e "${RED}---- ACTUAL OUTPUT (normalized) ----${NC}"
        cat "$TMP_NORMALIZED"
        echo -e "${RED}--- EXPECTED OUTPUT (normalized) ---${NC}"
        cat "$EXP_NORMALIZED"
        ((FAIL++))
    fi
done

echo ""

# Summary
TOTAL=$((SUCCESS + FAIL))
echo -e "Total tests: $TOTAL"
echo -e "${GREEN}Passed: $SUCCESS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"

# Cleanup
rm -f "$TMP_OUT" "$TMP_NORMALIZED" "$EXP_NORMALIZED"
