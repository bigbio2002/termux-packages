#!/bin/sh
#
# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#  This shell script is used to rebuild the gcc and toolchain binaries
#  for the Android NDK.
#

# include common function and variable definitions
. $NDK_BUILDTOOLS_PATH/prebuilt-common.sh

PROGRAM_PARAMETERS="<src-dir> <ndk-dir> <toolchain>"

PROGRAM_DESCRIPTION=\
"Rebuild the gcc toolchain prebuilt binaries for the Android NDK.

Where <src-dir> is the location of toolchain sources, <ndk-dir> is
the top-level NDK installation path and <toolchain> is the name of
the toolchain to use (e.g. arm-linux-androideabi-4.8)."

RELEASE=`date +%Y%m%d`
BUILD_OUT=$TMPDIR/build/toolchain
OPTION_BUILD_OUT=
register_var_option "--build-out=<path>" OPTION_BUILD_OUT "Set temporary build directory"

# Note: platform API level 9 or higher is needed for proper C++ support
register_var_option "--platform=<name>"  PLATFORM "Specify platform name"

OPTION_SYSROOT=
register_var_option "--sysroot=<path>"   OPTION_SYSROOT   "Specify sysroot directory directly"

BINUTILS_VERSION=$DEFAULT_BINUTILS_VERSION
EXPLICIT_BINUTILS_VERSION=
register_option "--binutils-version=<version>" do_binutils_version "Specify binutils version" "$BINUTILS_VERSION"
do_binutils_version () {
    BINUTILS_VERSION=$1
    EXPLICIT_BINUTILS_VERSION=true
}

GMP_VERSION=$DEFAULT_GMP_VERSION
register_var_option "--gmp-version=<version>" GMP_VERSION "Specify gmp version"

MPFR_VERSION=$DEFAULT_MPFR_VERSION
register_var_option "--mpfr-version=<version>" MPFR_VERSION "Specify mpfr version"

MPC_VERSION=$DEFAULT_MPC_VERSION
register_var_option "--mpc-version=<version>" MPC_VERSION "Specify mpc version"

CLOOG_VERSION=$DEFAULT_CLOOG_VERSION
register_var_option "--cloog-version=<version>" CLOOG_VERSION "Specify cloog version"

ISL_VERSION=$DEFAULT_ISL_VERSION
register_var_option "--isl-version=<version>" ISL_VERSION "Specify ISL version"

PPL_VERSION=$DEFAULT_PPL_VERSION
register_var_option "--ppl-version=<version>" PPL_VERSION "Specify ppl version"

PACKAGE_DIR=
register_var_option "--package-dir=<path>" PACKAGE_DIR "Create archive tarball in specific directory"

ENABLE_LANGUAGES="c,c++"
register_var_option "--enable-languages=<name>" ENABLE_LANGUAGES "Experimental: specify which languages to build"

BUILD_DEBUGGABLE="no"
register_var_option "--build-debuggable=<yes|no>" BUILD_DEBUGGABLE "Experimental: build debuggable version of gcc."

OBSCURE_PREFIX="yes"
register_var_option "--obscure-prefix=<yes|no>" OBSCURE_PREFIX "Experimental: obscure sysroot prefix dir by linking to it from /tmp"

register_jobs_option
register_canadian_option
register_try64_option

extract_parameters "$@"

prepare_canadian_toolchain $TMPDIR/build

fix_option BUILD_OUT "$OPTION_BUILD_OUT" "build directory"
setup_default_log_file $BUILD_OUT/config.log

