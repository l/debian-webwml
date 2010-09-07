#! /bin/sh

# upgrade a libc5 (bo) machine to libc6 (hamm).
#
# $Id$
#
# based on Scott Ellis' excellent "Debian libc5 to libc6 Mini-HOWTO"
# document at http://www.gate.net/~storm/FAQ/libc5-libc6-Mini-HOWTO.html

#
# Command line options:
#
# --make-tarfiles       create tarball of debian packages INSTEAD of
#                       doing the upgrade.  This option is *only* useful
#                       for maintainers of autoup mirror sites.  End
#                       users can safely ignore this option.
#
#

# Author: Craig Sanders <cas@taz.net.au>
#         and many others.  see changelog for details.
#
# Copyright Status: This script is hereby placed in the public domain
#
# Revision History:
#   see autoup.changelog

# The latest version of this script can always be found at:
#    http://debian.vicnet.net.au/autoup/
# and at:
#    http://www.taz.net.au/autoup/
#
# the vicnet site is much faster and also has a tarball containing all
# the deb files needed by this script.
#
# please check that you have the latest version before running this
# script.

# misc tweakable variables

DPKG="$(which dpkg)"
LDCONFIG=$(which ldconfig)

# uncomment for debugging
#set -x
#DPKG="echo dpkg"
#LDCONFIG="echo ldconfig"

DPKG_ARGS="-iBE  --force-overwrite --force-hold"
DATE=$(date +%m%d-%T)
ARCH="binary-$(dpkg --print-installation-architecture)"

FTP_SITE_1="ftp.debian.org"
FTP_DIR_1="debian/hamm/hamm/$ARCH"
FTP_SITE_2="ftp.infodrom.north.de"
FTP_DIR_2="/pub/debian/hamm/hamm/$ARCH"

# package variables

PKGS_LDSO="base/ldso_*.deb"
PKGS_LIBC5="oldlibs/libc5_*.deb"
PKGS_LIBC6="base/libc6_*.deb base/timezones_*.deb admin/locales_*.deb"
PKGS_NCURSES="oldlibs/ncurses3.0_*.deb base/ncurses3.4_*.deb"
PKGS_LIBRL="oldlibs/libreadline2_*.deb"
PKGS_LIBRLG="base/libreadlineg2_*.deb"
PKGS_BASH="base/bash_*.deb"
PKGS_LIBGPP="oldlibs/libg++27_*.deb libs/libg++272_*.deb \
             base/libstdc++2.8_*.deb"
PKGS_DPKG="base/dpkg_*.deb utils/dpkg-dev_*.deb"
PKGS_SLANG="oldlibs/slang0.99.34_*.deb base/slang0.99.38_*.deb"
PKGS_LIBGDBM="oldlibs/libgdbm1_*.deb base/libgdbmg1_*.deb"
PKGS_PERLBASE="base/perl-base_*.deb"
PKGS_PERL="interpreters/perl_*.deb"
PKGS_MOREDPKG="interpreters/data-dumper_*.deb base/libnet-perl_*.deb \
               base/dpkg-ftp_*.deb admin/dpkg-mountable_*.deb"
PKGS_NETBASE="net/netbase_*.deb"
PKGS_NETSTD="net/netstd_*.deb"

ALLPKGS="$PKGS_LDSO $PKGS_LIBC5 $PKGS_LIBC6 $PKGS_NCURSES $PKGS_LIBRL
         $PKGS_LIBRLG $PKGS_BASH $PKGS_LIBGPP $PKGS_DPKG $PKGS_SLANG 
         $PKGS_LIBGDBM $PKGS_PERLBASE $PKGS_PERL $PKGS_MOREDPKG 
         $PKGS_NETBASE $PKGS_NETSTD"

if [ "$1" == "--make-tarfiles" ] ; then
    answer="m" 
else
  cat <<__EOF__
This script will install the packages necessary to ensure a safe upgrade
to hamm.  

