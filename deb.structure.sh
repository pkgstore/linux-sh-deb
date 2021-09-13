#!/usr/bin/bash

PKG_NAME="${1}"
PKG_VER="${2}"
PKG_ARCH="${3}"
PKG_DEPENDS="${4}"

PKG_VER_S="1"

cat="$( command -v cat )"
chmod="$( command -v chmod )"
date="$( command -v date )"
mkdir="$( command -v mkdir )"
tar="$( command -v tar )"

_changelog_ts() {
  ${date} -u '+%a, %d %b %Y %T %z'
}

structure_dirs() {
  ${mkdir} -p "$( pwd )/${PKG_NAME}/_build/debian/source"
  ${mkdir} -p "$( pwd )/${PKG_NAME}/${PKG_NAME}-${PKG_VER}"
}

debian_files() {
  ${cat} > "$( pwd )/${PKG_NAME}/_build/debian/source/format" <<EOF
3.0 (quilt)

EOF

  ${cat} > "$( pwd )/${PKG_NAME}/_build/debian/changelog" <<EOF
${PKG_NAME} (${PKG_VER}-${PKG_VER_S}) unstable; urgency=medium

  * Initial Release

 -- Package Store <kitsune.solar@gmail.com>  $( _changelog_ts )

EOF

  ${cat} > "$( pwd )/${PKG_NAME}/_build/debian/control" <<EOF
Source: ${PKG_NAME}
Section: admin
Priority: optional
Maintainer: Package Store <kitsune.solar@gmail.com>
Uploaders: Package Store <kitsune.solar@gmail.com>
Build-Depends: debhelper (>= 13)
              ,debhelper-compat (= 13)
Standards-Version: 4.5.1
Homepage: https://pkgstore.gitlab.io
Vcs-Browser: https://github.com/pkgstore/linux-deb-${PKG_NAME}
Vcs-Git: https://github.com/pkgstore/linux-deb-${PKG_NAME}.git
Rules-Requires-Root: no

Package: ${PKG_NAME}
Architecture: ${PKG_ARCH}
Depends: ${PKG_DEPENDS}
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

obs_files() {
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
    <param name="compression">xz</param>
    <param name="file">*.tar</param>
  </service>
</services>

EOF
}

pack() {
  pushd "$( pwd )/${PKG_NAME}" \
    && ${tar} -cJf "${PKG_NAME}_${PKG_VER}.orig.tar.xz" "${PKG_NAME}-${PKG_VER}" \
    && popd || exit 1
}

structure_dirs && debian_files "$@" && obs_files && pack

exit 0
