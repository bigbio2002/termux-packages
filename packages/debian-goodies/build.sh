# Skeleton build.sh script for new package.
# For reference about available fields, check the Termux Developer's Wiki page:
# https://github.com/termux/termux-packages/wiki/Creating-new-package

TERMUX_PKG_HOMEPAGE=https://salsa.debian.org/debian/debian-goodies/
TERMUX_PKG_DESCRIPTION="Small toolbox-style utilities for Debian systems"
TERMUX_PKG_LICENSE="GPL-2.0-or-later"
TERMUX_PKG_MAINTAINER="Harry Weinstein @bigbio2002"
TERMUX_PKG_VERSION=0.88.2
#TERMUX_PKG_REVISION=
TERMUX_PKG_SRCURL=https://deb.debian.org/debian/pool/main/d/debian-goodies/debian-goodies_${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=d358e63d9df46513003c8376ce545f8d5b7a7314e6ab6c41b792f52feebd2213
TERMUX_PKG_DEPENDS="dctrl-tools"
#TERMUX_PKG_BREAKS=""
#TERMUX_PKG_REPLACES=""
TERMUX_PKG_BUILD_IN_SRC=true
#TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
#"
