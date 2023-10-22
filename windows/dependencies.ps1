$MPV_VERSION = "mpv-dev-x86_64-v3-20231015-git-78d4374"
$NODE_VERSION = "v18.18.2"

. $PSScriptRoot\env.ps1

# mpv
Invoke-WebRequest -UserAgent "Wget" -Uri "https://sourceforge.net/projects/mpv-player-windows/files/libmpv/$MPV_VERSION.7z/download" -OutFile "mpv.7z"
7z x "mpv.7z" -o"mpv"
Remove-Item -Path "mpv.7z"

Set-Location -Path "mpv"

$dllName = "libmpv-2"
$exports = New-Object System.Collections.Generic.List[System.String]

dumpbin /exports "$dllName.dll" | ForEach-Object {
    if ($_ -match "\s+\d+\s+[A-F0-9]+\s+[A-F0-9]+\s+(.*)") {
        $exports.Add($matches[1])
    }
}

$defContent = "EXPORTS`r`n" + ($exports -join "`r`n")
$defContent | Set-Content "$dllName.def"
lib /def:"$dllName.def" /out:"mpv.lib" /machine:x64

Set-Location -Path ".."

# ffmpeg
Invoke-WebRequest -UserAgent "Wget" -Uri "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.7z" -OutFile "ffmpeg.7z"
7z x "ffmpeg.7z" -o"ffmpeg"
$folderName = (Get-ChildItem -Path "ffmpeg" -Directory).Name
Move-Item -Path "ffmpeg/$folderName/bin/*" -Destination "ffmpeg"
# wait for user to press enter
Read-Host -Prompt "Press Enter to continue"
Remove-Item -Path "ffmpeg/$folderName" -Recurse
Remove-Item -Path "ffmpeg.7z"

# node
Invoke-WebRequest -UserAgent "Wget" -Uri "https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-win-x64.zip" -OutFile "node.zip"
7z x "node.zip"
Remove-Item -Path "node.zip"
Move-Item -Path "node-$NODE_VERSION-win-x64" -Destination "node"

# server.js
$url = Invoke-RestMethod "https://raw.githubusercontent.com/Stremio/stremio-shell/master/server-url.txt"
Invoke-WebRequest -Uri $url -OutFile "server.js"
