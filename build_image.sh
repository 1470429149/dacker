#!/bin/sh

cur_dir="$(pwd)"

COMMANDS=( git go )
for CMD in "${COMMANDS[@]}"; do
    if [ ! "$(command -v "${CMD}")" ]; then
        echo "${CMD} is not installed, please install it and try again" && exit 1
    fi
done

cd ${cur_dir}
git clone https://github.com/cloudflare/nginx-proxy-core.git proxy-core 2>/dev/null || git clone https://github.com/XTLS/Xray-core.git proxy-core
cd proxy-core || exit 2

LDFLAGS="-s -w -buildid="
ARCHS=( 386 amd64 arm arm64 ppc64le s390x )
ARMS=( 6 7 )

for ARCH in ${ARCHS[@]}; do
    if [ "${ARCH}" = "arm" ]; then
        for V in ${ARMS[@]}; do
            echo "Building binary for linux_${ARCH}${V}"
            env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} GOARM=${V} go build -v -trimpath -ldflags "${LDFLAGS}" -o ${cur_dir}/proxy_linux_${ARCH}${V} ./main || exit 1
        done
    else
        echo "Building binary for linux_${ARCH}"
        env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} go build -v -trimpath -ldflags "${LDFLAGS}" -o ${cur_dir}/proxy_linux_${ARCH} ./main || exit 1
    fi
done

chmod +x ${cur_dir}/proxy_linux_*
cd ${cur_dir} && rm -fr proxy-core