set_parameters ()
{
    SRC_DIR="$1"
    NDK_DIR="$2"
    TOOLCHAIN="$3"

    # Check source directory
    #
    if [ -z "$SRC_DIR" ] ; then
        echo "ERROR: Missing source directory parameter. See --help for details."
        exit 1
    fi
    if [ ! -d "$SRC_DIR/gcc" ] ; then
        echo "ERROR: Source directory does not contain gcc sources: $SRC_DIR"
        exit 1
    fi
    SRC_DIR=`cd $SRC_DIR; pwd`
    log "Using source directory: $SRC_DIR"

    # Check NDK installation directory
    #
    if [ -z "$NDK_DIR" ] ; then
        echo "ERROR: Missing NDK directory parameter. See --help for details."
        exit 1
    fi

    if [ ! -d "$NDK_DIR" ] ; then
        mkdir -p $NDK_DIR
        if [ $? != 0 ] ; then
            echo "ERROR: Could not create target NDK installation path: $NDK_DIR"
            exit 1
        fi
    fi
    NDK_DIR=`cd $NDK_DIR; pwd`
    log "Using NDK directory: $NDK_DIR"

    # Check toolchain name
    #
    if [ -z "$TOOLCHAIN" ] ; then
        echo "ERROR: Missing toolchain name parameter. See --help for details."
        exit 1
    fi
}

set_parameters $PARAMETERS

prepare_target_build

parse_toolchain_name $TOOLCHAIN

if [ -z "$PLATFORM" ]; then
   PLATFORM="android-"$(get_default_api_level_for_arch $ARCH)
fi

fix_sysroot "$OPTION_SYSROOT"

check_toolchain_src_dir "$SRC_DIR"

if [ -z "$EXPLICIT_BINUTILS_VERSION" ]; then
    BINUTILS_VERSION=$(get_default_binutils_version_for_gcc $TOOLCHAIN)
    dump "Auto-config: --binutils-version=$BINUTILS_VERSION"
fi

if [ ! -d $SRC_DIR/binutils/binutils-$BINUTILS_VERSION ] ; then
    echo "ERROR: Missing binutils sources: $SRC_DIR/binutils/binutils-$BINUTILS_VERSION"
    echo "       Use --binutils-version=<version> to specify alternative."
    exit 1
fi

fix_option MPFR_VERSION "$OPTION_MPFR_VERSION" "mpfr version"
if [ ! -f $SRC_DIR/mpfr/mpfr-$MPFR_VERSION.tar.bz2 ] ; then
    echo "ERROR: Missing mpfr sources: $SRC_DIR/mpfr/mpfr-$MPFR_VERSION.tar.bz2"
    echo "       Use --mpfr-version=<version> to specify alternative."
    exit 1
fi

if [ "$PACKAGE_DIR" ]; then
    mkdir -p "$PACKAGE_DIR"
    fail_panic "Could not create package directory: $PACKAGE_DIR"
fi

set_toolchain_ndk $NDK_DIR $TOOLCHAIN

if [ "$MINGW" != "yes" -a "$DARWIN" != "yes" ] ; then
    dump "Using C compiler: $CC"
    dump "Using C++ compiler: $CXX"
fi

rm -rf $BUILD_OUT
mkdir -p $BUILD_OUT

# Location where the toolchain license files are
TOOLCHAIN_LICENSES=$ANDROID_NDK_ROOT/build/tools/toolchain-licenses

# Without option "--sysroot" (and its variations), GCC will attempt to
# search path specified by "--with-sysroot" at build time for headers/libs.
# Path at --with-sysroot contains minimal headers and libs to bootstrap
# toolchain build, and it's not needed afterward (NOTE: NDK provides
# sysroot at specified API level, and Android build explicit lists header/lib
# dependencies.
#
# It's better to point --with-sysroot to local directory otherwise the
# path may be found at compile-time and bad things can happen: eg.
#  1) The path exists and contain incorrect headers/libs
#  2) The path exists at remote server and blocks GCC for seconds
#  3) The path exists but not accessible, which crashes GCC!

# For canadian build --with-sysroot has to be sub-directory of --prefix.
if [ -z "$HOST_TAG" ]; then
    echo "Error: HOST_TAG not set!"
    exit 1
fi