You need to either have a local or remote mirror mounted, or have the
latest versions of the following packages from hamm available in the
current directory:

    ldso, libc5, libc6, timezones, locales, ncurses3.0, ncurses3.4,
    libreadline2, libreadlineg2, bash, libg++27, libg++272,
    libstdc++2.8, dpkg, dpkg-dev, slang0.99.34, slang0.99.38, libgdbm1,
    libgdbmg1, perl-base, perl, data-dumper, libnet-perl, dpkg-ftp,
    dpkg-mountable, netbase, netstd.

If you are using a mirror, press 'm'.
If you need to download the files via FTP, press 'f'.
__EOF__

  echo -n "if you have the files in the current dir, press 'c': (m/f/c) "

  read answer
fi


case "$answer" in
    m|M)
        # local mirror available

        # ask where the mirror is (this could do with some error checking)
        echo 
        echo "enter the full path to your local mirror of debian: "
        echo "e.g. /debian/dists/stable/main/$ARCH/"
        echo 

        TRY="/debian/dists/stable/main/$ARCH ~ftp/debian/dists/stable/main/$ARCH ../$ARCH"
        for i in $TRY ; do
            if [ -d $i ] ; then
                DEFAULT=$i
            fi
        done 

        [ -n "$DEFAULT" ] && echo or just hit enter to use "$DEFAULT".

        read DM

        [ -z "$DM" ] && DM=$DEFAULT

        SEDSCRIPT="s:\([^ /]*/\):$DM/\1:g"
        ;;

    f|F)

        # Download the files via FTP
        cat <<EOF
        You have chosen to get the required files by ftp.
        Enter [1] to use the U.S. mirror ftp.debian.org;
        or [2] to use the European mirror ftp.infodrom.north.de;
        or [3] to enter another mirror site.  If you choose [3],
        you will also be asked to enter the directory path to be used.
EOF
        echo -n "Select your mirror site: (1/2/3) "
        read site
        case $site in
             1)
                  FTP_SITE=$FTP_SITE_1
                  FTP_DIR=$FTP_DIR_1 ;;
             2)
                  FTP_SITE=$FTP_SITE_2 
                  FTP_DIR=$FTP_DIR_2 ;;
             3)
                  echo "Enter the hostname of your mirror site:"
		  echo -n "> "
                  read FTP_SITE
                  echo "Enter the ftp path (like debian/hamm/hamm/$ARCH):"
		  echo -n "> "
                  read FTP_DIR ;;
        esac

        # Find download directory
        echo
        echo "Where do you want the files to be stored? "
        echo

        TRY="/tmp/autoup /tmp"
        for i in $TRY ; do
            if [ -d $i -a -z "$DEFAULT" ] ; then
                DEFAULT=$i
            fi
        done

        [ -n "$DEFAULT" ] && echo or just hit enter to use "$DEFAULT".

	echo -n "> "
        read DM

        [ -z "$DM" ] && DM=$DEFAULT

        SEDSCRIPT="s:\([^ /]*/\):$DM/\1:g"

        FTP_DEST=$DM

        # Fetch files
        cd $FTP_DEST

        # create directories for fetches files
        for file in $ALLPKGS; do
            mkdir -p `dirname $file`
        done

        echo "Fetching packages from: $FTP_SITE"

        ftpscript="$DM.$$.scr"

        cat <<__EOF__ >$ftpscript
            verbose
            open $FTP_SITE
            user anonymous libc6-upgrade@autoup.sh.debian.org
            hash
            binary
            cd $FTP_DIR
            pwd
__EOF__

        for file in $ALLPKGS; do
            cat <<__EOF__ >>$ftpscript
                cd $FTP_DIR/$(dirname $file)
                lcd $FTP_DEST/$(dirname $file)
                mget $(basename $file)
__EOF__
        done

        ftp -n -i <$ftpscript


        echo
        echo "All needed files downloaded, starting install..."
        echo

        ;;
        # ---------- end ftp area

    c|C)
        # current directory
        SEDSCRIPT='s:[^ /]*/::g'
        ;;
esac

echo
echo
echo "building list of package filenames to install..."

