# Configuration for packages.debian.org
#

topdir=/org/packages.debian.org

tmpdir=${topdir}/tmp
bindir=${topdir}/bin
scriptdir=${topdir}/htmlscripts
libdir=${topdir}/lib
filesdir=${topdir}/files
swishdir=${topdir}/swish++
htmldir=${topdir}/www
archivedir=${topdir}/archive
podir=${topdir}/po
localedir=${topdir}/locale

# unset this if packages.debian.org moves somewhere where the packages files
# cannot be obtained locally
#
localdir=/org/ftp.debian.org/ftp

# path to private ftp directory
ftproot=/org/ftp.root

ftpsite=http://ftp.debian.org/debian
nonus_ftpsite=http://ftp.uk.debian.org/debian-non-US
security_ftpsite=http://security.debian.org/debian-security

# Architectures
#
polangs="de nl"
ddtplangs="de cs da eo es fi fr hu it ja nl pl pt_BR pt_PT ru sk sv_SE uk"
parts="main contrib non-free"
dists="stable testing unstable"
arch_stable="alpha arm hppa i386 ia64 m68k mips mipsel powerpc s390 sparc"
arch_testing="${arch_stable}"
arch_unstable="alpha arm hppa hurd-i386 i386 ia64 m68k mips mipsel powerpc s390 sparc"
arch_experimental="${arch_unstable}"
arch_testing_proposed_updates="${arch_testing}"
arch_stable_proposed_updates="${arch_stable}"
