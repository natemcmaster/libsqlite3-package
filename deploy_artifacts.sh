#!/usr/bin/env bash

if [[ "$AZURE_ACCOUNT" == "" || "$AZURE_KEY" == "" || "$TRAVIS_PULL_REQUEST" != "false" ]]; then
    echo "Skipping deploy"
    exit 0
fi

get_resp_code() {
    curl -I --write-out %{http_code} --silent --output /dev/null $1
}

set -e

commit="$(git rev-parse HEAD)"
branch="$(git rev-parse --abbrev-ref HEAD)"

if [[ "$(uname)" == "Darwin" ]]; then 
    artifact="$(pwd)/artifacts/osx-x64.zip"
    other_blobname="travisci/libsqlite3-package/$commit/linux-x64.zip"
    opensslversion="$(brew list --versions openssl | awk -F' ' '{print $NF}')"
    openssl="/usr/local/Cellar/openssl/$opensslversion/bin/openssl"
    decode_opt="-D" # differences in base64 x-plat
else
    artifact="$(pwd)/artifacts/linux-x64.zip"
    other_blobname="travisci/libsqlite3-package/$commit/osx-x64.zip"
    openssl="$(which openssl)"
    decode_opt="-d"
fi

filename="$(basename $artifact)"
blobname="travisci/libsqlite3-package/$commit/$filename"

dateheader="x-ms-date:$(date -u +%a,\ %d\ %b\ %Y\ %H:%M:%S\ GMT)"
versionheader="x-ms-version:2015-12-11"
contenttype="x-ms-blob-type:BlockBlob"
stringtosign="PUT\n\n\n\n$contenttype\n$dateheader\n$versionheader\n/$AZURE_ACCOUNT/$blobname";
decoded_hex_key="$(echo -n $AZURE_KEY | base64 $decode_opt | xxd -p -c256)"
signature="$(echo -en "$stringtosign" | $openssl dgst -sha256 -mac HMAC -macopt "hexkey:$decoded_hex_key" -binary | base64)"

if [[ "$signature" == "" ]]; then
    echo "Failed to compute signature"
    exit 1
fi

curl \
    -T "$artifact" \
    -H "Authorization: SharedKeyLite $AZURE_ACCOUNT:$signature" \
    -H "$dateheader" \
    -H "$versionheader" \
    -H "$contenttype" \
    "https://$AZURE_ACCOUNT.blob.core.windows.net/$blobname"

if [[ "$APPVEYOR_KEY" != "" && "$(get_resp_code https://$AZURE_ACCOUNT.blob.core.windows.net/$blobname)" == "200" && "$(get_resp_code https://$AZURE_ACCOUNT.blob.core.windows.net/$other_blobname)" == "200"  ]]; then
    echo "Trigger AppVeyor"
    curl \
        -H "Authorization: Bearer $APPVEYOR_KEY" \
        -H "Content-type: application/json" \
        -X "POST" \
        -d "{\"accountName\":\"$APPVEYOR_ACCOUNT\",\"projectSlug\":\"$APPVEYOR_PROJECT\", \"branch\": \"$branch\", \"commitId\": \"$commit\"}" \
        https://ci.appveyor.com/api/builds

else
    echo "Skipping AppVeyor build trigger"
fi
