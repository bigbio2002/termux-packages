TERMUX_PKG_HOMEPAGE=https://redis.com/lp/hiredis
TERMUX_PKG_DESCRIPTION="Hiredis is a minimalistic C client library for the Redis database"
TERMUX_PKG_LICENSE="BSD 3-Clause"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.2.0"
TERMUX_PKG_SRCURL=https://github.com/redis/hiredis/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=82ad632d31ee05da13b537c124f819eb88e18851d9cb0c30ae0552084811588c
TERMUX_PKG_BUILD_DEPENDS="binutils"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
