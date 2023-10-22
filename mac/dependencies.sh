FFMPEG_SOURCE=https://ffmpeg.martin-riedl.de/redirect/latest
NODE_VERSION=v18.18.2

curl $(curl https://raw.githubusercontent.com/Stremio/stremio-shell/master/server-url.txt) -o server.js

echo "downloading ffmpeg"
ARCH=$( [ "$(uname -m)" != "arm64" ] && echo "amd64" || echo "arm64" )
echo $FFMPEG_SOURCE/macos/$ARCH/release/ffmpeg.zip
curl -L $FFMPEG_SOURCE/macos/$ARCH/release/ffmpeg.zip -o ffmpeg.zip && unzip ffmpeg.zip -d .
curl -L $FFMPEG_SOURCE/macos/$ARCH/release/ffprobe.zip -o ffprobe.zip && unzip ffprobe.zip -d .
rm ffmpeg.zip ffprobe.zip

echo "downloading node"
ARCH=$( [ "$(uname -m)" != "arm64" ] && echo "x64" || echo "arm64" )
curl https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-darwin-$ARCH.tar.gz | tar -xf - -C .
mv node-$NODE_VERSION-darwin-$ARCH/bin/node .
rm -rf node-$NODE_VERSION-darwin-$ARCH

echo "download dylibs"
if [ ! -f dylibs.tar ]; then
    mkdir -p dylibs
    IINA_URL="https://iina.io/dylibs/universal"
    curl -sS "${IINA_URL}/filelist.txt" | while read -r file; do
        file=$(echo $file | tr -d '[:space:]')
        curl -sS "${IINA_URL}/${file}" -o "dylibs/$file"
    done
    cd dylibs
    tar -cf ../dylibs.tar *
    cd ..
    rm -rf dylibs
fi
