PATH="$Qt5_Dir/bin:$PATH"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "Linux yet to come"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
    qmake -spec macx-clang
    make
    
    BUNDLE_NAME="stremio.app"
    BINARY_NAME="stremio"
    
    DEPENDENCIES_DIR=$(pwd)/dependencies
    if [[ ! -d dependencies ]]; then
        mkdir dependencies
        cd dependencies
        ../mac/dependencies.sh
        cd ..
    fi
    
    cd build
    cp $DEPENDENCIES_DIR/server.js "$BUNDLE_NAME/Contents/MacOS"
    cp $DEPENDENCIES_DIR/ffmpeg "$BUNDLE_NAME/Contents/MacOS"
    cp $DEPENDENCIES_DIR/ffprobe "$BUNDLE_NAME/Contents/MacOS"
    cp $DEPENDENCIES_DIR/node "$BUNDLE_NAME/Contents/MacOS"
    
    echo "macdeployqt"
    macdeployqt "$BUNDLE_NAME" -executable="$BUNDLE_NAME/Contents/MacOS/$BINARY_NAME" -qmldir=../src/ -always-overwrite
    
    tar -xf $DEPENDENCIES_DIR/dylibs.tar -C "$BUNDLE_NAME/Contents/Frameworks"
    echo "fix dylibs"
    files=$(tar -tf $DEPENDENCIES_DIR/dylibs.tar)
    for file in $files; do
        applicables=$(otool -L "$BUNDLE_NAME/Contents/Frameworks/$file" | grep -o "@rpath/.*dylib")
        for file2 in $applicables; do
            install_name_tool -change "$file2" "@loader_path/../Frameworks/$(basename $file2)" "$BUNDLE_NAME/Contents/Frameworks/$file"
        done
    done
    
    echo "codesign"
    codesign --force --deep --sign - stremio.app
    cd ..
else
    echo "Unknown platform"
fi