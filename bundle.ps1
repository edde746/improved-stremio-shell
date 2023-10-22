function Invoke-CmdScript {
  param(
    [String] $scriptName
  )
  $cmdLine = """$scriptName"" $args & set"
  & $Env:SystemRoot\system32\cmd.exe /c $cmdLine |
  select-string '^([^=]*)=(.*)$' | foreach-object {
    $varName = $_.Matches[0].Groups[1].Value
    $varValue = $_.Matches[0].Groups[2].Value
    set-item Env:$varName $varValue
  }
}

$env:PATH = "C:\Qt\Qt5.12.12\5.12.12\msvc2017_64\bin;" + $env:PATH
Invoke-CmdScript "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

New-Item -ItemType Directory -Path "build/output" -Force
Set-Location -Path "build"

if (-not (Test-Path -Path "mpv")) {
    $MPV_VERSION = "mpv-dev-x86_64-v3-20231015-git-78d4374"
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

  if ($exports.Count -gt 0) {
      $defContent = "EXPORTS`r`n" + ($exports -join "`r`n")
      $defContent | Set-Content "$dllName.def"

      lib /def:"$dllName.def" /out:"mpv.lib" /machine:x64

      Remove-Item "$dllName.def"
  } else {
      Write-Host "No exports found in $dllName.dll"
  }

  Set-Location -Path ".."
}

if (-not (Test-Path -Path "ffmpeg")) {
    Invoke-WebRequest -UserAgent "Wget" -Uri "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.7z" -OutFile "ffmpeg.7z"
    7z x "ffmpeg.7z" -o"ffmpeg"
    $folderName = (Get-ChildItem -Path "ffmpeg" -Directory).Name
    Move-Item -Path "ffmpeg/$folderName/*" -Destination "ffmpeg"
    Remove-Item -Path "ffmpeg/$folderName"
    Remove-Item -Path "ffmpeg.7z"
}

if (-not (Test-Path -Path "node")) {
    $NODE_VERSION = "v18.18.2"
    Invoke-WebRequest -UserAgent "Wget" -Uri "https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-win-x64.zip" -OutFile "node.zip"
    7z x "node.zip"
    Remove-Item -Path "node.zip"
    Move-Item -Path "node-$NODE_VERSION-win-x64" -Destination "node"
}

if (-not (Test-Path "server.js")) {
    $url = Invoke-RestMethod "https://raw.githubusercontent.com/Stremio/stremio-shell/master/server-url.txt"
    Invoke-WebRequest -Uri $url -OutFile "server.js"
}

Copy-Item -Path "ffmpeg/bin/ffmpeg.exe" -Destination "output/ffmpeg.exe"
Copy-Item -Path "ffmpeg/bin/ffprobe.exe" -Destination "output/ffprobe.exe"
Copy-Item -Path "node/node.exe" -Destination "output/node.exe"
Copy-Item -Path "server.js" -Destination "output/server.js"
Copy-Item -Path "mpv/libmpv-2.dll" -Destination "output/libmpv-2.dll"

Set-Location -Path ".."
& "qmake"
& "C:\Qt\Tools\QtCreator\bin\jom\jom.exe"

Copy-Item -Path "build/stremio.exe" -Destination "build/output/stremio.exe"
& windeployqt --no-compiler-runtime -qmldir=src "build/output/stremio.exe"

& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" setup.iss
