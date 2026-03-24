TERMUX_PKG_HOMEPAGE=https://sourceware.org/binutils
TERMUX_PKG_DESCRIPTION="GNU binutils"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="2.42"
TERMUX_PKG_SRCURL=https://ftp.gnu.org/gnu/binutils/binutils-${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=f6e4d41fd5fc778b06b7891457b3620da5ecea1006c6a4a41ae998109f85a800
TERMUX_PKG_BUILD_IN_SRC=true
#TERMUX_PKG_DEPENDS=
#TERMUX_PKG_BUILD_DEPENDS=
#TERMUX_PKG_RECOMMENDS=
#TERMUX_PKG_SUGGESTS=
#TERMUX_PKG_BREAKS=
#TERMUX_PKG_CONFLICTS=
#TERMUX_PKG_REPLACES=

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--bindir=$TERMUX_PREFIX/libexec/binutils
--disable-nls
--enable-build-warnings
--enable-threads
--with-system-zlib
--enable-plugins
--enable-gold
--enable-gprofng=no
--disable-gprofng-tools
--enable-new-dtags
--enable-relro
--enable-64-bit-bfd
--enable-deterministic-archives
--enable-initfini-array
--enable-default-hash-style=gnu
--enable-eh-frame-hdr-for-static
--enable-colored-disassembly
--enable-generate-build-notes
--enable-x86-used-note
--enable-warn-execstack
--enable-warn-rwx-segments
--with-sysroot=/data/data/com.termux/files
"

termux_step_pre_configure() {
	export CFLAGS="$CFLAGS -std=gnu99"
	export CXXFLAGS="$CXXFLAGS -std=gnu++11"

	LIB_BITS=

	#cd $TERMUX_PKG_SRCDIR
	if (( TERMUX_ARCH_BITS == 64 )); then
	#	for patch64 in ./packages/${TERMUX_PKG_NAME}/*.patch64; do
	#		patch -Np1 < ${patch64}
	#	done
		LIB_BITS="64"
	elif (( TERMUX_ARCH_BITS == 32 )); then
	#	for patch32 in ./packages/${TERMUX_PKG_NAME}/*.patch32; do
	#		patch -Np1 < ${patch32}
	#	done
		true
	else
		termux_error_exit "Unsupported bitness: $TERMUX_ARCH_BITS"
	fi

	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --with-lib-path=${TERMUX_PREFIX}/lib:/system/lib${LIB_BITS}:${TERMUX_PREFIX}/${TERMUX_ARCH}-linux-android/lib"
}
