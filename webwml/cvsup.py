#!/usr/bin/python
# A script to recursively update a CVS checkout, skipping directories for
# languages you do not know or care about. Useful for translators who only want
# a checkout of the directories for English and their own language.
# 
# This special script is needed because:
# - "cvs up -d" will check out languages most people usually do not care about
# - however plain "cvs up" does not create directories newly created in the
# repository
#
# Copyright 2010 Marcin Owsiany <porridge@debian.org>

import sys
import logging
import os
import subprocess

logging.basicConfig(level=logging.INFO)

logging.info('Getting list of entries in the repository.')
# Set LANG=C as we need to parse command output
env = dict(os.environ)
env['LANG'] = 'C'
lines = subprocess.Popen(['cvs', 'ls', '-l'], stdout=subprocess.PIPE, env=env).communicate()[0]
repo_dirs = set()
for line in lines.split('\n'):
	if not line:
		pass
	elif line.startswith('-'):
		pass
	elif line.startswith('d'):
		repo_dirs.add(line.split(None, 4)[4])
	else:
		logging.warn('Unexpected line: %s', line)

logging.info('Getting list of known languages.')
lines = subprocess.Popen(['make', 'list-languages'], stdout=subprocess.PIPE).communicate()[0]
langs = set(lines.split())

logging.info('Getting list of checked-out directories.')
local_dirs = set(e for e in os.listdir('.') if os.path.isdir(e))

logging.debug('Dirs in repo: %s', ' '.join(sorted(repo_dirs)))
logging.debug('LANGS       : %s', ' '.join(sorted(langs)))
logging.debug('Dirs in .   : %s', ' '.join(sorted(local_dirs)))

# We want:
# - all currently checked out directories (i.e. ones that exist locally and in
# the repository)
checked_out = local_dirs.intersection(repo_dirs)
# - all directories in repo that are not langs
specials = repo_dirs - langs
# However we do not want e.g. stale language directories which are being
# transitioned to a new name. So we keep a list of known non-language
# directories, and we warn (and ignore) if the above encounters anything else.
known_specials = set(['Perl', 'po'])
mysterious = specials - known_specials

to_update = known_specials | checked_out
if to_update:
	logging.info('Updating recursively: %s', ' '.join(to_update))
	subprocess.Popen(['cvs', '-q', 'up', '-dP'] + sorted(list(to_update))).wait()
else:
	logging.warn('No directories to update recursively.')
logging.info('Updating current directory.')
subprocess.Popen(['cvs', '-q', 'up', '-lP']).wait()

if mysterious:
	logging.warn('The following directories exist in repo but are neither '
	             'known special dirs nor in LANGUAGES in top Makefile. '
	             'Please delete them or add to known_specials in %s: %s',
				 sys.argv[0], ' '.join(mysterious))
