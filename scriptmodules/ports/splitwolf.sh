#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="splitwolf"
rp_module_desc="SplitWolf - 2-4 Player Split-Screen Wolfenstein 3D & Spear of Destiny Port"
rp_module_help="Game File Extension: .wl1, .wl6, .sdm, .sod, .sd2, .sd3\n\nCopy Your Wolfenstein 3D & Spear of Destiny Game Files to $romdir/ports/wolf3d/"
rp_module_licence="NONCOM https://bitbucket.org/linuxwolf6/splitwolf/raw/scrubbed/license-mame.txt"
rp_module_repo="git https://bitbucket.org/linuxwolf6/splitwolf.git scrubbed"
rp_module_section="exp"

function depends_splitwolf() {
    getDepends sdl2 sdl2_mixer
}

function sources_splitwolf() {
    gitPullOrClone
}

function _get_opts_splitwolf() {
    echo 'splitwolf-wolf3d VERSION_WOLF3D_SHAREWARE=y' # shareware v1.4
    echo 'splitwolf-wolf3d_apogee VERSION_WOLF3D_APOGEE=y' # 3d realms / apogee v1.4 full
    echo 'splitwolf-wolf3d_full VERSION_WOLF3D=y' # gt / id / activision v1.4 full
    echo 'splitwolf-sod VERSION_SPEAR=y' # spear of destiny
    echo 'splitwolf-sodmp VERSION_SPEAR_MP=y' # spear of destiny mission packs
    echo 'splitwolf-spear_demo VERSION_SPEAR_DEMO=y' # spear of destiny
}

function game_data_splitwolf() {
    if [[ ! -d "$md_inst/bin/lwmp" ]]; then
        # Get game assets
        downloadAndExtract "https://bitbucket.org/linuxwolf6/splitwolf/downloads/lwmp.zip" "$md_inst/bin/"
    fi
}

function add_games_splitwolf() {
    declare -A games_wolf4sdl=(
        ['vswap.sod']="SplitWolf - Spear of Destiny"
        ['vswap.sd1']="SplitWolf - Spear of Destiny"
        ['vswap.sd2']="SplitWolf - Spear of Destiny Mission Pack 2 - Return to Danger"
        ['vswap.sd3']="SplitWolf - Spear of Destiny Mission Pack 3 - Ultimate Challenge"
        ['vswap.sdm']="SplitWolf - Spear of Destiny (Shareware)"
        ['vswap.wl1']="SplitWolf - Wolfenstein 3D (Shareware)"
        ['vswap.wl6']="SplitWolf - Wolfenstein 3D"
    )

    add_ports_wolf4sdl "$md_inst/bin/splitwolf.sh %ROM%" "splitwolf"
}

function build_splitwolf() {
    mkdir -p "bin"
    local opt
    while read -r opt; do
        local bin="${opt%% *}"
        local defs="${opt#* }"
        make clean
        CFLAGS+=" -Wno-narrowing"
        make "$defs" DATADIR="$romdir/ports/wolf3d"
        mv "$bin" "bin/$bin"
        md_ret_require+=("bin/$bin")
    done < <(_get_opts_splitwolf)
}

function install_splitwolf() {
    cp "$md_build/gamecontrollerdb.txt" "$md_build/bin/"
    md_ret_files=('bin')
}

function configure_splitwolf() {
    local game

    mkRomDir "ports/wolf3d"

    if [[ "$md_mode" == "install" ]]; then
        game_data_splitwolf
        game_data_wolf4sdl
        cat > "$md_inst/bin/splitwolf.sh" << _EOF_
#!/bin/bash

function get_md5sum() {
    local file="\$1"

    [[ -n "\$file" ]] && md5sum "\$file" 2>/dev/null | cut -d" " -f1
}

function launch_splitwolf() {
    local wad_file="\$1"
    declare -A game_checksums=(
        ['6efa079414b817c97db779cecfb081c9']="splitwolf-wolf3d"
        ['a6d901dfb455dfac96db5e4705837cdb']="splitwolf-wolf3d_apogee"
        ['b8ff4997461bafa5ef2a94c11f9de001']="splitwolf-wolf3d_full"
        ['b1dac0a8786c7cdbb09331a4eba00652']="splitwolf-sod"
        ['25d92ac0ba012a1e9335c747eb4ab177']="splitwolf-sodmp --mission 2"
        ['94aeef7980ef640c448087f92be16d83']="splitwolf-sodmp --mission 3"
        ['35afda760bea840b547d686a930322dc']="splitwolf-spear_demo"
    )
        if [[ "\${game_checksums[\$(get_md5sum \$wad_file)]}" ]] 2>/dev/null; then
            $md_inst/bin/\${game_checksums[\$(get_md5sum \$wad_file)]} --splitdatadir $md_inst/bin/lwmp/ --split 2 --splitlayout 2x1
        else
            echo "Error: \$wad_file (md5: \$(get_md5sum \$wad_file)) is not a supported version"
        fi
}

launch_splitwolf "\$1"
_EOF_
        chmod +x "$md_inst/bin/splitwolf.sh"
    fi

    add_games_splitwolf

    moveConfigDir "$home/.splitwolf" "$md_conf_root/splitwolf"
}
