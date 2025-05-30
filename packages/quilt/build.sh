TERMUX_PKG_HOMEPAGE=https://savannah.nongnu.org/projects/quilt
TERMUX_PKG_DESCRIPTION="Allows you to easily manage large numbers of patches"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.69"
TERMUX_PKG_SRCURL=https://savannah.nongnu.org/download/quilt/quilt-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=555ddffde22da3c86d1caf5a9c1fb8a152ac2b84730437bd39cc08849c9f4852
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="coreutils, diffstat, gawk, perl"
#TERMUX_PKG_DEPENDS+=", graphviz"
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-diffstat=$TERMUX_PREFIX/bin/diffstat
--without-7z
--without-rpmbuild
--without-sendmail
"

termux_step_post_make_install() {
	ln -sf $TERMUX_PREFIX/bin/gawk $TERMUX_PREFIX/share/quilt/compat/awk
}
