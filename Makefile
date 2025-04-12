PACKAGES = compiler lib examples 
TARGETS = all clean format

default: all Learn-bs-in-y-minutes.md

$(TARGETS):
		for p in $(PACKAGES) ; do $(MAKE) $(FLAGS) -C $$p $@ || break ; done

Learn-bs-in-y-minutes.md: doc-src/learn.m4 examples/learn.bs
		m4 doc-src/learn.m4 >Learn-bs-in-y-minutes.md || true

docs: Learn-bs-in-y-minutes.md

agon:
	$(MAKE) -f Makefile.agondev -C compiler
	$(MAKE) -C native-tools

windows:
	$(MAKE) -f Makefile.mingw -C compiler