# convert PKGS_ variables to correct directory location
PKGS_LDSO=$( echo "$PKGS_LDSO" | sed -e "$SEDSCRIPT" )
PKGS_LIBC5=$( echo "$PKGS_LIBC5" | sed -e "$SEDSCRIPT" )
PKGS_LIBC6=$( echo "$PKGS_LIBC6" | sed -e "$SEDSCRIPT" )
PKGS_NCURSES=$( echo "$PKGS_NCURSES" | sed -e "$SEDSCRIPT" )
PKGS_LIBRL=$( echo "$PKGS_LIBRL" | sed -e "$SEDSCRIPT" )
PKGS_LIBRLG=$( echo "$PKGS_LIBRLG" | sed -e "$SEDSCRIPT" )
PKGS_BASH=$( echo "$PKGS_BASH" | sed -e "$SEDSCRIPT" )
PKGS_LIBGPP=$( echo "$PKGS_LIBGPP" | sed -e "$SEDSCRIPT" )
PKGS_SLANG=$( echo "$PKGS_SLANG" | sed -e "$SEDSCRIPT" )
PKGS_DPKG=$( echo "$PKGS_DPKG" | sed -e "$SEDSCRIPT" )
PKGS_LIBGDBM=$( echo "$PKGS_LIBGDBM" | sed -e "$SEDSCRIPT" )
PKGS_PERLBASE=$( echo "$PKGS_PERLBASE" | sed -e "$SEDSCRIPT" )
PKGS_PERL=$( echo "$PKGS_PERL" | sed -e "$SEDSCRIPT" )
PKGS_MOREDPKG=$( echo "$PKGS_MOREDPKG" | sed -e "$SEDSCRIPT" )
PKGS_NETBASE=$( echo "$PKGS_NETBASE" | sed -e "$SEDSCRIPT" )
PKGS_NETSTD=$( echo "$PKGS_NETSTD" | sed -e "$SEDSCRIPT" )


echo "checking that all needed files are available..."
# sanity check that we can find the packages

ALLPKGS=$( echo "$ALLPKGS" | sed -e "$SEDSCRIPT" )

for i in $ALLPKGS ; do
    echo -n "$(basename $i) "
    if [ ! -f $i ] ; then
        echo 
        echo "Can't find $i!"
        echo aborting upgrade.
        exit 100
    fi
done

echo 
echo 
echo "all needed files found." 
echo

# make the tarball if called with --make-tarfiles

if [ "$1" == "--make-tarfiles" ] ; then
    mkdir debfiles
    cd debfiles
    ln -s $ALLPKGS .
    tar chfz ../autoup.tar.gz *
    cd ..
	exit 0
fi


#
# libc5
#
echo "installing libc5."

$DPKG $DPKG_ARGS $PKGS_LIBC5 || exit 2

#
# if this is a buzz system, then first upgrade dpkg to version 1.4.0.8 
#
DPKG_VER=$(dpkg -s dpkg | grep Version: | awk '{print $2}')
DPKG_MINOR=$(echo $DPKG_VER | awk -F"." '{print $2}')

# uncomment for testing
#DPKG_MINOR=3

# bo dpkg is now in /debian/dists/stable/main/upgrade-i386/dpkg_1.4.0.8.deb
# a quick hack to s=binary-i386/base=upgrade-i386= should fix it.  
#
# actually, that sucks and this whole section should be rewritten. it
# doesn't work for ftp upgrades anyway....it assumes that bo dpkg is
# available on a local disk.   i'm tempted to just delete all this stuff.
# maybe the best thing to do is still check for bo, but don't do
# anything except tell the user to download and install dpkg 1.4.0.8
# before continuing.

if [ $DPKG_MINOR -lt 4 ] ; then
    BO_DPKG="./dpkg_1.4.0.8.deb"
    BO_SEDSCRIPT=$(echo "$SEDSCRIPT" | \
        sed -e 's/unstable/stable/g' -e 's/frozen/stable/g' \
            -e 's/hamm/bo/g' -e 's=binary-i386=upgrade-i386=g' )
    BO_DPKG=$(echo $BO_DPKG | sed -e "$BO_SEDSCRIPT")

    if [ ! -f $BO_DPKG ] ; then
        echo "can't find $BO_DPKG, which is needed to upgrade your buzz system to hamm"
        exit 2
    fi

    echo "installing dpkg from bo."
    $DPKG $DPKG_ARGS $BO_DPKG  || exit 2
fi


RMFILE="/root/autoup.removed-$DATE"

# Now we start the install

# First get rid of essential package timezone to permit installation of
# replacement timezones.
#
# I don't like forcing dpkg, but I can see no alternative. timezone is
# required, but shouldn't really be "essential", and this was corrected
# in bo.

$DPKG -l timezone | grep -q "^.i" && TIMEZONE=1

if [ "$TIMEZONE" = "1" ] ; then 
    echo
    echo "Removing package timezone to permit replacing it with timezones."
    echo

    $DPKG --force-remove-essential -r timezone 
fi

# Now build list of incompatible packages to be removed if installed.

RMPKGS="xmanpages perl-suid perl-debug wg15-locale libpthread0 xslib 
        splay boot-floppies localebin"

RMGREP=$(echo "$RMPKGS" | xargs echo | sed -e 's/ /\\\|/g')

PKGS_RM=$(dpkg -l | grep "^.i" | grep -w "$RMGREP" | awk '{print $2}')

# build up a list of installed -dev packages so that we can remove them.
#
# this is necessary even on machines which aren't doing libc6
# development because libc5 can't be upgraded to latest version without
# removal of libc5-dev which also necessitates removal of other -dev
# packages like libdb1-dev and libdl1-dev if they are installed.

DEVPACKAGES=$( dpkg --get-selections | 
    grep -v "dpkg-dev\|deinstall" | 
    cut -f1 |
    grep -- "-dev$\|-pic$\|-dbg$" )

# don't bother running 'dpkg -r' if there's nothing to remove.
RM_LIST="$DEVPACKAGES $PKGS_RM"

if [ ! "$RM_LIST" = " " ] ; then
    # log what gets removed.
    echo "Packages Removed by autopup script on $DATE :" > $RMFILE
    echo "Development packages: " >> $RMFILE
    echo "$DEVPACKAGES" >> $RMFILE
    echo "Other packages that were incompatible with the upgrade:" >> $RMFILE
    echo -n "timezone " >> $RMFILE
    echo $PKGS_RM >> $RMFILE

    # and finally remove them.
    echo 
    echo "removing incompatible and development packages."

    $DPKG --remove --force-hold -B $RM_LIST || exit 1
fi 


# now install the new versions of things.  Just the bare minimum to let
# the user safely run dselect for the rest of the upgrade.

echo 
echo "installing packages."

# libc
#
$DPKG $DPKG_ARGS $PKGS_LDSO || exit 2
$DPKG $DPKG_ARGS $PKGS_LIBC6 || exit 2

# libreadline, ncurses, and bash
#
$DPKG $DPKG_ARGS $PKGS_NCURSES || exit 3
$DPKG $DPKG_ARGS $PKGS_LIBRL || exit 4
$DPKG $DPKG_ARGS $PKGS_LIBRLG || exit 5

# paranoia says run ldconfig NOW. don't laugh, i've needed to do this on
# some libc5-libc6 upgrades. i know that the postinst scripts for the
# libs are supposed to do it but ....
$LDCONFIG
$DPKG $DPKG_ARGS $PKGS_BASH || exit 6

# new dpkg
#
$DPKG $DPKG_ARGS $PKGS_LIBGPP || exit 7
$DPKG $DPKG_ARGS $PKGS_DPKG

# slang
$DPKG $DPKG_ARGS $PKGS_SLANG || exit 7

# perl
#
$DPKG $DPKG_ARGS $PKGS_LIBGDBM || exit 8
# paranoia says "run ldconfig now".
$LDCONFIG

# Unlike a bo installation, in rex, dpkg removes perl when installing
# perl-base, and must de-configure many packages (9 on my system)
# first.  Since these packages can not be re-configured until perl is
# installed and configured, the following line will always cause an
# error, therefore the "|| exit 9" is commented out in this line.

