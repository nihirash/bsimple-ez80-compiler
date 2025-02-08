SRC := src
CROSSBIN := bsc
DEPS := $(wildcard $(SRC)/*.c $(SRC)/*.h)
SRCS := $(wildcard $(SRC)/*.c)
C := cc
INSTALLDIR := ~/bin/
INDENT := gindent

$(CROSSBIN): $(DEPS)
	$(C) $(SRCS) -o $(CROSSBIN)

install: $(CROSSBIN)
	mkdir -p $(INSTALLDIR)
	rm -f $(INSTALLDIR)$(CROSSBIN)
	cp $(CROSSBIN) $(INSTALLDIR)

format:
	$(INDENT) -kr -ts1 $(DEPS)
	rm -f $(SRC)/*.c~ $(SRC)/*.h~

all: format install

clean:
	rm -f $(CROSSBIN)