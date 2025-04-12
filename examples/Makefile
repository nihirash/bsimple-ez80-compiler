SRCS := $(wildcard *.bs)
BUILT := $(SRCS:.bs=.s)
ASSEMBLED := $(SRCS:.bs=.bin)
BSIMPLE := bsc
ASM := ez80asm

%.s: %.bs
		$(BSIMPLE) $<

%.bin: %.s
		$(ASM) $<
		
all: $(ASSEMBLED)

clean:
		rm -f $(ASSEMBLED) *.s

format:
