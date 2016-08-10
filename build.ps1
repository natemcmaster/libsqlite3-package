[cmdletbinding(PositionalBinding = $false)]
param(
    [int]$BuildNumber = $env:APPVEYOR_BUILD_NUMBER,

    [Parameter(Mandatory=$True)]
    [string]$OsxZip,

    [Parameter(Mandatory=$True)]
    [string]$LinuxZip
)

$ErrorActionPreference='Stop'
$ProgressPreference='SilentlyContinue'

#
# Functions
#

function log($msg) {
    Write-Host -ForegroundColor Cyan "info : $msg"
}

function Clean-Folder($path) {
    if (Test-Path $path) {
        Remove-Item -Recurse -Force $path | Out-Null
    }
    New-Item -ItemType Directory -Path $path -Force | Out-Null
}

#
# Settings
#

$artifacts= Join-Path $PSScriptRoot artifacts/build/
$buildDir = Join-Path $PSScriptRoot bin
$nuget = Join-Path $buildDir nuget.exe

$branch=${env:APPVEYOR_REPO_BRANCH}
if (!($branch)) {
    $branch="$(git rev-parse --abbrev-ref HEAD)"
}

$version = Get-Content -Raw $PSScriptRoot/.pack-version
if ($BuildNumber -and ($branch -ne 'master')) {
    $version += "-$("{0:D5}" -f $BuildNumber)"
}

$sqliteVersion = Get-Content -Raw $PSScriptRoot/.sqlite-version

if ( !($version) -or !($sqliteVersion)) {
    throw 'Could not identify versions from local files'
}

$downloads=@(
    @{
        Url = "https://www.sqlite.org/2016/sqlite-dll-win32-x86-$sqliteVersion.zip"
        Files = @{
            'sqlite3.dll' = 'runtimes/win7-x86/native/sqlite3.dll'
        }
    },
    @{
        Url = "https://www.sqlite.org/2016/sqlite-dll-win64-x64-$sqliteVersion.zip"
        Files = @{
            'sqlite3.dll' = 'runtimes/win7-x64/native/sqlite3.dll'
        }
    },
    @{
        Url = "https://www.sqlite.org/2016/sqlite-uwp-$sqliteVersion.vsix"
        Files = @{
            'Redist/Retail/x86/sqlite3.dll' = 'runtimes/win10-x86/nativeassets/uap10.0/sqlite3.dll'
            'Redist/Retail/x64/sqlite3.dll' = 'runtimes/win10-x64/nativeassets/uap10.0/sqlite3.dll'
            'Redist/Retail/ARM/sqlite3.dll' = 'runtimes/win10-arm/nativeassets/uap10.0/sqlite3.dll'
        }
    },
    @{
        Zip = $OsxZip
        Files = @{
            'libsqlite3.dylib' = 'runtimes/osx-x64/native/libsqlite3.dylib'
        }
    },
    @{
        Zip = $LinuxZip
        Files = @{
            'libsqlite3.so' = 'runtimes/linux-x64/native/libsqlite3.so'
        }
    }
)

#
# Do it
#

log "Branch: $branch"
log "Version: $version"
log "SQLite version: $sqliteVersion"

log 'Clean aritfacts'
Clean-Folder $artifacts
Clean-Folder $buildDir

Copy-Item -Recurse files/ $buildDir
Copy-Item $PSScriptRoot/.sqlite-version $buildDir/files/sqlite-version.txt

foreach ($values in $downloads) {
    if ($values.Url) {
        log "downloading $($values.Url)"
        $values.Zip = Join-Path $buildDir ([IO.Path]::GetFileName($values.Url))
        if ($values.Zip -notlike '*.zip') {
            $values.Zip += '.zip'
        }
        Invoke-WebRequest $values.Url -OutFile $values.Zip
    }
    $unzip = Join-Path $buildDir ([IO.Path]::GetFileNameWithoutExtension($values.Zip))
    log "unzip '$($values.Zip)' to '$unzip'"
    Expand-Archive -Path $values.Zip -DestinationPath $unzip -Force

    $values.Files.Keys | % {
        $src = Join-Path $unzip $_
        $dest = Join-Path $buildDir $values.Files[$_]
        log "copying '$src' to '$dest'"

        New-Item -Type Directory -ErrorAction Ignore -Path (Split-Path -Parent $dest) | Out-Null
        Copy-Item $src $dest
    }
}

if (!(Test-Path $nuget)) {
    Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile $nuget
}

$nuspec = Join-Path $PSScriptRoot 'SQLite.nuspec'
log "packing '$nuspec'"
& $nuget pack $nuspec -basepath $buildDir -o $artifacts -version $version -verbosity detailed
if ($LASTEXITCODE -ne 0) {
    Write-Error 'pack failed'
}

Write-Host -ForegroundColor Green "Done"