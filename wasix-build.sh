#! /bin/bash

set -exuo pipefail

rm -rf build dist *.egg-info

source .cross-venv/bin/activate

# Needed because the build scripts end up using wasixcc to build some C code
export WASIXCC_SYSROOT=$(realpath ../../wasix-libc/sysroot32-ehpic/)
export WASIXCC_WASM_EXCEPTIONS=yes
export WASIXCC_PIC=yes

PREV_DEFAULT=$(rustup default)
PREV_DEFAULT=${PREV_DEFAULT% (default)}

# Set this to the name of the wasix toolchain you have locally
# if you're not building your toolchain from source.
rustup default wasix-dev

export OPENSSL_DIR=$(realpath ../python-wasix-binaries/openssl)
export PYO3_CROSS_LIB_DIR=$(realpath ../cpython-install/cpython/lib/)
export RUSTFLAGS="-C link-arg=-Bsymbolic"
maturin build --target wasm32-wasmer-wasi-dl --release \
  --interpreter=$(realpath .cross-venv/bin/cross-python3)

rustup default "$PREV_DEFAULT"

cd target/wheels
mkdir temp
unzip cryptography-45.0.4-cp313-abi3-any.whl -d temp
wasm-opt \
  temp/cryptography/hazmat/bindings/_rust.abi3.so \
  -o temp/cryptography/hazmat/bindings/_rust.abi3.so \
  --emit-exnref \
  --enable-threads --enable-mutable-globals --enable-bulk-memory \
  --enable-bulk-memory-opt --enable-exception-handling \
  --no-validation
rm cryptography-45.0.4-cp313-abi3-any.whl
cd temp
zip -r ../cryptography-45.0.4-cp313-abi3-any.whl ./
cd ..
rm -rf temp