# let's use make's ordering when reading makefile files in order to
# create data/langs before the Makefile stuff is run

# this file is English-only, don't copy it to a translation directory!

.PHONY: all
all: data/langs
	make -f Makefile

data/langs: data/unstable scripts/list-languages
	scripts/list-languages data/unstable > data/langs
