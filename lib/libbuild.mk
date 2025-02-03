SRCS := $(wildcard *.i) $(wildcard *.bs)
BUILT := $(SRCS:.bs=.s) 
BSIMPLE := bsc

%.s: %.bs
		bsc $<

$(RESULT): $(BUILT)
		cat $(BUILT) > $(RESULT)
		rm -f *.s

all: $(RESULT)

clean:
		rm -f *.s $(RESULT)
