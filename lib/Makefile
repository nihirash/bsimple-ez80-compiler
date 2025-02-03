PACKAGES =  startup stdlib files
TARGETS = all clean

$(TARGETS):
		for p in $(PACKAGES) ; do $(MAKE) $(FLAGS) -C $$p $@ || break ; done
