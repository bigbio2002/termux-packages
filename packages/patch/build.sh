TERMUX_PKG_HOMEPAGE=https://savannah.gnu.org/projects/patch/
TERMUX_PKG_DESCRIPTION="GNU patch which applies diff files to create patched files"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="2.8.1"
TERMUX_PKG_SRCURL=https://mirrors.kernel.org/gnu/patch/patch-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=3240c7959c5347c8ed347e3c4201c0337bf4240d5cf09d68889e58eeaba30e17
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--disable-xattr ac_cv_path_ED=$TERMUX_PREFIX/bin/ed"
TERMUX_PKG_GROUPS="base-devel"
