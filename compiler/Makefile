SRC := src
CROSSBIN := bsc
CROSSFLAGS := -DCROSS -o $(CROSSBIN)
DEPS := $(wildcard $(SRC)/*.c $(SRC)/*.h)
SRCS := $(wildcard $(SRC)/*.c)
include ../Makefile.cross-config

$(CROSSBIN): $(DEPS)
	$(C) $(SRCS) $(CROSSFLAGS)

install: $(CROSSBIN)
	mkdir -p $(INSTALLDIR)
	rm -f $(INSTALLDIR)$(CROSSBIN)
	cp $(CROSSBIN) $(INSTALLDIR)

format:
	$(INDENT) $(IDENTFLAGS) $(DEPS) || echo "Autoformating not available - skipped"
	rm -f $(SRC)/*.c~ $(SRC)/*.h~

all: install

clean:
	rm -rf $(CROSSBIN) obj/ bin/
	