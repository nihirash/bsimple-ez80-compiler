SRC := src
CROSSBIN := bsc
DEPS := $(wildcard $(SRC)/*.c $(SRC)/*.h)
SRCS := $(wildcard $(SRC)/*.c)
include ../Makefile.cross-config

$(CROSSBIN): $(DEPS)
	$(C) $(SRCS) -o $(CROSSBIN)

install: $(CROSSBIN)
	mkdir -p $(INSTALLDIR)
	rm -f $(INSTALLDIR)$(CROSSBIN)
	cp $(CROSSBIN) $(INSTALLDIR)

format:
	$(INDENT) $(IDENTFLAGS) $(DEPS)
	rm -f $(SRC)/*.c~ $(SRC)/*.h~

all: install

clean:
	rm -rf $(CROSSBIN) obj/ bin/
	