TOOLCHAIN_SUBDIR=$TOOLCHAIN
TOOLCHAIN_INSTALL_PATH=$TMPDIR/$TOOLCHAIN_SUBDIR
dump "Using TOOLCHAIN_INSTALL_PATH=$TOOLCHAIN_INSTALL_PATH"
dump "Using TOOLCHAIN_SUBDIR=$TOOLCHAIN_SUBDIR"
TOOLCHAIN_BUILD_SYSROOT=$TOOLCHAIN_INSTALL_PATH/sysroot
dump "Sysroot  : Copying: $SYSROOT --> $TOOLCHAIN_BUILD_SYSROOT"
mkdir -p $TOOLCHAIN_BUILD_SYSROOT && (cd $SYSROOT && tar chf - *) | (cd $TOOLCHAIN_BUILD_SYSROOT && tar xf -)
if [ $? != 0 ] ; then
    echo "Error while copying sysroot files. See $TMPLOG"
    exit 1
fi

PREFIX_LOCATION=$TOOLCHAIN_INSTALL_PATH
BUILD_SYSROOT_LOCATION=$TOOLCHAIN_BUILD_SYSROOT

# If enabled, use symbolic link to obscure prefix location (b/25513824)
if [ "$OBSCURE_PREFIX" == "yes" ]; then
    TAG=`echo $ARGV $$ $RELEASE | md5sum | cut -f1 -d" "`
    rm -f /tmp/$TAG
    ln -s $PREFIX_LOCATION /tmp/$TAG
    PREFIX_LOCATION=/tmp/$TAG
    BUILD_SYSROOT_LOCATION=/tmp/$TAG/sysroot
elif [ "$OBSCURE_PREFIX" != "no" ]; then
    echo "error: illegal value for --obscure-prefix option (must be 'yes' or 'no')"
    exit 1
fi

# configure the toolchain
#
dump "Configure: $TOOLCHAIN toolchain build"
# Old versions of the toolchain source packages placed the
# configure script at the top-level. Newer ones place it under
# the build directory though. Probe the file system to check
# this.
BUILD_SRCDIR=$SRC_DIR/build
if [ ! -d $BUILD_SRCDIR ] ; then
    BUILD_SRCDIR=$SRC_DIR
fi
OLD_ABI="${ABI}"
export CC CXX
export CFLAGS_FOR_TARGET="$ABI_CFLAGS_FOR_TARGET"
export CXXFLAGS_FOR_TARGET="$ABI_CXXFLAGS_FOR_TARGET"
# Needed to build a 32-bit gmp on 64-bit systems
export ABI=$HOST_GMP_ABI

# Note that the following flags only apply for "build" in canadian
if [ "$BUILD_DEBUGGABLE" = "yes" ] ; then
  CFLAGS_FOR_BUILD="-O0 -g"
else
  CFLAGS_FOR_BUILD="-O2 -s"
fi
CXXFLAGS_FOR_BUILD="$CFLAGS_FOR_BUILD"
LDFLAGS_FOR_BUILD=

if [ "$MINGW" = "yes" ] ; then
    CFLAGS_FOR_BUILD=$CFLAGS_FOR_BUILD" -D__USE_MINGW_ANSI_STDIO=1"
fi
CFLAGS="$CFLAGS_FOR_BUILD $HOST_CFLAGS"
CXXFLAGS="$CXXFLAGS_FOR_BUILD $HOST_CFLAGS"
LDFLAGS="$LDFLAGS_FOR_BUILD $HOST_LDFLAGS"
export CFLAGS CXXFLAGS LDFLAGS CFLAGS_FOR_BUILD LDFLAGS_FOR_BUILD
# This extra flag is used to slightly speed up the build
EXTRA_CONFIG_FLAGS="--disable-bootstrap"
if [ "$DARWIN" = "yes" ]; then
    # Disable plugin because in canadian cross build, plugin gengtype
    # will be incorrectly linked with build's library and fails.
    # ToDo
    EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" --disable-plugin"
else
    EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" --enable-plugins"
fi
# Enable OpenMP
EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" --enable-libgomp"
# Enable indirect functions in the compilers that support it (4.6 and above)
EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" --enable-gnu-indirect-function"
# Disable libcilkrts which needs C++ for now, because libstdlibc++ in NDK is
# built separately...
case "$TOOLCHAIN" in
    x86*-4.9) EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" --disable-libcilkrts"
