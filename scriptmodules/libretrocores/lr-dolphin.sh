#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-dolphin"
rp_module_desc="Nintendo Gamecube & Wii Libretro Core"
rp_module_help="ROM Extensions: .ciso .dol .elf .gcm .gcz .iso .rvz .tgc .wad .wbfs\n\nCopy Gamecube ROMs to: $romdir/gc\n\nCopy Wii ROMs to: $romdir/wii"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/dolphin/master/license.txt"
rp_module_repo="git https://github.com/libretro/dolphin master"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_lr-dolphin() {
    local depends=(
        'bluez-libs'
        'cmake'
        'enet'
        'ffmpeg'
        'lzo'
        'mbedtls'
        'miniupnpc'
        'minizip'
        'pugixml'
        'qt5-base'
        'sfml'
    )
    getDepends "${depends[@]}"
}

function sources_lr-dolphin() {
    gitPullOrClone
}

function build_lr-dolphin() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DLIBRETRO=ON \
        -DLIBRETRO_STATIC=1 \
        -DENABLE_LTO=ON \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/dolphin_libretro.so"
}

function install_lr-dolphin() {
    md_ret_files=(
        'build/dolphin_libretro.so'
        'Data/Sys'
    )
}

function configure_lr-dolphin() {
    mkRomDir "gc"
    mkRomDir "wii"

    mkUserDir "$biosdir/gc"
    mkUserDir "$biosdir/wii"
    mkUserDir "$biosdir/gc/dolphin-emu"
    mkUserDir "$biosdir/wii/dolphin-emu"

    defaultRAConfig "gc" "system_directory" "$biosdir/gc"
    defaultRAConfig "wii" "system_directory" "$biosdir/wii"

    addEmulator 0 "$md_id" "gc" "$md_inst/dolphin_libretro.so"
    addEmulator 0 "$md_id" "wii" "$md_inst/dolphin_libretro.so"

    addSystem "gc"
    addSystem "wii"

    if [[ "$md_mode" == "install" ]]; then
        ln -svf "$md_inst/Sys" "$biosdir/gc/dolphin-emu"
        ln -svf "$md_inst/Sys" "$biosdir/wii/dolphin-emu"
        chown -R "$user:$user" "$md_inst/Sys"
    fi
}
