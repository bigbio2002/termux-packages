TERMUX_PKG_HOMEPAGE=https://blog.orhun.dev/introducing-gpg-tui/
TERMUX_PKG_DESCRIPTION="TUI for managing your GnuPG keys with ease"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="0.11.2"
TERMUX_PKG_SRCURL=https://github.com/orhun/gpg-tui/archive/refs/tags/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=2cbd0186b76b7bb5b4a21c76b2f4b344c03194731729aac645465f33d665ef91
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="gpgme"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
	termux_setup_rust

	cargo vendor
	find ./vendor \
		-mindepth 1 -maxdepth 1 -type d \
		! -wholename ./vendor/arboard \
		! -wholename ./vendor/x11rb-protocol \
		-exec rm -rf '{}' \;

	find vendor/{arboard,x11rb-protocol} -type f -print0 | \
		xargs -0 sed -i \
		-e 's|android|disabling_this_because_it_is_for_building_an_apk|g' \
		-e "s|/tmp|$TERMUX_PREFIX/tmp|g"

	echo "" >> Cargo.toml
	echo '[patch.crates-io]' >> Cargo.toml
	echo "arboard = { path = \"./vendor/arboard\" }" >> Cargo.toml
	echo "x11rb-protocol = { path = \"./vendor/x11rb-protocol\" }" >> Cargo.toml
}

termux_step_post_make_install() {
	install -Dm644 config/gpg-tui.toml "$TERMUX_PREFIX"/share/gpg-tui/gpg-tui.toml
	install -Dm644 man/gpg-tui.1 "$TERMUX_PREFIX"/share/man/man1/gpg-tui.1
	install -Dm644 man/gpg-tui.toml.5 "$TERMUX_PREFIX"/share/man/man5/gpg-tui.toml.5
}
