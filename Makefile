

BUILD=build
CFLAGS=-O2 -Wall

INCLUDES=-I$(BUILD)
CL65=cl65
CFG=asm/bas2xex.cfg
TGT=-tatari

all: $(BUILD)/bas2xex

$(BUILD)/%.xex: asm/%.s | $(BUILD)
	$(CL65) -C$(CFG) -g -l $(@:%.xex=%.lst) -Ln $(@:%.xex=%.lab) $(TGT) -o $@ $<

$(BUILD)/%: src/%.c | $(BUILD)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $<

$(BUILD)/loader.h: $(BUILD)/bas2xex.xex
	xxd -n loader -i $< $@

$(BUILD):
	@mkdir -p $@

$(BUILD)/bas2xex: $(BUILD)/loader.h