esac
# Disable libsanitizer (which depends on libstdc++ built separately) for now
EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" --disable-libsanitizer"
# Enable Gold
ENABLE_GOLD_FLAGS=
case "$TOOLCHAIN" in
    # Note that only ARM/X86 >= GCC 4.6 and AARCH64 >= GCC 4.9 are supported
    mips*)
        # Don't use gold for mips/mips64.
    ;;
    aarch64*)
        # Enable ld.gold but ld.bfd remain the default
        ENABLE_GOLD_FLAGS="--enable-gold --enable-ld=default"
    ;;
    *)
        # Enable ld.gold as default
        ENABLE_GOLD_FLAGS="--enable-gold=default"
    ;;
esac
# Current mingw has an internal compiler error when building gold.
# Bug: http://b/22045105
if [ "$MINGW" = "yes" -a "$TRY64" = "no" ]; then
    ENABLE_GOLD_FLAGS=
fi
EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" "$ENABLE_GOLD_FLAGS
# We're not using gold for mips yet, and there is no support for threaded
# linking on Windows (no pthreads).
if [ "$TOOLCHAIN" != mips* -a "$MINGW" != "yes" ]; then
    EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" --enable-threads"
fi
# Enable linker option -eh-frame-hdr also for static executable
EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" --enable-eh-frame-hdr-for-static"
# Enable aarch64 workaround for Cortex-A53 Erratum number 835769
case "$TOOLCHAIN" in
    aarch64*-4.9) EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" --enable-fix-cortex-a53-835769"
esac
MAY_FAIL_DUE_TO_RACE_CONDITION=
if [ "$MINGW" = "yes" -o "$DARWIN" = "yes" ]; then
   MAY_FAIL_DUE_TO_RACE_CONDITION=yes
fi
# hack to use different set of sources
CONFIGURE_GCC_VERSION=$GCC_VERSION
case "$TOOLCHAIN" in
  *4.9l)
    CONFIGURE_GCC_VERSION=4.9l
    ;;
  *4.8l)
    CONFIGURE_GCC_VERSION=4.8l
    ;;
  *)
    ;;
esac
GCC_MAJOR_VERSION=`echo $GCC_VERSION | cut -f1 -d.`
# Enable Graphite
EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" --enable-graphite=yes --with-isl-version=$ISL_VERSION"
# Graphite requires cloog for gcc 4.x, but only isl for post-4.x
if [ $GCC_MAJOR_VERSION -le 4 ]; then
  EXTRA_CONFIG_FLAGS=$EXTRA_CONFIG_FLAGS" --with-cloog-version=$CLOOG_VERSION"
fi
# Build GNU sed so the configure script works for MIPS/MIPS64 on Darwin.
# http://b/22099482
cd $BUILD_OUT && run $SRC_DIR/sed/configure
if [ $? != 0 ] ; then
    dump "Error while trying to configure sed. See $TMPLOG"
    exit 1
fi
run make -j$NUM_JOBS
if [ $? != 0 ] ; then
    dump "Error while trying to build sed. See $TMPLOG"
    exit 1
fi
# Put our freshly-built GNU sed ahead of the system one on the path.
export PATH=$BUILD_OUT/sed/:$PATH
if [ -f $SRC_DIR/gcc/gcc-$GCC_VERSION/gcc/BASE-VER ] ; then
    INCLUDE_VERSION=`cat $SRC_DIR/gcc/gcc-$GCC_VERSION/gcc/BASE-VER`
else
    INCLUDE_VERSION=$GCC_VERSION
