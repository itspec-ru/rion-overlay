# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

WANT_AUTOMAKE="1.11"
WANT_AUTOCONF="2.5"
DISTUTILS_DISABLE_PYTHON_DEPENDENCY="yes"

inherit distutils eutils autotools libtool

DESCRIPTION="BitTorrent library written in C++ for *nix."
HOMEPAGE="http://www.rasterbar.com/products/libtorrent"
SRC_URI="http://rion-overlay.googlecode.com/files/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="log debug +dht doc +crypt pool-allocators statistics disk-stats +geoip -examples test python-binding +zlib"

DEPEND=">=sys-devel/libtool-2.2.6
		dev-util/pkgconfig
		${COMMON_DEPEND}"

COMMON_DEPEND=">=dev-libs/boost-1.36
				encryption? ( dev-libs/openssl )
				geoip? ( dev-libs/geoip )
				zlib? ( sys-libs/zlib )
				python-binding? ( =dev-lang/python-2*
									>=dev-libs/boost-1.36[python] )"

RDEPEND="${COMMON_DEPEND}"

src_prepare(){
	elibtoolize
	eautoreconf
	if use python-binding;then
		cd "${S}"/bindings/python
		distutils_src_prepare
	 fi
}

src_configure() {
	local myconf

	use geoip && myconf="--with-libgeoip"

	econf \
		--enable-largefile \
		$(use_enable log logging) \
		$(use_enable debug) \
		$(use_enable dht) \
		$(use_enable crypt encryption) \
		$(use_enable pool-allocators) \
		$(use_enable statistics) \
		$(use_enable disk-stats) \
		$(use_enable geoip) \
		$(use_enable examples) \
		$(use_enable test tests) \
		$(use_enable python-binding ) \
		$(use_with zlib) \
		${myconf} || die "econf failed"
}

src_compile() {
	emake || die "emake failed"
	if use python-binding; then
		cd "${S}"/bindings/python
		distutils_src_compile

	fi
}
src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc ChangeLog AUTHORS NEWS README

	if use doc; then
		insinto /usr/share/doc/${P}/html
		doins -r "${S}"/docs/
	fi

	if use python-binding;then
		cd "${S}"/bindings/python
		distutils_src_install
	fi
}
