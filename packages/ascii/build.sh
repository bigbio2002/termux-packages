# Skeleton build.sh script for new package.
# For reference about available fields, check the Termux Developer's Wiki page:
# https://github.com/termux/termux-packages/wiki/Creating-new-package

TERMUX_PKG_HOMEPAGE=http://www.catb.org/~esr/ascii/
TERMUX_PKG_DESCRIPTION="Displays an ASCII table"
TERMUX_PKG_LICENSE="BSD 2-clause?"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="3.30"
#TERMUX_PKG_REVISION=
TERMUX_PKG_SRCURL=http://www.catb.org/~esr/ascii/ascii-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=
#TERMUX_PKG_DEPENDS=""
TERMUX_PKG_BUILD_DEPENDS="asciidoctor"
#TERMUX_PKG_BREAKS=""
#TERMUX_PKG_REPLACES=""
TERMUX_PKG_BUILD_IN_SRC=true
#TERMUX_PKG_EXTRA_CONFIGURE_ARGS=""
