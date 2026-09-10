TERMUX_PKG_HOMEPAGE=https://unicode.org/ucd/
TERMUX_PKG_DESCRIPTION="The Unicode Character Database (UCD)"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="copyright.html"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="18.0.0"
TERMUX_PKG_SRCURL=(
	https://unicode.org/Public/${TERMUX_PKG_VERSION}/ucd/UCD.zip
	https://unicode.org/Public/${TERMUX_PKG_VERSION}/ucd/Unihan.zip
)
TERMUX_PKG_SHA256=(
	17591bf796d71323cdf69715aca3cc9778f6008bf61fb733bd2d1241c03702fd
	14185c2d7c738ae317807b0b895c92757a0a1797bb84e406b1982daec081627d
)
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_METHOD=repology

termux_step_get_source() {
	local i
	for i in $(seq 0 $(( ${#TERMUX_PKG_SRCURL[@]}-1 ))); do
		local f="${TERMUX_PKG_NAME}-$(basename "${TERMUX_PKG_SRCURL[$i]}")"
		termux_download \
			"${TERMUX_PKG_SRCURL[$i]}" \
			"$TERMUX_PKG_CACHEDIR/${f}" \
			"${TERMUX_PKG_SHA256[$i]}"
	done
	mkdir -p "$TERMUX_PKG_SRCDIR"
	unzip -d "$TERMUX_PKG_SRCDIR" \
		"$TERMUX_PKG_CACHEDIR/${TERMUX_PKG_NAME}-UCD.zip"
	cp "$TERMUX_PKG_CACHEDIR/${TERMUX_PKG_NAME}-Unihan.zip" \
		"$TERMUX_PKG_SRCDIR/Unihan.zip"
}

termux_step_post_get_source() {
	cp $TERMUX_PKG_BUILDER_DIR/copyright.html ./
}

termux_step_make_install() {
	cp -rT "$TERMUX_PKG_SRCDIR" "$TERMUX_PREFIX/share/${TERMUX_PKG_NAME}"
}
