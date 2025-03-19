TERMUX_PKG_HOMEPAGE=https://github.com/ib/xarchiver
TERMUX_PKG_DESCRIPTION="GTK+ frontend to various command line archivers"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.5.4.24"
TERMUX_PKG_SRCURL=https://github.com/ib/xarchiver/archive/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=ac5775309820196761a7fab4355251e0e74b7fa09156db279b3a440183f97bd7
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_DEPENDS="gdk-pixbuf, glib, gtk3"
TERMUX_PKG_RECOMMENDS="arj, binutils-is-llvm | binutils, bzip2, cpio, gzip, lz4, lzip, lzop, p7zip, tar, unar, unrar, unzip, xz-utils, zip, zstd"
