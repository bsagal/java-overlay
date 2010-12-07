# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Build written by Andrew John Hughes (gnu_andrew@member.fsf.org)

# *********************************************************
# * IF YOU CHANGE THIS EBUILD, CHANGE ICEDTEA-6.* AS WELL *
# *********************************************************

EAPI="2"

inherit autotools flag-o-matic java-pkg-2 java-vm-2 pax-utils versionator

LICENSE="Apache-1.1 Apache-2.0 GPL-1 GPL-2 GPL-2-with-linking-exception LGPL-2 MPL-1.0 MPL-1.1 public-domain W3C"
SLOT="7"
#KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

DESCRIPTION="A harness to build OpenJDK using Free Software build tools and dependencies"
ICEDTEA_VER="$(get_version_component_range 2-3)"
ICEDTEA_PKG=icedtea-${ICEDTEA_VER}
OPENJDK_TARBALL="195fcceefddc.tar.gz"
LANGTOOLS_TARBALL="681f1f51926f.tar.gz"
JAXP_TARBALL="826bafcb6c4a.tar.gz"
JAXWS_TARBALL="1661166c82dc.tar.gz"
CORBA_TARBALL="e805b4155d76.tar.gz"
JDK_TARBALL="2017795af50a.tar.gz"
HOTSPOT_TARBALL="a393ff93e7e5.tar.gz"
CACAO_TARBALL="66e762d869dd.tar.bz2"
JAXP_DROP="jdk7-jaxp-m6.zip"
JAXWS_DROP="jdk7-jaxws-2009_09_28.zip"
JAF_DROP="jdk7-jaf-2009_08_28.zip"
SRC_URI="http://icedtea.classpath.org/download/source/${ICEDTEA_PKG}.tar.gz
		 http://hg.openjdk.java.net/icedtea/jdk7/archive/${OPENJDK_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/corba/archive/${CORBA_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/jaxp/archive/${JAXP_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/jaxws/archive/${JAXWS_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/jdk/archive/${JDK_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/hotspot/archive/${HOTSPOT_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/langtools/archive/${LANGTOOLS_TARBALL}
		 http://icedtea.classpath.org/download/drops/${JAXP_DROP}
		 http://icedtea.classpath.org/download/drops/${JAXWS_DROP}
		 http://icedtea.classpath.org/download/drops/${JAF_DROP}
		 cacao? ( http://mips.complang.tuwien.ac.at/hg/cacao/archive/${CACAO_TARBALL} )"
HOMEPAGE="http://icedtea.classpath.org"
S=${WORKDIR}/${ICEDTEA_PKG}

# Missing options:
# shark - needs adding
IUSE="cacao debug doc examples javascript nsplugin pulseaudio systemtap xrender zero"

RDEPEND=">=net-print/cups-1.2.12
	 >=x11-libs/libX11-1.1.3
	 >=media-libs/freetype-2.3.5
	 >=media-libs/alsa-lib-1.0
	 >=x11-libs/gtk+-2.8
	 >=x11-libs/libXinerama-1.0.2
	 >=x11-libs/libXp-1.0.0
	 >=x11-libs/libXi-1.1.3
	 >=x11-libs/libXau-1.0.3
	 >=x11-libs/libXdmcp-1.0.2
	 >=x11-libs/libXtst-1.0.3
	 >=media-libs/jpeg-6b
	 >=media-libs/libpng-1.2
	 >=media-libs/giflib-4.1.6
	 >=sys-libs/zlib-1.2.3
	 x11-proto/inputproto
	 x11-proto/xineramaproto
	 nsplugin? ( >=net-libs/xulrunner-1.9.1 )
	 pulseaudio?  ( >=media-sound/pulseaudio-0.9.11 )
	 javascript? ( dev-java/rhino:1.6 )
	 zero? ( virtual/libffi )
	 xrender? ( >=x11-libs/libXrender-0.9.4 )
	 systemtap? ( >=dev-util/systemtap-1 )
	 !dev-java/icedtea:0"

# Additional dependencies for building:
#   zip: extract OpenJDK tarball, and needed by configure
#   xalan/xerces: automatic code generation
#   ant, ecj, jdk: required to build Java code
# Only ant-core-1.7.1-r2 and later contain a version of Ant that
# properly respects environment variables, if the build
# sets some environment variables.
# ca-certificates, perl and openssl are used for the cacerts keystore generation
# xext headers have two variants depending on version - bug #288855
# autoconf - as long as we use eautoreconf, version restrictions for bug #294918
DEPEND="${RDEPEND}
	|| (
		>=dev-java/gcj-jdk-4.3
		>=dev-java/cacao-0.99.2
		dev-java/icedtea:7
		dev-java/icedtea6-bin
		dev-java/icedtea:6
		dev-java/icedtea6
	)
	app-arch/zip
	>=dev-java/xalan-2.7.0:0
	>=dev-java/xerces-2.9.1:2
	>=dev-java/ant-core-1.7.1-r2
	dev-java/ant-nodeps
	app-misc/ca-certificates
	dev-lang/perl
	dev-libs/openssl
	sys-apps/lsb-release
	 || ( >=sys-devel/autoconf-2.65:2.5 <sys-devel/autoconf-2.64:2.5 )"

# a bit of hack so the VM switching is triggered without causing dependency troubles
JAVA_PKG_NV_DEPEND=">=virtual/jdk-1.5"
JAVA_PKG_WANT_SOURCE="1.5"
JAVA_PKG_WANT_TARGET="1.5"

pkg_setup() {
# Shark support disabled for now - still experimental and needs sys-devel/llvm
#	if use shark ; then
#	  if ( ! use x86 && ! use sparc && ! use ppc ) ; then
#		eerror "The Shark JIT has known issues on 64-bit platforms.  Please rebuild"
#		errror "without the shark USE flag turned on."
#		die "Rebuild without the shark USE flag on."
#	  fi
#	  if ( ! use zero ) ; then
#		eerror "The use of the Shark JIT is only applicable when used with the zero assembler port.";
#		die "Rebuild without the shark USE flag on or with the zero USE flag turned on."
#	  fi
#	fi

	# quite a hack since java-config does not provide a way for a package
	# to limit supported VM's for building and their preferred order
	if [[ -n "${JAVA_PKG_FORCE_VM}" ]]; then
		einfo "Honoring user-set JAVA_PKG_FORCE_VM"
	elif has_version dev-java/icedtea:7; then
		JAVA_PKG_FORCE_VM="icedtea7"
	elif has_version dev-java/icedtea:0; then
		JAVA_PKG_FORCE_VM="icedtea"
	elif has_version dev-java/gcj-jdk; then
		JAVA_PKG_FORCE_VM="gcj-jdk"
	elif has_version dev-java/icedtea6; then
		JAVA_PKG_FORCE_VM="icedtea6"
	elif has_version dev-java/icedtea:6; then
		JAVA_PKG_FORCE_VM="icedtea6"
	elif has_version dev-java/icedtea6-bin; then
		JAVA_PKG_FORCE_VM="icedtea6-bin"
	elif has_version dev-java/cacao; then
		JAVA_PKG_FORCE_VM="cacao"
	else
		JAVA_PKG_FORCE_VM=""
		# don't die just yet if merging a binpkg - bug #258423
		DIE_IF_NOT_BINPKG=true
	fi

	# if the previous failed, don't even run java eclasses pkg_setup
	# as it might also die when no VM is present
	if [[ -n "${JAVA_PKG_FORCE_VM}" ]]; then
		einfo "Forced vm ${JAVA_PKG_FORCE_VM}"
		java-vm-2_pkg_setup
		java-pkg-2_pkg_setup
	fi

	VMHANDLE="icedtea${SLOT}"
}

src_unpack() {
	if [[ -n ${DIE_IF_NOT_BINPKG} ]]; then
		die "Unable to find a supported VM for building"
	fi
	unpack ${ICEDTEA_PKG}.tar.gz
}

unset_vars() {
	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS
}

src_prepare() {
	epatch "${FILESDIR}/${PV}-alsa-sane-headers.patch"
	eautoreconf
}

src_configure() {
	local config procs rhino_jar
	local vm=$(java-pkg_get-current-vm)

	if [[ "${vm}" == "icedtea6" || "${vm}" == "icedtea" ]] || [[ "${vm}" == "icedtea7" ]] || [[ "${vm}" == "icedtea6-bin" ]] ; then
		# We can't currently bootstrap with a Sun-based JVM :(
		config="${config} --disable-bootstrap"
	elif [[ "${vm}" != "gcj-jdk" && "${vm}" != "cacao" ]] ; then
		eerror "IcedTea must be built with either a JDK based on GNU Classpath or an existing build of IcedTea."
		die "Install a GNU Classpath JDK (gcj-jdk, cacao)"
	fi

	# OpenJDK-specific parallelism support.
	procs=$(echo ${MAKEOPTS} | sed -r 's/.*-j\W*([0-9]+).*/\1/')
	if [[ -n ${procs} ]] ; then
		config="${config} --with-parallel-jobs=${procs}";
		einfo "Configuring using --with-parallel-jobs=${procs}"
	fi

	if use_zero ; then
		config="${config} --enable-zero"
	else
		config="${config} --disable-zero"
	fi

	if use javascript ; then
		rhino_jar=$(java-pkg_getjar rhino:1.6 js.jar);
	fi

	unset_vars

	econf ${config} \
		--with-openjdk-src-zip="${DISTDIR}/${OPENJDK_TARBALL}" \
		--with-corba-src-zip="${DISTDIR}/${CORBA_TARBALL}" \
		--with-jaxp-src-zip="${DISTDIR}/${JAXP_TARBALL}" \
		--with-jaxws-src-zip="${DISTDIR}/${JAXWS_TARBALL}" \
		--with-jdk-src-zip="${DISTDIR}/${JDK_TARBALL}" \
		--with-hotspot-src-zip="${DISTDIR}/${HOTSPOT_TARBALL}" \
		--with-langtools-src-zip="${DISTDIR}/${LANGTOOLS_TARBALL}" \
		--with-jaxp-drop-zip="${DISTDIR}/${JAXP_DROP}" \
		--with-jaxws-drop-zip="${DISTDIR}/${JAXWS_DROP}" \
		--with-jaf-drop-zip="${DISTDIR}/${JAF_DROP}" \
		--with-cacao-src-zip="${DISTDIR}/${CACAO_TARBALL}" \
		--with-jdk-home="$(java-config -O)" \
		--with-abs-install-dir=/usr/$(get_libdir)/icedtea${SLOT} \
		--disable-jdk-tests \
		$(use_enable !debug optimizations) \
		$(use_enable doc docs) \
		$(use_enable nsplugin plugin) \
		$(use_with javascript rhino ${rhino_jar}) \
		$(use_enable zero) \
		$(use_enable pulseaudio pulse-java) \
		$(use_enable xrender) \
		$(use_enable systemtap) \
		|| die "configure failed"
}

src_compile() {
	# Newer versions of Gentoo's ant add
	# an environment variable so it works properly...
	export ANT_RESPECT_JAVA_HOME=TRUE

	# ant -diagnostics in Ant 1.8.0 fails without xerces+xalan
	# otherwise we try to load the least that's needed to avoid possible classpath collisions
	export ANT_TASKS="xerces-2 xalan ant-nodeps"

	# Paludis does not respect unset from src_configure
	unset_vars
	emake -j 1  || die "make failed"
}

src_install() {
	local dest="${ROOT}usr/$(get_libdir)/icedtea${SLOT}"
	local ddest="${D}/${dest}"
	dodir "${dest}" || die

	local arch=${ARCH}

	dodoc README NEWS AUTHORS || die
	dosym "${ROOT}usr/share/doc/${PF}" "${ROOT}usr/share/doc/${PN}${SLOT}"

	cd "${S}/openjdk.build/j2sdk-image" || die

	if use doc ; then
		# java-pkg_dohtml needed for package-list #302654
		java-pkg_dohtml -r ../docs/* || die "Failed to install documentation"
	fi

	# doins can't handle symlinks.
	cp -vRP bin include jre lib man "${ddest}" || die "failed to copy"

	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler.
	pax-mark m $(list-paxables "${ddest}"{,/jre}/bin/*)

	dodoc ASSEMBLY_EXCEPTION THIRD_PARTY_README || die

	if use examples; then
		dodir "${dest}/share";
		cp -vRP demo sample "${ddest}/share/" || die
	fi

	cp src.zip "${ddest}" || die

	# Fix the permissions.
	find "${ddest}" \! -type l \( -perm /111 -exec chmod 755 {} \; -o -exec chmod 644 {} \; \) || die

	if use nsplugin; then
		use x86 && arch=i386;
		install_mozilla_plugin "${dest}/jre/lib/${arch}/IcedTeaNPPlugin.so";
	fi

	# We need to generate keystore - bug #273306
	einfo "Generating cacerts file from certificates in /usr/share/ca-certificates/"
	mkdir "${T}/certgen" && cd "${T}/certgen" || die
	cp "${FILESDIR}/generate-cacerts.pl" . && chmod +x generate-cacerts.pl || die
	for c in /usr/share/ca-certificates/*/*.crt; do
		openssl x509 -text -in "${c}" >> all.crt || die
	done
	./generate-cacerts.pl "${ddest}/bin/keytool" all.crt || die
	cp -vRP cacerts "${ddest}/jre/lib/security/" || die
	chmod 644 "${ddest}/jre/lib/security/cacerts" || die

	sed -e "s/@SLOT@/${SLOT}/g" \
		-e "s/@PV@/${ICEDTEA_VER}/g" \
		< "${FILESDIR}/icedtea.env" > "${T}/icedtea.env"
	set_java_env "${T}/icedtea.env"
}

use_zero() {
	use zero || ( ! use amd64 && ! use x86 && ! use sparc )
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst

	if use nsplugin; then
		elog "The icedtea${SLOT} browser plugin (NPPlugin) can be enabled using eselect java-nsplugin"
		elog "Note that the plugin works only in browsers based on xulrunner-1.9.1 or later"
		elog "such as Firefox 3.5+, Chromium and perhaps some others too."
	fi
}
