-include tasks/*.mk

.DEFAULT_GOAL = all

CPPFLAGS += -I.

LDFLAGS += -L.

SUBDIRS = src

all: configure ## Make all directories
	@export \
	CC="$(CC)" \
	DEFS="$(DEFS)" \
	INCLUDES="$(INCLUDES)" \
	CPPFLAGS="$(CPPFLAGS)" \
	CFLAGS="$(CFLAGS)" \
	LDFLAGS="$(LDFLAGS)" \
	LDADD="$(LDADD)" \
	LDLIBS="$(LDLIBS)" \
	LIBS="$(LIBS)" \
	RM="$(RM)"; \
	for dir in $(SUBDIRS); do cd $$dir && $(MAKE); done

clean: ## Make clean all directories
	for dir in $(SUBDIRS); do cd $$dir && $(MAKE) clean; done

check: ## Make check all directories
	