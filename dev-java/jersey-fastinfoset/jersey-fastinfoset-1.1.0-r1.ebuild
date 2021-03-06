# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/${PN}/${PN}-1.0.ebuild,v 1.3 2009/03/31 17:33:10 betelgeuse Exp $

EAPI="2"
JAVA_PKG_IUSE="doc source test"
PROJ_PV="${PV}-ea"
PROJ_PN="jersey"
PROJ_P="${PROJ_PN}-${PROJ_PV}"

inherit java-pkg-2 java-ant-2

DESCRIPTION="JAX-RS Reference Implementation for building RESTful Web services - fastinfoset"
HOMEPAGE="https://jersey.dev.java.net/"

SRC_FILE="${PROJ_P}-src.tar.bz2"
SRC_URI="mirror://gentoo/${SRC_FILE}
		 mirror://gentoo/${SRC_FILE/src/src-generated}
		 http://dev.gentoo.org/~robbat2/java/${SRC_FILE}
		 http://dev.gentoo.org/~robbat2/java/${SRC_FILE/src/src-generated}"

LICENSE="|| ( CDDL GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

COMMON_DEPEND=">=dev-java/jsr311-api-1.1
			  java-virtuals/jaxb-api:2
			  java-virtuals/stax-api
			  dev-java/jersey-core
			  dev-java/fastinfoset
			  java-virtuals/jaf"
DEPEND=">=virtual/jdk-1.5
		test? ( dev-java/ant-junit:0 dev-java/junit:0 )
		${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.5
		${COMMON_DEPEND}"

S="${WORKDIR}/${PROJ_P}/${PROJ_PN}/${PN}"

# src_tarball is ONLY available in jersey-core

java_prepare() {
	sed \
		-e "/@@GENTOO_PN@@/s,@@GENTOO_PN@@,${PN},g" \
		-e "/@@GENTOO_PV@@/s,@@GENTOO_PV@@,${PV},g" \
		<"${FILESDIR}"/generic-maven-build.xml \
		>build.xml

	java-pkg_jar-from jsr311-api
	java-pkg_jar-from jaxb-api-2
	java-pkg_jar-from jaf
	java-pkg_jar-from stax-api
	java-pkg_jar-from jersey-core
	java-pkg_jar-from fastinfoset
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar
	use doc	&& java-pkg_dojavadoc target/site/apidocs
	use source && java-pkg_dosrc src/main/java
}

src_test() {
	EANT_GENTOO_CLASSPATH="junit ant-core" \
	ANT_TASKS="ant-junit" \
	eant test
}
