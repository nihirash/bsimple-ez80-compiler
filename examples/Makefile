SRCS := $(wildcard *.bs)
BUILT := $(SRCS:.bs=.s)
ASSEMBLED := $(SRCS:.bs=.bin)

%.bin: %.bs
		bs $<

all: $(ASSEMBLED)

clean:
		rm -f $(ASSEMBLED) *_post.bs *.s

format:
