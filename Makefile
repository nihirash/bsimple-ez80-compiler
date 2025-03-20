PACKAGES = compiler lib cross-tools examples 
TARGETS = all clean format

default: all

$(TARGETS):
		for p in $(PACKAGES) ; do $(MAKE) $(FLAGS) -C $$p $@ || break ; done

Learn-bs-in-y-minutes.md: doc-src/learn.m4 examples/learn.bs
		m4 doc-src/learn.m4 >Learn-bs-in-y-minutes.md || true

docs: Learn-bs-in-y-minutes.md

agon:
	$(MAKE) -f Makefile.agondev -C compiler