[CmdletBinding()]
param(
    [int]$st = ${env:SUBLIME_TEXT_VERSION}
)


try{
    if (-not $st) {
        throw "Missing Sublime Text version"
    }

    write-verbose "installing sublime text $st"

    $url = $null
    for ($i=1; $i -le 20; $i++) {
        try {
            foreach ( $link in (Invoke-WebRequest "http://www.sublimetext.com/$st" -UseBasicParsing).Links ) {
                if ( $link.href.endsWith("x64.zip") ) {
                   $url = $link.href
                   break
                }
            }
            break
        } catch {
            start-sleep -s 3
        }
    }
    if (-not $url) {
        throw "could not download Sublime Text binary"
    }

    write-verbose "downloading $url"

    $url = [System.Uri]::EscapeUriString($url)
    $filename = Split-Path $url -leaf


    for ($i=1; $i -le 20; $i++) {
        try {
            (New-Object System.Net.WebClient).DownloadFile($url, "${env:Temp}\$filename")
            break
        } catch {
            start-sleep -s 3
        }
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("${env:Temp}\$filename", "C:\st")

    New-Item -itemtype directory "C:\st\Data\Packages\User" -force >$null
}catch {
    throw $_
}
