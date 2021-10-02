#!/usr/bin/bash

structure() {
  echo -n "Package Name [ENTER]: "; read -r PKG_NAME
  echo -n "Package Version (ex.: 1.0.0) [ENTER]: "; read -r PKG_VER
  echo -n "Package Arch (ex.: all/any/amd64/i386) [ENTER]: "; read -r PKG_ARCH
  echo -n "Package Depends (ex.: pkg1, pkg2, pkg3) [ENTER]: "; read -r PKG_DEPENDS
  echo -n "Package Section (ex.: pkg1, pkg2, pkg3) [ENTER]: "; read -r PKG_SECTION
  echo -n "Package Priority (ex.: pkg1, pkg2, pkg3) [ENTER]: "; read -r PKG_PRIORITY

  [[ -z "${PKG_NAME}" ]] && PKG_NAME="ext-example-pkg"
  [[ -z "${PKG_VER}" ]] && PKG_VER="1.0.0"
  [[ -z "${PKG_ARCH}" ]] && PKG_ARCH="all"
  [[ -z "${PKG_SECTION}" ]] && PKG_SECTION="admin"
  [[ -z "${PKG_PRIORITY}" ]] && PKG_PRIORITY="optional"

  PKG_REV="1"

  cat="$( command -v cat )"
  chmod="$( command -v chmod )"
  date="$( command -v date )"
  mkdir="$( command -v mkdir )"
  tar="$( command -v tar )"

  _deb_dirs && _deb_files && _obs_files && _ex_files && _pack
}

_changelog_ts() {
  ${date} -u '+%a, %d %b %Y %T %z'
}

_deb_dirs() {
  ${mkdir} -p "$( pwd )/${PKG_NAME}/_build/debian/source"
  ${mkdir} -p "$( pwd )/${PKG_NAME}/${PKG_NAME}-${PKG_VER}"
}

_deb_files() {
  ${cat} > "$( pwd )/${PKG_NAME}/_build/debian/source/format" <<EOF
3.0 (quilt)
EOF

  ${cat} > "$( pwd )/${PKG_NAME}/_build/debian/changelog" <<EOF
${PKG_NAME} (${PKG_VER}-${PKG_REV}) unstable; urgency=medium

  * Initial Release

 -- Package Store <kitsune.solar@gmail.com>  $( _changelog_ts )
EOF

  ${cat} > "$( pwd )/${PKG_NAME}/_build/debian/control" <<EOF
Source: ${PKG_NAME}
Section: ${PKG_SECTION}
Priority: ${PKG_PRIORITY}
Maintainer: Package Store <kitsune.solar@gmail.com>
Uploaders: Package Store <kitsune.solar@gmail.com>
Build-Depends: debhelper-compat (= 13)
Standards-Version: 4.5.1
Homepage: https://pkgstore.gitlab.io
Vcs-Browser: https://github.com/pkgstore/linux-deb-${PKG_NAME}
Vcs-Git: https://github.com/pkgstore/linux-deb-${PKG_NAME}.git
Rules-Requires-Root: no

Package: ${PKG_NAME}
Architecture: ${PKG_ARCH}
Depends: ${PKG_DEPENDS}, \${misc:Depends}
Description: [${PKG_NAME^^}-HEADER]
 [${PKG_NAME^^}-BODY]
EOF

  ${cat} > "$( pwd )/${PKG_NAME}/_build/debian/install" <<EOF
*.conf etc/${PKG_NAME}
*.sh usr/bin
EOF

  ${cat} > "$( pwd )/${PKG_NAME}/_build/debian/rules" <<EOF
#!/usr/bin/make -f

%:
	dh \$@
EOF

  ${chmod} +x "$( pwd )/${PKG_NAME}/_build/debian/rules"
}

_obs_files() {
  ${cat} > "$( pwd )/${PKG_NAME}/_meta" <<EOF
<package name="${PKG_NAME}" project="home:pkgstore:deb-ext">
  <title/>
  <description/>
</package>
EOF

  ${cat} > "$( pwd )/${PKG_NAME}/_service" <<EOF
<services>
  <service name="obs_scm">
    <param name="scm">git</param>
    <param name="url">https://github.com/deb-store/${PKG_NAME}.git</param>
    <param name="revision">main</param>
    <param name="version">_none_</param>
    <param name="filename">${PKG_NAME}</param>
    <param name="extract">*</param>
  </service>
  <service name="tar" mode="buildtime"/>
  <service name="recompress" mode="buildtime">
    <param name="file">*.tar</param>
    <param name="compression">xz</param>
  </service>
</services>
EOF
}

_ex_files() {
  ${cat} > "$( pwd )/${PKG_NAME}/${PKG_NAME}-${PKG_VER}/${PKG_NAME}.conf" <<EOF
param1: 1
param2: 2
EOF

  ${cat} > "$( pwd )/${PKG_NAME}/${PKG_NAME}-${PKG_VER}/${PKG_NAME}.sh" <<EOF
#!/usr/bin/bash

echo "Hello World!"
exit 0
EOF
}

_pack() {
  pushd "$( pwd )/${PKG_NAME}" \
    && ${tar} -cJf "${PKG_NAME}_${PKG_VER}.orig.tar.xz" "${PKG_NAME}-${PKG_VER}" \
    && popd || exit 1
}

"$@"

exit 0
