TERMUX_PKG_HOMEPAGE=https://beyondgrep.com/
TERMUX_PKG_DESCRIPTION="Tool like grep optimized for programmers"
TERMUX_PKG_LICENSE="Artistic-License-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="3.8.0"
TERMUX_PKG_SRCURL=https://beyondgrep.com/ack-v${TERMUX_PKG_VERSION}
TERMUX_PKG_SHA256=09886aa5a1aa0244f9fef98ebe78823497b07211f42b60914a0187f566dfb121
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="perl"
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	termux_download \
		$TERMUX_PKG_SRCURL \
		$TERMUX_PREFIX/bin/ack \
		$TERMUX_PKG_SHA256
	touch $TERMUX_PREFIX/bin/ack
	chmod +x $TERMUX_PREFIX/bin/ack
}
