TERMUX_PKG_HOMEPAGE=https://simdjson.org/
TERMUX_PKG_DESCRIPTION="A C++ library to see how fast we can parse JSON with complete validation"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="3.12.0"
TERMUX_PKG_SRCURL=https://github.com/simdjson/simdjson/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=1e5e82f0a34c331c1b0d0c21609791bfe6d6849edfc24983fc241626b433e1c3
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DBUILD_SHARED_LIBS=ON
"
