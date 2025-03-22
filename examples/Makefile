SRCS := $(wildcard *.bs)
BUILT := $(SRCS:.bs=.s)
ASSEMBLED := $(SRCS:.bs=.bin)

%.bin: %.bs
		bs $<
		rm -f $(basename $<)_post.s
		rm $(basename $<)_post.bs
		
all: $(ASSEMBLED)

clean:
		rm -f $(ASSEMBLED) *_post.bs *.s

format:
