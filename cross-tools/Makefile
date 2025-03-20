SRCS := $(wildcard *.c)
DEPS := $(wildcard *.c *.h)
APPS := $(basename $(SRCS))
include ../Makefile.cross-config

all: install

clean: 
		rm -rf $(APPS)

install: $(APPS)
		cp $(APPS) $(INSTALLDIR)


format:
	$(INDENT) $(IDENTFLAGS) $(SRCS)
	rm -f *.c~ *.h~