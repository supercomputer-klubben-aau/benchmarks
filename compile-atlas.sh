#!/bin/bash
set -e
set -v

ATLAS_VERSION="3.11.41"
ATLAS_SRC_TAR_NAME="atlas${ATLAS_VERSION}.tar.bz2"
ATLAS_SRC_URL="https://master.dl.sourceforge.net/project/math-atlas/Developer%20%28unstable%29/${ATLAS_VERSION}/${ATLAS_SRC_TAR_NAME}"

if [[ -z "${DEPLOY_DIR}" ]]; then
  echo "DEPLOY_DIR not set!" >&2
  exit 1
fi

ATLAS_TMP_DIR="${PWD}/tmp/atlas"
ATLAS_SRC_TAR="${ATLAS_TMP_DIR}/${ATLAS_SRC_TAR_NAME}"
ATLAS_SRC_DIR="${ATLAS_TMP_DIR}/ATLAS"
ATLAS_BUILD_DIR="${ATLAS_TMP_DIR}/build"
ATLAS_DEPLOY_DIR="${DEPLOY_DIR}/atlas"

rm -rf "${ATLAS_TMP_DIR}"
mkdir -p "${ATLAS_TMP_DIR}"

mkdir -p "${ATLAS_BUILD_DIR}"

rm -rf "${ATLAS_DEPLOY_DIR}"
mkdir -p "${ATLAS_DEPLOY_DIR}"

curl -L "${ATLAS_SRC_URL}" -o "${ATLAS_SRC_TAR}"

tar -xvf "${ATLAS_SRC_TAR}" -C "${ATLAS_TMP_DIR}"

pushd "${ATLAS_BUILD_DIR}"

"${ATLAS_SRC_DIR}/configure" \
  --prefix="${ATLAS_DEPLOY_DIR}" #\
  #-Fa acg '-march=native -Ofast -fomit-frame-pointer -flto'

popd
