TERMUX_PKG_HOMEPAGE=https://libmateweather.mate-desktop.dev/
TERMUX_PKG_DESCRIPTION="libmateweather is a libgnomeweather fork."
TERMUX_PKG_LICENSE="LGPL-2.1, GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.28.0"
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=https://github.com/mate-desktop/libmateweather/releases/download/v$TERMUX_PKG_VERSION/libmateweather-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=2094a4ba78da7a4b75536ea8e45ccdc00691adfe1c13a557c8a77dcd76450a8b
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="atk, gdk-pixbuf, glib, gtk3, harfbuzz, libcairo, libsoup, libxml2, pango, zlib"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-locations-compression
"
