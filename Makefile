# Makefile for FLP project 2: Spanning trees
# Author: Pavel Osinek (xosine00)

SWIFLAGS := -q -g start

SRC := spanning-tree.pl
OUT := flp24-log
ZIP := flp-log-xosine00.zip
FILES := $(SRC) Makefile README.md tests/ run_tests.sh

$(OUT): $(SRC)
	swipl $(SWIFLAGS) -o $(OUT) -c $(SRC)

.PHONY: clean
clean:
	rm -f $(OUT)

.PHONY: zip
zip:
	zip -r $(ZIP) $(FILES)

.PHONY: test
test: $(OUT)
	chmod +x run_tests.sh
	./run_tests.sh
