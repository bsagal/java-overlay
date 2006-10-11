# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN="IzPack"
DESCRIPTION="IzPack is an installers generator for the Java platform."
HOMEPAGE="http://www.izforge.com/izpack/"
SRC_URI="http://download.berlios.de/izpack/${MY_PN}.src.${PV}.tar.gz"

#Apache License Version 2.0
LICENSE="Apache-2.0"
SLOT="3.9"
KEYWORDS="~amd64"
IUSE="doc source examples"


#Looks and Feels that izpack can use
#dev-java/liquidlnf
#dev-java/kunststoff
#dev-java/jgoodies-looka
CDEPEND="=dev-java/jakarta-regexp-1.3*"
DEPEND=">=virtual/jdk-1.4
		app-arch/zip
		>=dev-java/ant-core-1.5
		${CDEPEND}"
RDEPEND=">=virtual/jre-1.4
		${CDEPEND}"
S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd ${S}/lib
	rm *.jar
	java-pkg_jarfrom jakarta-regexp-1.3 jakarta-regexp.jar jakarta-regexp-1.3.jar
	java-pkg_jarfrom ant-core ant.jar
}

src_compile() {
	cd src 
	eant all $(use_doc build.javadoc)
}

src_install() {
	java-pkg_dojar lib/*.jar
	use_doc && java-pkg_dojavadoc doc/izpack/javadoc

	use source && java-pkg_dosrc src/*
	if use examples; then
		dodir /usr/share/doc/$PF}/examples
		cp -r samples/* ${D}/usr/share/doc/${PF}/examples
	fi
}

pkg_postinst () {
	einfo " The following are useful swing packages that you can use with izPack"
	einfo "   dev-java/metouia"
	einfo "   dev-java/jgoodies-looks"
	einfo "   dev-java/liquidlnf"
	einfo "   dev-java/kunststoff"
}

