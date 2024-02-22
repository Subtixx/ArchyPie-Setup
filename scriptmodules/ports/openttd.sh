#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openttd"
rp_module_desc="OpenTTD: Game Engine For Transport Tycoon Deluxe"
rp_module_licence="GPL2 https://raw.githubusercontent.com/OpenTTD/OpenTTD/master/COPYING.md"
rp_module_repo="git https://github.com/OpenTTD/OpenTTD :_get_branch_openttd"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_openttd() {
    download "https://api.github.com/repos/openttd/openttd/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_openttd() {
    local depends=(
        'cmake'
        'curl'
        'doxygen'
        'fluidsynth'
        'fontconfig'
        'freetype2'
        'harfbuzz'
        'icu'
        'libpng'
        'lzo'
        'ninja'
        'sdl2'
        'xz'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_openttd() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|PATHSEP \".config\" PATHSEP;|PATHSEP \"ArchyPie/configs\" PATHSEP;|g" -i "${md_build}/src/fileio.cpp"
    sed -e "s|PATHSEP \".local\" PATHSEP \"share\" PATHSEP;|PATHSEP \"ArchyPie/configs\" PATHSEP;|g" -i "${md_build}/src/fileio.cpp"
}

function build_openttd() {
    # Cannot Build With Clang, Review After Release > 13.4
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_INSTALL_BINDIR=bin \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_openttd() {
    ninja -C build install/strip
}

function configure_openttd() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        # Create Default Configuration File
        local config
        config="$(mktemp)"

        iniConfig " = " "" "${config}"

        # Set Fullscreen By Default
        echo "[misc]" > "${config}"
        iniSet "fullscreen" "true"

        copyDefaultConfig "${config}" "${md_conf_root}/${md_id}/openttd.cfg"
        rm "${config}"
    fi

    addPort "${md_id}" "${md_id}" "OpenTTD" "${md_inst}/bin/${md_id}"
}