$DPKG $DPKG_ARGS $PKGS_PERLBASE # || exit 9

[ -e /usr/lib/perl5/i486-linux/5.003/auto/Mail/.packlist ] && rm -f /usr/lib/perl5/i486-linux/5.003/auto/Mail/.packlist

$DPKG $DPKG_ARGS $PKGS_PERL # || exit 9

# When perl is setup, it should(?) configure the de-configured packages.
# However, paranoia says to comment out the "|| exit 9" and run
# configure. exit at this point if there are packages which failed to
# configure.

$DPKG --configure --pending || exit 9
cat<<EOF 

I have tried to remove any packages that would be broken by the upgrade,
but I may have missed some.  If any "Errors were encountered while
processing:" messages appear above, those packages must be removed or
replaced with their equivalent from hamm.

press [ENTER] to continue"

EOF
read 

# strictly speaking, dpkg-ftp and dpkg-mountable are not essential to
# upgrade right now but they're both very useful.
$DPKG $DPKG_ARGS $PKGS_MOREDPKG

# and now netbase and netstd
$DPKG $DPKG_ARGS $PKGS_NETBASE
$DPKG $DPKG_ARGS $PKGS_NETSTD

# paranoia says to run this at the end
$DPKG --configure --pending

# paranoia says: "run sync", so lets do it :-)
sync ; sync ; sync 


# FINISHED!

# the user can now run dselect and select any -dev packages they want
# (and other packages too, of course :-)


more <<__EOF__

libc6 is now installed.  Now run dselect to upgrade the rest of your
system.[1]  When that's done, reboot with "shutdown -r now" for the
utmp/wtmp wrapper functions in the upgraded libc5 to take effect.

BTW, if you aren't using it already, check out dselect's "mountable"
access method.  It's much faster than the standard "mounted" method, and
it logs everything that happens in /var/log/dpkg-mountable.  You'll want
to set "Allow overwriting repeated files?" to yes, and for extra speed
set "Enable MD5 checksumming?" to no.

If you are installing manually using dpkg, remember that all libc6 (g)
libraries conflict with all the versions of their libc5 (non-g)
counterparts prior to a certain version which placed libc5 libs in
/usr/lib/libc5-compat.  This means that they conflict with your bo
versions of libc5-linked libraries, but not the hamm versions.  For
example, if you are installing xlib6g, you should install xlib6 from
hamm first before installing xlib6g unless you have nothing that depend
on xlib6 in which case you can safely remove it.

All development packages (-dev, -dbg, and -pic) and a number of other
incompatible packages have been removed during this upgrade procedure
due to conflicts between libc5 and libc6 versions.  A list of the
removed packages are in file $RMFILE in this directory.
You will have to re-install any of these packages you need.

Finally, remember to fix up wtmp and utmp, otherwise last and
who and sac etc won't work. here's what Miquel van Smoorenburg
<miquels@cistron.nl> had to say about this recently in debian-user
mailing list:

    > 1. You need to update ALL your packages to hamm
    > 2. Reboot if you haven't done that already
    > 3. You need to move the wtmp file and truncate the utmp file:
    >    cd /var/log
    >    mv wtmp wtmp.libc5
    >    touch wtmp
    >    cd /var/run
    >    cp /dev/null utmp
    > 4. You might want to reboot again to make sure
    > 
    > This is because the "struct utmp" and thus the utmp and wtmp
    > "databases" are different between libc5 and libc6

[1]  Note the following from the libc5-libc6-Mini-HOWTO:
4.5.  Upgrading to stable by FTP

  The directory structure of the ftp site has been slightly modified,
  placing the contrib and non-free sections of the archive alongside the
  main section, to avoid contrib and non-free getting out of sync with
  earlier portions of the archives.  You must have dpkg-ftp_1.4.9 or
  greater to update your machine using dpkg-ftp.  If you are updating
  your machine via ftp, the proper information to give dpkg-ftp is:

  o  Enter debian directory: /debian

  o  Enter space separated list of distributions to get:
     dists/stable/main dists/stable/non-free dists/stable/contrib
__EOF__
