PACKAGES =  startup stdlib files arcade
TARGETS = all clean

$(TARGETS):
		for p in $(PACKAGES) ; do $(MAKE) $(FLAGS) -C $$p $@ || break ; done

format: