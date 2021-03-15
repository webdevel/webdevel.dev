.DEFAULT_GOAL = webdevel.dev

webdevel.dev.o: webdevel.dev.c
	$(CC) $(DEFS) $(INCLUDES) $(CPPFLAGS) $(CFLAGS) -c $(<) -o $(@)

webdevel.dev: webdevel.dev.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(@) $(<) $(LDADD) $(LDLIBS) -Wl,$(LIBS)
	@ls -ls $(@)

clean:
	$(RM)v webdevel.dev webdevel.dev.o
