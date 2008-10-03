# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1
JAVA_PKG_IUSE="doc source test"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="StatSVN is a metrics-analysis tool for charting software evolution through analysis of Subversion source repositories."
HOMEPAGE="http://www.statsvn.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}-source.zip"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="
	>=dev-util/statcvs-0.3:0
	>=dev-java/backport-util-concurrent-3.0:0"

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	test?
	(
		dev-java/junit:0
		dev-java/jfreechart:1.0
		dev-java/jcommon:1.0
	)
	${COMMON_DEPEND}"

RDEPEND=">=virtual/jre-1.4
	>=dev-util/subversion-1.3.0
	dev-java/xerces:2
	${COMMON_DEPEND}"

EANT_GENTOO_CLASSPATH="statcvs,backport-util-concurrent"
EANT_BUILD_TARGET="dist"
JAVA_ANT_CLASSPATH_TAGS="javac java javadoc"
JAVA_ANT_REWRITE_CLASSPATH="true"

src_unpack() {
	unpack ${A}

	# patches tests so they do not attempt to create cache in /root/.statsvn
	#cd ${S}/tests-src/net/sf/statsvn/input
	cd "${S}" || die
	einfo "Removing bundled jars."
	find . -name "*.jar" -print -delete
	rm -r "${S}"/bin/*
	epatch "${FILESDIR}"/${P}-build.xml.patch
	epatch "${FILESDIR}"/${P}-fixstatcvsusage.patch
}

src_test() {
	ewarn "Note that the tests require you to be online."
	#java-pkg_jar-from --into lib junit
	eant -Dgentoo.classpath=$(java-pkg_getjars statcvs,backport-util-concurrent):$(java-pkg_getjars --build-only junit,jfreechart-1.0,jcommon-1.0) test
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	# jfreechart pulls in gnu-jaxp which doesn't work for statsvn so we need
	# to force another SAXParserFactory and DocumentBuilderFactory
	java-pkg_register-dependency xerces-2
	java-pkg_dolauncher statsvn --main net.sf.statsvn.Main \
		--java_args '-Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl -Djavax.xml.parsers.DocumentBuilderFactory=org.apache.xerces.jaxp.DocumentBuilderFactoryImpl'

	use doc && java-pkg_dojavadoc doc
	use source && java-pkg_dosrc src/*
}

pkg_postinst() {
	elog "For instractions on how to use StatSVN see"
	elog "http://svn.statsvn.org/statsvnwiki/index.php/Main_Page"
	elog "You need to regenerate statistics"
	elog "if you update dev-java/jtreemap"
}
