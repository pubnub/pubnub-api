SUBDIRS = corona moai

.PHONY: all
all:
	for dir in $(SUBDIRS); do \
    	$(MAKE) -C $$dir;     \
	done

.PHONY: clean
clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) clean -C $$dir; \
	done 

.PHONY: test
test:
	for dir in $(SUBDIRS); do \
		$(MAKE) test -C $$dir; \
	done 
