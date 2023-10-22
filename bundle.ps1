. ./windows/env.ps1

$DEPENDENCY_FOLDER = (Get-Item -Path ".\").FullName + "\dependencies"

if (-not (Test-Path -Path $DEPENDENCY_FOLDER)) {
    New-Item -ItemType Directory -Path "dependencies" -Force
    Set-Location -Path "dependencies"
    . ../windows/dependencies.ps1
    Set-Location -Path ".."
}

New-Item -ItemType Directory -Path "build/output" -Force
Set-Location -Path "build"

Copy-Item -Path "$DEPENDENCY_FOLDER/ffmpeg/ffmpeg.exe" -Destination "output/ffmpeg.exe"
Copy-Item -Path "$DEPENDENCY_FOLDER/ffmpeg/ffprobe.exe" -Destination "output/ffprobe.exe"
Copy-Item -Path "$DEPENDENCY_FOLDER/node/node.exe" -Destination "output/node.exe"
Copy-Item -Path "$DEPENDENCY_FOLDER/server.js" -Destination "output/server.js"
Copy-Item -Path "$DEPENDENCY_FOLDER/mpv/libmpv-2.dll" -Destination "output/libmpv-2.dll"

Set-Location -Path ".."
& "qmake"
& "jom"

Copy-Item -Path "build/stremio.exe" -Destination "build/output/stremio.exe"
& windeployqt --no-compiler-runtime -qmldir=src "build/output/stremio.exe"

if (-not $env:GITHUB_ACTIONS) {
    & "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" setup.iss
}