fi
cd $BUILD_OUT && run \
$BUILD_SRCDIR/configure --target=$ABI_CONFIGURE_TARGET \
                        --enable-bionic-libs \
                        --enable-libatomic-ifuncs=no \
                        --enable-initfini-array \
                        --host=$ABI_CONFIGURE_HOST \
                        --build=$ABI_CONFIGURE_BUILD \
                        --disable-nls \
                        --prefix=$PREFIX_LOCATION \
                        --with-sysroot=$BUILD_SYSROOT_LOCATION \
                        --with-binutils-version=$BINUTILS_VERSION \
                        --with-mpfr-version=$MPFR_VERSION \
                        --with-mpc-version=$MPC_VERSION \
                        --with-gmp-version=$GMP_VERSION \
                        --with-gcc-version=$CONFIGURE_GCC_VERSION \
                        --with-gdb-version=none \
                        --with-gxx-include-dir=$PREFIX_LOCATION/include/c++/$INCLUDE_VERSION \
                        --with-bugurl=$DEFAULT_ISSUE_TRACKER_URL \
                        --enable-languages=$ENABLE_LANGUAGES \
                        $EXTRA_CONFIG_FLAGS \
                        $ABI_CONFIGURE_EXTRA_FLAGS
if [ $? != 0 ] ; then
    dump "Error while trying to configure toolchain build. See $TMPLOG"
    exit 1
fi
ABI="$OLD_ABI"
# build the toolchain
dump "Building : $TOOLCHAIN toolchain [this can take a long time]."
cd $BUILD_OUT
export CC CXX
export ABI=$HOST_GMP_ABI
export NUM_JOBS
while [ -n "1" ]; do
    run make -j$NUM_JOBS
    if [ $? = 0 ] ; then
        break
    else
        if [ "$MAY_FAIL_DUE_TO_RACE_CONDITION" = "yes" ] ; then
            # Unfortunately, there is a bug in the GCC build scripts that prevent
            # parallel mingw/darwin canadian cross builds to work properly on some
            # multi-core machines (but not all, sounds like a race condition). Detect
            # this and restart in less parallelism, until -j1 also fail
            NUM_JOBS=$((NUM_JOBS/2))
            export NUM_JOBS
            if [ $NUM_JOBS -lt 1 ] ; then
                echo "Error while building mingw/darwin toolchain. See $TMPLOG"
                exit 1
            fi
            dump "Parallel canadian build failed - continuing in less parallelism -j$NUM_JOBS"
        else
            echo "Error while building toolchain. See $TMPLOG"
            exit 1
        fi
    fi
done
ABI="$OLD_ABI"
# install the toolchain to its final location.
dump "Install  : $TOOLCHAIN toolchain binaries."
cd $BUILD_OUT && run make install
if [ $? != 0 ] ; then
    # try "-j1", eg.  for aarch64-linux-android-4.8 with libatomic may fail to install due to race condition (missing prefix/lib/../lib64/./libiberty.an)
    NUM_JOBS=1
    export NUM_JOBS
    run make install -j$NUM_JOBS
    if [ $? != 0 ] ; then
        echo "Error while installing toolchain. See $TMPLOG"
        exit 1
    fi
fi
function install_missing_libs () {
    (cd "$1" &&
        find . \( -name "*.a" -o -name "*.la" -o -name "*.spec" \) -exec install -D "{}" "$2/{}" \;)
}
if [ "$MINGW" = "yes" -o "$DARWIN" = "yes" ] ; then
    # For some reasons, libraries in $ABI_CONFIGURE_TARGET (*) are not installed.
    # Hack here to copy them over.
    # (*) FYI: libgcc.a and libgcov.a not installed there in the first place
    INSTALL_TARGET_LIB_PATH="$BUILD_OUT/host-$ABI_CONFIGURE_BUILD/install/$ABI_CONFIGURE_TARGET/lib"
    TOOLCHAIN_TARGET_LIB_PATH="$TOOLCHAIN_INSTALL_PATH/$ABI_CONFIGURE_TARGET/lib"
    install_missing_libs "${INSTALL_TARGET_LIB_PATH}" "${TOOLCHAIN_TARGET_LIB_PATH}"
    if [ -d "${INSTALL_TARGET_LIB_PATH}64" ]; then
        install_missing_libs "${INSTALL_TARGET_LIB_PATH}64" "${TOOLCHAIN_TARGET_LIB_PATH}64"
    fi
