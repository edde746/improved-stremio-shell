FFMPEG_SOURCE=https://ffmpeg.martin-riedl.de/redirect/latest
NODE_VERSION=v18.18.2
cd build

if [ ! -f server.js ]; then
    curl $(curl https://raw.githubusercontent.com/Stremio/stremio-shell/master/server-url.txt) -o server.js
fi

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "Linux yet to come"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    BUNDLE_NAME="stremio.app"
    BINARY_NAME="stremio"
    rm -rf "$BUNDLE_NAME"

    mkdir -p "$BUNDLE_NAME/Contents/MacOS"
    mkdir -p "$BUNDLE_NAME/Contents/Frameworks"
    cp $BINARY_NAME "$BUNDLE_NAME/Contents/MacOS"
    cp Info.plist "$BUNDLE_NAME/Contents"

    if [ ! -f ffmpeg ]; then
        echo "downloading ffmpeg"
        ARCH=$( [ "$(uname -m)" != "arm64" ] && echo "amd64" || echo "arm64" )
        echo $FFMPEG_SOURCE/macos/$ARCH/release/ffmpeg.zip
        curl -L $FFMPEG_SOURCE/macos/$ARCH/release/ffmpeg.zip -o ffmpeg.zip && unzip ffmpeg.zip -d .
        curl -L $FFMPEG_SOURCE/macos/$ARCH/release/ffprobe.zip -o ffprobe.zip && unzip ffprobe.zip -d .
        rm ffmpeg.zip ffprobe.zip
    fi

    if [ ! -f node ]; then
        echo "downloading node"
        ARCH=$( [ "$(uname -m)" != "arm64" ] && echo "x64" || echo "arm64" )
        curl https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-darwin-$ARCH.tar.gz | tar -xf - -C .
        mv node-$NODE_VERSION-darwin-$ARCH/bin/node .
        rm -rf node-$NODE_VERSION-darwin-$ARCH
    fi

    cp server.js "$BUNDLE_NAME/Contents/MacOS"
    cp ffmpeg "$BUNDLE_NAME/Contents/MacOS"
    cp ffprobe "$BUNDLE_NAME/Contents/MacOS"
    cp node "$BUNDLE_NAME/Contents/MacOS"

    echo "macdeployqt"
    macdeployqt "$BUNDLE_NAME" -executable="$BUNDLE_NAME/Contents/MacOS/$BINARY_NAME" -executable=ffmpeg -executable=ffprobe -executable=node -qmldir=../src/ -always-overwrite

    echo "download dylibs"
    if [ ! -f dylibs.tar ]; then
        mkdir -p dylibs
        IINA_URL="https://iina.io/dylibs/universal"
        curl -sS "${IINA_URL}/filelist.txt" | while read -r file; do
            file=$(echo $file | tr -d '[:space:]')
            curl -sS "${IINA_URL}/${file}" -o "dylibs/$file"
        done
        tar -cf dylibs.tar dylibs/*
        rm -rf dylibs
    fi

    echo "extract dylibs"
    tar -xf dylibs.tar -C "$BUNDLE_NAME/Contents/Frameworks"
    echo "fix dylibs"
    files=$(tar -tf dylibs.tar)
    for file in $files; do
        applicables=$(otool -L "$BUNDLE_NAME/Contents/Frameworks/$file" | grep -o "@rpath/.*dylib")
        for file2 in $applicables; do
            install_name_tool -change "$file2" "@loader_path/../Frameworks/$(basename $file2)" "$BUNDLE_NAME/Contents/Frameworks/$file"
        done
    done

    echo "codesign"
    codesign --force --deep --sign - stremio.app
else
    echo "Unknown platform"
fi