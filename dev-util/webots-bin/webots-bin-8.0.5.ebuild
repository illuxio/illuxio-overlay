# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /webots-bin/webots-bin-7.4.3.ebuild,v 1.2 2014/05/15 20:04:00 illuxio Exp $

EAPI="5"

inherit unpacker

DESCRIPTION="Webots - fast prototyping and simulation of mobile robots"
HOMEPAGE="http://www.cyberbotics.com/"

SLOT="0"
KEYWORDS="~x86 ~amd64"
RESTRICT="mirror strip"
QA_PREBUILT="*"
IUSE="+udev"

REQUIRED_USE=""

PNS=${PN/-bin/}
SRC_BASE="http://www.cyberbotics.com/dvd/linux/${PNS}"
SRC_URI="amd64? ( ${SRC_BASE}/${PNS}-${PV}-x86-64.tar.bz2 )
		x86? ( ${SRC_BASE}/${PNS}-${PV}-i386.tar.bz2 )"

RDEPEND="udev? (
		  virtual/udev
		)
		~media-libs/jpeg-8d
		media-libs/jasper
		media-libs/libraw
		dev-libs/libusb-compat"
DEPEND=""

S=${WORKDIR}/${PNS}
WEBOTS_HOME=/opt/${PN}

src_prepare() {
	# Prevent checks
	# scanelf: rpath_security_checks(): Security problem
	mv ${S}/webots-bin \
	   ${S}/lib/RenderSystem_GL.so \
	   ${S}/resources/projects/default/controllers/ros/ros \
	   ${T}
}

src_install() {
	into ${WEBOTS_HOME}
	
	# Normal files
	insinto ${WEBOTS_HOME}
	doins -r bin doc include resources
	
	exeinto ${WEBOTS_HOME}
	doexe webots ${FILESDIR}/matrix-rule-handler
	dosym ${WEBOTS_HOME}/webots /usr/bin/webots-bin

	# Libs
	if use amd64; then
	  dodir ${WEBOTS_HOME}/lib64 
	  dosym ${WEBOTS_HOME}/lib64 ${WEBOTS_HOME}/lib
	  insinto ${WEBOTS_HOME}/lib64
	else
	  insinto ${WEBOTS_HOME}/lib
	fi
	doins -r lib/matlab lib/python lib/qt lib/*.jar* 	
	dolib.so lib/*.so*

	if use udev; then
	  local WEBOTS_UDEV=/lib/udev/rules.d
	  sh ${FILESDIR}/matrix-rule-handler -r > ${T}/99-webots.rules
	  insinto ${WEBOTS_UDEV}
	  doins ${T}/99-webots.rules
	fi
}

pkg_postinst() {
  # Prevent checks
  # scanelf: rpath_security_checks(): Security problem
  cp ${T}/webots-bin ${WEBOTS_HOME}/
  cp ${T}/RenderSystem_GL.so ${WEBOTS_HOME}/lib/
  cp ${T}/ros ${WEBOTS_HOME}/resources/projects/default/controllers/ros/

  ewarn "This package could have some security issues through the relative DT_RPATH in some binary!"

  if use udev; then
	ewarn "Remember to reload udev: '/etc/init.d/udev reload'."
  fi
}

pkg_prerm() {
  rm ${WEBOTS_HOME}/webots-bin \
	 ${WEBOTS_HOME}/lib/RenderSystem_GL.so \
	 ${WEBOTS_HOME}/resources/projects/default/controllers/ros/ros
}
