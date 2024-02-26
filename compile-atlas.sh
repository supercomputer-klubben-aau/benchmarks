#!/bin/bash
set -e
set -v

ATLAS_VERSION="3.11.41"
ATLAS_SRC_TAR_NAME="atlas${ATLAS_VERSION}.tar.bz2"
ATLAS_SRC_URL="http://downloads.sourceforge.net/math-atlas/${ATLAS_SRC_TAR_NAME}"

if [[ -z "${DEPLOY_DIR}" ]]; then
  echo "DEPLOY_DIR not set!" >&2
  exit 1
fi

ATLAS_TMP_DIR="${PWD}/tmp/atlas"
ATLAS_SRC_TAR="${ATLAS_TMP_DIR}/${ATLAS_SRC_TAR_NAME}"
ATLAS_SRC_DIR="${ATLAS_TMP_DIR}/ATLAS"
ATLAS_VENDOR_DIR="${PWD}/atlas"
ATLAS_BUILD_DIR="${ATLAS_SRC_DIR}/build"
ATLAS_DEPLOY_DIR="${DEPLOY_DIR}/atlas"

rm -rf "${ATLAS_TMP_DIR}"
mkdir -p "${ATLAS_TMP_DIR}"

mkdir -p "${ATLAS_BUILD_DIR}"

rm -rf "${ATLAS_DEPLOY_DIR}"
mkdir -p "${ATLAS_DEPLOY_DIR}"

curl -L "${ATLAS_SRC_URL}" -o "${ATLAS_SRC_TAR}"

tar -xvf "${ATLAS_SRC_TAR}" -C "${ATLAS_TMP_DIR}"

# Fix uses of fgrep -> grep -F
find "${ATLAS_SRC_DIR}" -type f -exec sed -i 's/fgrep/grep -F/g' {} +

# Uncomment to fix free invalid ptr in xprobe_comp
# Seems to be a compiler bug :shrug:
#sed -i 's|free(.*|;|g' "${ATLAS_SRC_DIR}/CONFIG/src/atlconf_misc.c"

pushd "${ATLAS_SRC_DIR}"

patch -p1 < "${ATLAS_VENDOR_DIR}/gfortran-10.patch"

popd

pushd "${ATLAS_BUILD_DIR}"

"${ATLAS_SRC_DIR}/configure" \
  --prefix="${ATLAS_DEPLOY_DIR}" \
  -Fa acg '-march=native -Ofast -fomit-frame-pointer -flto'

make build

#make

popd
