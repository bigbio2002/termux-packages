TERMUX_PKG_HOMEPAGE=https://geth.ethereum.org/
TERMUX_PKG_DESCRIPTION="Go implementation of the Ethereum protocol"
TERMUX_PKG_LICENSE="LGPL-3.0, GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.14.9"
TERMUX_PKG_SRCURL=https://github.com/ethereum/go-ethereum/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=078c9dba93e3823061754eb55dedf5df842da4d315d7bd824b5076b1cd595ad7
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_SUGGESTS="geth-utils"

termux_step_make() {
	termux_setup_golang

	export GOPATH=$TERMUX_PKG_BUILDDIR
	mkdir -p "${GOPATH}"/src/github.com/ethereum
	ln -sf "$TERMUX_PKG_SRCDIR" "$GOPATH"/src/github.com/ethereum/go-ethereum

	cd "$GOPATH"/src/github.com/ethereum/go-ethereum
	for applet in abidump abigen blsync bootnode clef devp2p era ethkey evm geth rlpdump; do
		go -C ./cmd/"$applet" build -v
	done
	unset applet
}

termux_step_make_install() {
	for applet in abidump abigen blsync bootnode clef devp2p era ethkey evm geth rlpdump; do
		install -Dm700 \
			"$TERMUX_PKG_SRCDIR/cmd/$applet/$applet" \
			"$TERMUX_PREFIX"/bin/
	done
	unset applet
}
