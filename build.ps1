[cmdletbinding(PositionalBinding = $false)]
param(
   [string]$VersionSuffix=$env:DOTNET_BUILD_VERSION
)

$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

$installDir = ".dotnet/"
$dotnet = "$installDir/dotnet.exe"

function log($msg) {
    Write-Host -ForegroundColor Cyan "info : $msg"
}

function dotnet() {
    log "dotnet $($args -join ' ')"
    & $dotnet @args
    if($LASTEXITCODE -ne 0) {
        Write-Error "dotnet command failed"
    }
}

if (!(Test-Path $installDir)) { 
    mkdir $installDir | out-null
}

if (Test-Path artifacts) {
    log "Clean aritfacts"
    Remove-Item -Recurse -Force artifacts/
}

if(!(Test-Path $dotnet)) {
    $dotnetVersion = Get-Content ".dotnet-version"
    log "Install dotnet $dotnetVersion"
    
    iwr https://raw.githubusercontent.com/dotnet/cli/rel/1.0.0/scripts/obtain/dotnet-install.ps1 -outfile "$installDir/dotnet-install.ps1"
    & "$installDir/dotnet-install.ps1" -InstallDir $installDir -Version $dotnetVersion
}

dotnet restore --verbosity minimal
dotnet run -p tools/PackageBuilder/ --osx binaries/osx-x64.zip --linux binaries/linux-x64.zip

if(!($VersionSuffix)) {
    $date=get-date -u "%s"
    $date=$date.Substring(0, $date.IndexOf('.'))
    $VersionSuffix="t$date"
}

Get-ChildItem src/*/project.json | % {
    dotnet pack $_ -o artifacts/build/ --version-suffix $VersionSuffix
}
log "Cleanup useless symbols packages"
Remove-Item artifacts/build/*.symbols.nupkg

Write-Host -ForegroundColor Green "Done"