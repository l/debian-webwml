# Configuration for packages.debian.org
#

topdir=/org/packages.ubuntu.com

tmpdir=${topdir}/tmp
bindir=${topdir}/bin
scriptdir=${topdir}/htmlscripts
libdir=${topdir}/lib
filesdir=${topdir}/files
htmldir=${topdir}/www
archivedir=${topdir}/archive
podir=${topdir}/po
localedir=${topdir}/locale
staticdir=${topdir}/static
configdir=${topdir}/etc

# unset this if packages.debian.org moves somewhere where the packages files
# cannot be obtained locally
#
#localdir=/org/archive.ubuntu.com

ftpsite=http://archive.ubuntu.com/ubuntu
#nonus_ftpsite=http://ftp.uk.debian.org/debian-non-US
security_ftpsite=$ftpsite
# path to private ftp directory
#ftproot=/org/ftp.root

# Architectures
#
polangs="de nl fr"
ddtplangs="de cs da eo es fi fr hu it ja nl pl pt_BR pt_PT ru sk sv_SE uk"
parts="main multiverse restricted universe"
dists="dapper dapper-backports edgy edgy-backports feisty feisty-backports gutsy gutsy-backports"
arch_dapper="i386 amd64 powerpc"
arch_dapper_updates="${arch_dapper}"
arch_dapper_backports="${arch_dapper}"
arch_edgy="${arch_dapper}"
arch_edgy_updates="${arch_edgy}"
arch_edgy_backports="${arch_edgy}"
arch_feisty="${arch_edgy}"
arch_feisty_updates="${arch_feisty}"
arch_feisty_backports="${arch_feisty}"
arch_gutsy="${arch_feisty}"
arch_gutsy_updates="${arch_gutsy}"
arch_gutsy_backports="${arch_gutsy}"

# Miscellaneous
#
admin_email="djpig@debian.org"
