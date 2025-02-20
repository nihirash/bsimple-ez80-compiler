PACKAGES = compiler lib examples
TARGETS = all clean format

default: all

$(TARGETS):
		for p in $(PACKAGES) ; do $(MAKE) $(FLAGS) -C $$p $@ || break ; done

agon:
	$(MAKE) -f Makefile.agondev -C compiler