# improved-stremio-shell

This is pretty much a fork of [stremio-shell](https://github.com/stremio/stremio-shell) with an improved build process which allows for easier updating of mpv as well as the ability to build for MacOS on arm.

## Download

Built binaries for Windows & MacOS can be found as artifacts on the [actions](https://github.com/edde746/improved-stremio-shell/actions/) page.

## Build

Start by making sure that you have the environment variable `Qt5_Dir` set to the path of your Qt installation.

### Windows

#### Requirements

- Qt >= 5.15.2
- MSVC >= 2017
- jom

Run the `bundle.ps1` script, if you want it to create the installer you will also need to have [Inno Setup](https://jrsoftware.org/isinfo.php) installed.

### MacOS

#### Requirements

- Qt >= 5.15.2
- Xcode >= 12.2
- mpv

Simply run the `bundle.sh` script.
