# Skeleton build.sh script for new package.
# For reference about available fields, check the Termux Developer's Wiki page:
# https://github.com/termux/termux-packages/wiki/Creating-new-package

TERMUX_PKG_HOMEPAGE=https://github.com/ajkaijanaho/dctrl-tools/
TERMUX_PKG_DESCRIPTION="Command-line tools to process Debian package information"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="Harry Weinstein @bigbio2002"
TERMUX_PKG_VERSION="2.24"
#TERMUX_PKG_REVISION=
TERMUX_PKG_SRCURL=https://deb.debian.org/debian/pool/main/d/dctrl-tools/dctrl-tools_${TERMUX_PKG_VERSION}.orig.tar.gz
TERMUX_PKG_SHA256=949653246a777e5e5835dd490003c72573cee45184e82369fba2fdd037af15d1
TERMUX_PKG_DEPENDS="argp"
TERMUX_PKG_BUILD_IN_SRC=true
termux_step_configure()
{
# no configure required
true
}
termux_step_make()
{
#make grep-dctrl/grep-dctrl prefix=$TERMUX_PREFIX sysconfdir=$TERMUX_PREFIX/etc
make all-no-mo mo prefix=$TERMUX_PREFIX sysconfdir=$TERMUX_PREFIX/etc
}
termux_step_make_install()
{
make install prefix=$TERMUX_PREFIX sysconfdir=$TERMUX_PREFIX/etc
#install -m755 grep-dctrl/grep-dctrl $TERMUX_PREFIX/bin
}
