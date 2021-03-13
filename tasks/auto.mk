PACKAGE=$(shell awk '{printf $$1; exit}' README.md)
VERSION=$(shell awk '{printf $$2; exit}' README.md)
REPORT=$(shell awk '{printf $$3; exit}' README.md)

configure.scan:
	autoscan --verbose --debug &> autoscan.log

configure.ac: configure.scan
	@if test ! -e $(@); then \
mv $(<) $(@); \
sed 's#FULL-PACKAGE-NAME#$(PACKAGE)#' $(@) > /tmp/out && mv /tmp/out $(@); \
sed 's#VERSION#$(VERSION)#' $(@) > /tmp/out && mv /tmp/out $(@); \
sed 's#BUG-REPORT-ADDRESS#$(REPORT)#' $(@) > /tmp/out && mv /tmp/out $(@); \
sed 's#AC_CONFIG_FILES#AM_INIT_AUTOMAKE([1.16 -Wall -Werror foreign dist-bzip2 dist-zip])\n\nAC_CONFIG_FILES#' $(@) > /tmp/out && mv /tmp/out $(@); \
fi

aclocal.m4: configure.ac
	aclocal --verbose --warnings=all &> aclocal.log

config.h.in: aclocal.m4
	autoheader --verbose --debug --warnings=all &> autoheader.log

configure: config.h.in
	autoreconf --verbose --debug --warnings=all --install &> autoreconf.log

Makefile.in: configure
	automake --verbose --foreign --warnings=all --add-missing

autotest:
	autom4te --verbose --debug --warnings=all --language=Autotest

all/clean: ## Extreme Caution
	@$(RM)rv \
	$(shell find autom4te.cache 2>/dev/null || true | sort -r) \
	$(shell find build 2>/dev/null || true | sort -r) \
	$(shell find src/.deps 2>/dev/null || true | sort -r) \
	$(shell find *.log 2>/dev/null || true) \
	$(shell find aclocal.* 2>/dev/null || true) \
	$(shell find config.* 2>/dev/null || true) \
	$(shell find configure configure.scan 2>/dev/null || true) \
	$(shell find depcomp 2>/dev/null || true) \
	$(shell find missing 2>/dev/null || true) \
	$(shell find compile 2>/dev/null || true) \
	$(shell find install* 2>/dev/null || true) \
	$(shell find src/*.o src/stamp* src/config.h* 2>/dev/null || true) \
	$(shell find Makefile.* src/Makefile* 2>/dev/null || true) \
	$(shell find src/$(PACKAGE) 2>/dev/null || true) \
	2>/dev/null || true
