#!/bin/bash
set -e
set -v

OPENMPI_VERSION_MAJOR_MINOR="5.0"
OPENMPI_VERSION_REVISION="0"
OPENMPI_CFLAGS="-march=native -Ofast -fomit-frame-pointer -flto"
OPENMPI_CXXFLAGS="${OPENMPI_CFLAGS}"
OPENMPI_FCFLAGS="${OPENMPI_CFLAGS}"
OPENMPI_LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now"

if [[ -z "${DEPLOY_DIR}" ]]; then
  echo "DEPLOY_DIR not set!" >&2
  exit 1
fi

OPENMPI_VERSION="${OPENMPI_VERSION_MAJOR_MINOR}.${OPENMPI_VERSION_REVISION}"
OPENMPI_TMP_DIR="${PWD}/tmp/openmpi"
OPENMPI_SRC_TAR="${OPENMPI_TMP_DIR}/openmpi-${OPENMPI_VERSION}.tar.bz2"
OPENMPI_SRC_DIR="${OPENMPI_TMP_DIR}/openmpi-${OPENMPI_VERSION}"

OPENMPI_DEPLOY_DIR="${DEPLOY_DIR}/openmpi"

rm -rf "${OPENMPI_TMP_DIR}"
mkdir -p "${OPENMPI_TMP_DIR}"

rm -rf "${OPENMPI_DEPLOY_DIR}"
mkdir -p "${OPENMPI_DEPLOY_DIR}"

curl "https://download.open-mpi.org/release/open-mpi/v${OPENMPI_VERSION_MAJOR_MINOR}/openmpi-${OPENMPI_VERSION}.tar.bz2" -o "${OPENMPI_SRC_TAR}"

tar -xvf "${OPENMPI_SRC_TAR}" -C "${OPENMPI_TMP_DIR}"

pushd "${OPENMPI_SRC_DIR}"


# TODO: Add UCX
# TODO: Research more options (WE NEED MAXIMUM PERFORMANCE!!!11!!!1!1!)
# TODO: Compile with our compilers
./configure \
  --prefix="${OPENMPI_DEPLOY_DIR}" \
  --disable-shared \
  --enable-static \
  --enable-mpirun-prefix-by-default \
  --with-mpi-param-check=never \
  "CFLAGS=${OPENMPI_CFLAGS}" \
  "CXXFLAGS=${OPENMPI_CXXFLAGS}" \
  "FCFLAGS=${OPENMPI_FCFLAGS}" \
  "LDFLAGS=${OPENMPI_LDFLAGS}"

make -j
make install


popd
