# Configuration for packages.debian.org
#

topdir=/org/packages.debian.org

bindir=${topdir}/bin
filesdir=${topdir}/files
swishdir=${topdir}/swish++
htmldir=${topdir}/www
archivedir=${topdir}/archive

# unset this if packages.debian.org moves somewhere where the packages files
# cannot be obtained locally
#
localdir=/org/ftp.debian.org/ftp

ftpsite=http://ftp.debian.org/debian
nonus_ftpsite=http://ftp.uk.debian.org/debian-non-US
security_ftpsite=http://security.debian.org/debian-security

# Architectures
#
parts="main contrib non-free"
dists="stable testing unstable"
arch_stable="alpha arm hppa i386 ia64 m68k mips mipsel powerpc s390 sparc"
arch_testing="${arch_stable}"
arch_unstable="alpha arm hppa hurd-i386 i386 ia64 m68k mips mipsel powerpc s390 sparc"
arch_experimental="${arch_unstable}"
arch_testing_proposed_updates="${arch_testing}"
arch_stable_proposed_updates="${arch_stable}"
