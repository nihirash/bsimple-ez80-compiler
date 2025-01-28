all:
		$(MAKE) -C compiler -f Makefile.cross install
		$(MAKE) -C stdlib
		$(MAKE) -C examples

clean:
		$(MAKE) -C compiler -f Makefile.cross clean
		$(MAKE) -C stdlib clean
		$(MAKE) -C examples clean