# let's use make's ordering when reading makefile files in order to
# create data/langs before the Makefile stuff is run

# it depends on the fact english/ is built first, but that's okay I guess

# this file is English-only, don't copy it to a translation directory!

.PHONY: all install clean cleandest

all install clean cleandest: data/langs
	make -f Makefile $@

data/langs: data/unstable scripts/list-languages
	scripts/list-languages data/unstable > data/langs