fi
# don't forget to copy the GPL and LGPL license files
run cp -f $TOOLCHAIN_LICENSES/COPYING* $TOOLCHAIN_INSTALL_PATH
# remove some unneeded files
run rm -f $TOOLCHAIN_INSTALL_PATH/bin/*-gccbug
run rm -f $TOOLCHAIN_INSTALL_PATH/bin/*gdbtui$HOST_EXE
run rm -f $TOOLCHAIN_INSTALL_PATH/bin/*-run$HOST_EXE
run rm -rf $TOOLCHAIN_INSTALL_PATH/info
run rm -rf $TOOLCHAIN_INSTALL_PATH/man
run rm -rf $TOOLCHAIN_INSTALL_PATH/share/info
run rm -rf $TOOLCHAIN_INSTALL_PATH/share/man
run rm -rf $TOOLCHAIN_INSTALL_PATH/lib/gcc/$ABI_CONFIGURE_TARGET/*/install-tools
run rm -rf $TOOLCHAIN_INSTALL_PATH/lib/gcc/$ABI_CONFIGURE_TARGET/*/plugin
run rm -rf $TOOLCHAIN_INSTALL_PATH/libexec/gcc/$ABI_CONFIGURE_TARGET/*/install-tools
run rm -rf $TOOLCHAIN_INSTALL_PATH/lib/libiberty.a
run rm -rf $TOOLCHAIN_INSTALL_PATH/lib32/libiberty.a
run rm -rf $TOOLCHAIN_INSTALL_PATH/lib64/libiberty.a
run rm -rf $TOOLCHAIN_INSTALL_PATH/lib/x86_64/libiberty.a
run rm -rf $TOOLCHAIN_INSTALL_PATH/$ABI_CONFIGURE_TARGET/lib/libiberty.a
run rm -rf $TOOLCHAIN_INSTALL_PATH/$ABI_CONFIGURE_TARGET/lib/*/libiberty.a
run rm -rf $TOOLCHAIN_INSTALL_PATH/$ABI_CONFIGURE_TARGET/lib/*/*/libiberty.a
find $TOOLCHAIN_INSTALL_PATH -name "*.la" -exec rm -f {} \;
# Remove host install in cross compilation
if [ "$ABI_CONFIGURE_HOST" != "$ABI_CONFIGURE_TARGET" ]; then
    run rm -rf "$TOOLCHAIN_INSTALL_PATH/$ABI_CONFIGURE_HOST"
fi
# remove sysroot
run rm -rf "$TOOLCHAIN_INSTALL_PATH/sysroot"
# clean up link in /tmp if needed
if [ "$OBSCURE_PREFIX" == "yes" ]; then
  rm -f $PREFIX_LOCATION
fi
# Remove libstdc++ for now (will add it differently later)
# We had to build it to get libsupc++ which we keep.
run rm -rf $TOOLCHAIN_INSTALL_PATH/$ABI_CONFIGURE_TARGET/lib/libstdc++.*
run rm -rf $TOOLCHAIN_INSTALL_PATH/$ABI_CONFIGURE_TARGET/lib/*/libstdc++.*
run rm -rf $TOOLCHAIN_INSTALL_PATH/$ABI_CONFIGURE_TARGET/include/c++
# strip binaries to reduce final package size
if [ "$BUILD_DEBUGGABLE" != "yes" ] ; then
  test -z "$STRIP" && STRIP=strip
  run $STRIP $TOOLCHAIN_INSTALL_PATH/bin/*
  run $STRIP $TOOLCHAIN_INSTALL_PATH/$ABI_CONFIGURE_TARGET/bin/*
  run $STRIP $TOOLCHAIN_INSTALL_PATH/libexec/gcc/*/*/cc1$HOST_EXE
  run $STRIP $TOOLCHAIN_INSTALL_PATH/libexec/gcc/*/*/cc1plus$HOST_EXE
  run $STRIP $TOOLCHAIN_INSTALL_PATH/libexec/gcc/*/*/collect2$HOST_EXE
  run $STRIP $TOOLCHAIN_INSTALL_PATH/libexec/gcc/*/*/lto*$HOST_EXE
