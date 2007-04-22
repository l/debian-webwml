#! /bin/sh
set -e

# This script originates from http://www.debian.org/mirror/anonftpsync
# modified by Martin Zobel-Helas <mhelas@helas.net>, 2005-01-16
# 	these modifications are published under the terms of the GNU GPL
# Modifications:
# + some more documentation about variables
# + added ARCH_EXCLUDE
# + mirror in a save way, first /pool, then /dists and the rest

# Version: $Id$ 


# Note: You MUST have rsync 2.0.16-1 or newer, which is available in slink
# and all newer Debian releases, or at http://rsync.samba.org/

# Set the variables below to fit your site. You can then use cron to have
# this script run daily to automatically update your copy of the archive.

# Don't forget:
# chmod 744 anonftpsync

# TO is the destination for the base of the Debian mirror directory
# (the dir that holds dists/ and ls-lR).
# (mandatory)

TO=

# RSYNC_HOST is the site you have chosen from the mirrors file.
# (http://www.debian.org/mirror/list-full)
# (mandatory)

RSYNC_HOST=volatile.debian.net

# RSYNC_DIR is the directory given in the "Packages over rsync:" line of
# the mirrors file for the site you have chosen to mirror.
# (mandatory)

RSYNC_DIR=debian-volatile/

# LOGDIR is the directory where the logs will be written to
# (mandatory)

LOGDIR=

# ARCH_EXCLUDE can be used to exclude a complete architecture from
# mirrorring. Please use as space seperated list.
# Possible values are:
# alpha, arm, hppa, hurd-i386, i386, ia64, m68k, mipsel, mips, powerpc, s390, sh and sparc
#
# There is one special value: source
# This is not an architecture but will exclude all source code in /pool
#
# eg.
# ARCH_EXCLUDE="alpha arm hppa hurd-i386 ia64 m68k mipsel mips s390 sparc"
# 
# With a blank ARCH_EXCLUDE you will mirror all availible architectures
# (optional)

ARCH_EXCLUDE=

# EXCLUDE is a list of parameters listing patterns that rsync will exclude.
# The following example would exclude mostly everything:
#EXCLUDE="\
#  --exclude binary-alpha/ --exclude binary-arm/ --exclude binary-i386/ \
#  --exclude binary-m68k/ --exclude binary-powerpc/ --exclude binary-sparc/ \
#  --exclude binary-ia64/ --exclude binary-mips*/ --exclude binary-hppa/ \
#  --exclude binary-sh/ --exclude binary-s390/ \
#  --exclude binary-hurd-i386/ \
#  --exclude *_alpha.deb --exclude *_arm.deb --exclude *_i386.deb \
#  --exclude *_m68k.deb --exclude *_powerpc.deb --exclude *_sparc.deb \
#  --exclude *_ia64.deb --exclude *_hppa.deb --exclude *_sh.deb \
#  --exclude *_mips.deb --exclude *_mipsel.deb --exclude *_s390.deb \
#  --exclude *_hurd-i386.deb \
#  --exclude disks-alpha/ --exclude disks-arm/ --exclude disks-i386/ \
#  --exclude disks-ia64/ --exclude disks-m68k/ --exclude disks-mips*/  \
#  --exclude disks-powerpc/  --exclude disks-s390/  --exclude disks-sparc/ \
#  --exclude stable/ --exclude testing/ --exclude unstable/ \
#  --exclude source/ \
#  --exclude *.orig.tar.gz --exclude *.diff.gz --exclude *.dsc \
#  --exclude /contrib/ --exclude /non-free/ \
# "

# With a blank EXCLUDE you will mirror the entire archive.
# (optional)

EXCLUDE=

# MAILTO is the address where to send logfile to
# if not defined, no mail will be sent
# (optional)

MAILTO=

# There should be no need to edit anything below this point, unless there
# are problems.

#-----------------------------------------------------------------------------#

# Check for some enviroment variables
if [ -z $TO ] || [ -z $RSYNC_HOST ] || [ -z $RSYNC_DIR ] || [ -z $LOGDIR ]; then
	echo "One of the following variables seem to be empty:"
	echo "TO, RSYNC_HOST, RSYNC_DIR or LOGDIR"
	exit 2
fi

if ! [ -d ${TO}/project/trace/ ]; then
	# we are running mirror script for the first time
	mkdir -p ${TO}/project/trace
fi

# Note: on some non-Debian systems, hostname doesn't accept -f option.
# If that's the case on your system, make sure hostname prints the full
# hostname, and remove the -f option. If there's no hostname command,
# explicitly replace `hostname -f` with the hostname.
HOSTNAME=`hostname -f`

LOCK="${TO}/Archive-Update-in-Progress-${HOSTNAME}"

# Exclude architectures defined in $ARCH_EXCLUDE
for ARCH in $ARCH_EXCLUDE; do
	EXCLUDE=$EXCLUDE"\
		--exclude binary-$ARCH/ \
		--exclude disks-$ARCH/ \
		--exclude installer-$ARCH/ \
		--exclude Contents-$ARCH.gz \
		--exclude *_$ARCH.deb \
		--exclude *_$ARCH.udeb "
	if [ "$ARCH" == "source" ]; then
		SOURCE_EXCLUDE="\
		--exclude *.tar.gz \
		--exclude *.diff.gz \
		--exclude *.dsc "
	fi
done

# Logfile
LOGFILE=$LOGDIR/debian-volatile.log

# Get in the right directory and set the umask to be group writable
# 
cd $HOME
umask 002

# Check to see if another sync is in progress
if lockfile -! -l 43200 -r 0 "$LOCK"; then
  echo ${HOSTNAME} is unable to start rsync, lock file exists
  exit 1
fi
# Note: on some non-Debian systems, trap doesn't accept "exit" as signal
# specification. If that's the case on your system, try using "0".
trap "rm -f $LOCK > /dev/null 2>&1" exit

set +e

# First sync /pool
rsync --recursive --links --hard-links --times --verbose --delete \
     $EXCLUDE $SOURCE_EXCLUDE \
     $RSYNC_HOST::$RSYNC_DIR/pool/ $TO/pool/ >> $LOGFILE 2>&1

# Now sync the remaining stuff
rsync --recursive --links --hard-links --times --verbose --delete-after \
     --exclude "Archive-Update-in-Progress-${HOSTNAME}" \
     --exclude "project/trace/${HOSTNAME}" \
     --exclude "/pool/" \
     $EXCLUDE \
     $RSYNC_HOST::$RSYNC_DIR $TO >> $LOGFILE 2>&1

date -u > "${TO}/project/trace/${HOSTNAME}"


if ! [ -z $MAILTO ]; then
	mail -s "debian-volatile archive synced" $MAILTO < $LOGFILE
fi

savelog $LOGFILE

