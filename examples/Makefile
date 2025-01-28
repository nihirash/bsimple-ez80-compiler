SRCS := $(wildcard *.bs)
BUILT := $(SRCS:.bs=.s)
ASSEMBLED := $(SRCS:.bs=.bin)

%.s: %.bs
		bsc $<

%.bin: %.s
		ez80asm $<

all: $(ASSEMBLED)

clean:
		rm -f $(ASSEMBLED)