$ErrorActionPreference='Stop'
dotnet restore src/
$suffix=Get-Date -uformat '%s'
$suffix=$suffix.Substring(0, $suffix.IndexOf('.'))
$artifactDir='./artifacts/build/'

if (Test-Path $artifactDir) {
    rm -Recurse $artifactDir
}

foreach ($p in get-childitem src/*/project.json) {
    dotnet pack $p --version-suffix t$suffix -o $artifactDir
}