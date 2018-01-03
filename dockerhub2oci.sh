#!/bin/bash

registry="registry.hub.docker.com"
repo="gliderlabs"
image="alpine"
tag="latest"

cachedir=/tmp/docker2oci/
mkdir -p ${cachedir}

imgroot=${repo}/${image}/${tag}
rm -rf ${imgroot}
mkdir -p ${imgroot}

img_full="${repo}/${image}"

auth_uri="https://auth.docker.io/token"
auth_uri_full="${auth_uri}?service=registry.docker.io&scope=repository:${img_full}:pull"

reg_uri_manifest="https://${registry}/v2/${img_full}/manifests/${tag}"
reg_uri_blobs="https://${registry}/v2/${img_full}/blobs"

# Auth token
token=$(curl -s ${auth_uri_full} | jq -r .token)
# grep -Po '"'"token"'"\s*:\s*"\K([^"]*)')
#echo $token

# Layers
layers=$(curl -s -H "Authorization: Bearer ${token}" "${reg_uri_manifest}" | jq -r .fsLayers[].blobSum)
# grep -Po '"'"blobSum"'"\s*:\s*"\K([^"]*)')
#echo "$reply"

for HASHLAYER in ${layers}; do
	hashtype=${HASHLAYER%:*}
	layer=${HASHLAYER#*:}
	hashtype_aria=$(echo ${hashtype} | sed 's/^\([a-z]*\)\([0-9]*\)$/\1-\2/')
	echo ${reg_uri_blobs}/${HASHLAYER}
	echo "  checksum=${hashtype_aria}=${layer}"
	echo "  out=${HASHLAYER}.tar.gz"
done | aria2c -i - -d ${cachedir} --header="Authorization: Bearer ${token}" -V

for HASHLAYER in ${layers}; do
	tar --overwrite -C ${imgroot} -xf ${cachedir}/${HASHLAYER}.tar.gz
done
