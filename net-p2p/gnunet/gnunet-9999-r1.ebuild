# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8

if [[ ${PV} == "9999" ]] ; then
	inherit autotools git-r3
	EGIT_REPO_URI="https://git.gnunet.org/gnunet.git"
	WANT_AUTOCONF="2.69"
	WANT_AUTOMAKE="1.11.1"
	WANT_LIBTOOL="2.2"
	AUTOTOOLS_AUTORECONF=1
else
	#inherit libtool multilib-minimal
	SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64"
fi

AUTOTOOLS_IN_SOURCE_BUILD=1

DESCRIPTION="GNUnet is a framework for secure peer-to-peer networking."
HOMEPAGE="http://gnunet.org/"
RESTRICT="test"

LICENSE="GPL-3"

SLOT="0"
IUSE="experimental mysql nls postgresql +sqlite X curl idn bluez conversation FileSharing NATuPnP QRCode GNSvcard"

PATCHES=(
	"${FILESDIR}/${P}-fix-sudo-in-install.patch"
)

IDEPEND="
	acct-user/gnunet
"


RDEPEND="
	${IDEPEND}
	app-shells/bash
	sys-devel/gettext
	>=net-libs/gnutls-3.2.12
	curl? ( >=net-misc/curl-7.35.0 )
	!curl? ( net-misc/gnurl )
	>=dev-libs/libunistring-0.9.2
	idn? ( >=net-dns/libidn-1.0 )
	!idn? ( net-dns/libidn2 )
	>=net-libs/libmicrohttpd-0.9.63
	dev-libs/jansson
	dev-libs/nss
	dev-libs/openssl
	dev-libs/libltdl
	!mysql? ( >=dev-db/sqlite-3.0 )
	!sqlite? ( >=virtual/mysql-5.1 )
	mysql? ( >=virtual/mysql-5.1 )
	postgresql? ( dev-db/postgresql )
	sys-apps/which
	sys-libs/zlib
	>=dev-libs/libsodium-1.0.17
	bluez? ( media-sound/bluez-alsa )
	conversation? (
		media-libs/libopusenc
		media-libs/libpulse
		media-libs/libogg
	)
	FileSharing? (
		sys-libs/libextractor
	)
	NATuPnP? (
		net-libs/miniupnpc
	)
	QRCode? (
		media-gfx/zbar
	)
	GNSvcard? (
		app-text/texlive
	)
	>=dev-libs/libgcrypt-1.6
	nls? ( sys-devel/gettext )
	sqlite? ( >=dev-db/sqlite-3.0 )
	X? (
		x11-libs/libXt
		x11-libs/libXext
		x11-libs/libX11
		x11-libs/libXrandr
	)
"

BDEPEND="
	${RDEPEND}
"

DEPEND="${RDEPEND}"


src_prepare() {
	default
	if [[ ${PV} == "9999" ]] ; then
		eautoreconf
	fi
}

src_configure() {
	if [[ ${PV} == "9999" ]] ; then
		./bootstrap
	fi
	econf \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		$(use_enable nls) \
		$(use_enable experimental) \
		$(use_with mysql) \
		$(use_with postgresql) \
		$(use_with sqlite) \
		$(use_with X x) \
		$(use_with conversation opus) \
		$(use_with conversation pulse) \
		$(use_with conversation ogg) \
		$(use_with FileSharing extractor) \
		$(use_with QRCode zbar) \
		--with-microhttpd
	if [[ ${PV} == "9999" ]] ; then
		echo ${PV}
		emake -j1  gana
	fi
}

src_install() {
	emake -j1 DESTDIR="${D}" install
	newinitd "${FILESDIR}"/${PN}-9999.initd gnunet
	keepdir /var/{lib,log}/gnunet
	fowners gnunet:gnunet /var/lib/gnunet /var/log/gnunet
}

pkg_postinst() {
	einfo
	einfo "To configure"
	einfo "	 1) Add user(s) to the gnunet group"
	einfo "	 2) Edit the server config file '/etc/gnunet.conf'"
	einfo
}