fi
# Some of the files should really be links to save space.
# This is mostly to reduce the size of the Windows zip archives,
# since:
#  - The toolchain install script actually use hard-links
#  - Tar automatically detects hard links and will only store a
#    single copy of each file anyway.
# $1: Source file (will be changed to a link)
# $2: Destination (relative to source).
do_relink () {
    log "Relink: $1 --> $2"
    local BASENAME DIRNAME
    DIRNAME=$(dirname "$1")
    BASENAME=$(basename "$1")
    ( cd "$DIRNAME" && rm -f "$BASENAME" && ln -s "$2" "$BASENAME" )
    fail_panic "Can't relink $1 to $2"
}
# <config>/bin/<name> should point to ../../<config>-<name>
LINK_FILES=$(cd $TOOLCHAIN_INSTALL_PATH/$ABI_CONFIGURE_TARGET/bin && ls * 2>/dev/null)
for LINK_FILE in $LINK_FILES; do
  do_relink $TOOLCHAIN_INSTALL_PATH/$ABI_CONFIGURE_TARGET/bin/$LINK_FILE ../../bin/$ABI_CONFIGURE_TARGET-$LINK_FILE
done
# $1: Source file prefix (e.g. 'c++')
# $2: Destination file prefix (e.g. 'g++')
# $3: Alternative file prefix if $2 doesn't exist (eg. ld.bfd)
do_relink_bin () {
    local DST_FILE=$2
    if [ ! -f "$TOOLCHAIN_INSTALL_PATH/bin/$ABI_CONFIGURE_TARGET-$DST_FILE$HOST_EXE" ]; then
        DST_FILE=$3
    fi
    if [ ! -f "$TOOLCHAIN_INSTALL_PATH/bin/$ABI_CONFIGURE_TARGET-$DST_FILE$HOST_EXE" ]; then
        echo "ERROR: Can't relink $1 to $DST_FILE because $DST_FILE doesn't exist"
        exit 1
    fi
    do_relink \
        $TOOLCHAIN_INSTALL_PATH/bin/$ABI_CONFIGURE_TARGET-$1$HOST_EXE \
        $ABI_CONFIGURE_TARGET-$DST_FILE$HOST_EXE
}
do_relink_bin c++ g++
do_relink_bin gcc-$GCC_VERSION gcc
# symlink ld to either ld.gold or ld.bfd
case "$TOOLCHAIN" in
    aarch64*)
    # Don't make ld.gold as default for now because it's new
    do_relink_bin ld ld.bfd ld.gold
    ;;
    *)
    do_relink_bin ld ld.gold ld.bfd
    ;;
esac
# copy SOURCES file if present
if [ -f "$SRC_DIR/SOURCES" ]; then
    cp "$SRC_DIR/SOURCES" "$TOOLCHAIN_INSTALL_PATH/SOURCES"
fi
echo "Removing sysroot for $TOOLCHAIN"
rm -rf $TOOLCHAIN_INSTALL_PATH/sysroot
if [ "$PACKAGE_DIR" ]; then
    make_repo_prop "$TMPDIR/$TOOLCHAIN_SUBDIR"
    touch $TMPDIR/$TOOLCHAIN_SUBDIR/MODULE_LICENSE_GPL
    cp $TMPDIR/$TOOLCHAIN_SUBDIR/COPYING $TMPDIR/$TOOLCHAIN_SUBDIR/NOTICE
    ARCHIVE="gcc-$ARCH-$HOST_TAG.tar.bz2"
    dump "Packaging $ARCHIVE from $TMPDIR/$TOOLCHAIN_SUBDIR"
    pack_archive "$PACKAGE_DIR/$ARCHIVE" "$TMPDIR" "$TOOLCHAIN_SUBDIR"
    fail_panic "Could not package $TOOLCHAIN GCC!"
fi
dump "Done."
if [ -z "$OPTION_BUILD_OUT" ] ; then
    rm -rf $BUILD_OUT
fi
