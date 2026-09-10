TERMUX_PKG_HOMEPAGE=https://www.yoctoproject.org/tools-resources/projects/matchbox
TERMUX_PKG_DESCRIPTION="X virtual keyboard library."
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=0.3
TERMUX_PKG_REVISION=22
TERMUX_PKG_SRCURL=https://github.com/bigbio2002/libfakekey/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
#TERMUX_PKG_SRCURL=https://git.yoctoproject.org/cgit/cgit.cgi/libfakekey/snapshot/libfakekey-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=d282fa6481a5b85f71e36e8bad4cfa938cc8eaac4c42ffa27f9203ac634813f4
# alternate source from Debian
#TERMUX_PKG_VERSION=0.3+git20170516
#TERMUX_PKG_SRCURL=https://deb.debian.org/debian/pool/main/libf/libfakekey/libfakekey_${TERMUX_PKG_VERSION}.orig.tar.xz
#TERMUX_PKG_SHA256=ddbd308dc7f20390b2a6cb88bd077a62061a40533e209a14a94bdb36b32a0446
TERMUX_PKG_DEPENDS="libx11, libxtst"
TERMUX_PKG_EXTRA_MAKE_ARGS="AM_LDFLAGS=-lX11"

termux_step_pre_configure() {
	autoreconf -i
}
