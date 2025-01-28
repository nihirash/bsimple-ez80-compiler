SRCS := $(wildcard src/*.i) $(wildcard src/*.bs)
BUILT := $(SRCS:.bs=.s) 
RESULT := startup.i
BSIMPLE := bsc

%.s: %.bs
		bsc $<

$(RESULT): $(BUILT)
		cat $(BUILT) > $(RESULT)
		rm src/*.s

all: $(RESULT)

clean:
		rm -f src/*.s $(RESULT)
