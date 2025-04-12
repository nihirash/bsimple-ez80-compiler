TOOLS := bs

SOURCES := $(TOOLS:=.bs)
BINARIES := $(TOOLS:=.bin)

ASM := ez80asm
BSC := bsc

%.s: %.bs
		$(BSC) $<

%.bin: %.s
		$(ASM) $<

all: $(BINARIES)