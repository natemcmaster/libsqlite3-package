$ErrorActionPreference='Stop'
$commit="$(git rev-parse HEAD)"
mkdir binaries/ -ErrorAction Ignore | out-null
iwr https://${env:AZURE_ACCOUNT}.blob.core.windows.net/travisci/libsqlite3-package/$commit/osx-x64.zip -outfile binaries/osx-x64.zip
iwr https://${env:AZURE_ACCOUNT}.blob.core.windows.net/travisci/libsqlite3-package/$commit/linux-x64.zip -outfile binaries/linux-x64.zip