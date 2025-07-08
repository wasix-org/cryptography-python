#! /bin/bash

set -exuo pipefail

rm -rf .native-venv .cross-venv build

python3.13 -m venv ./.native-venv
source ./.native-venv/bin/activate
pip install crossenv pycparser build cffi

# Note: For some reason, if -cxx is passed in to crossenv, it ignores the --cc option, opting
# instead to use wasixcc++ for C sources, which fails to work due to C++ warnings.
python -m crossenv ../cpython-install/cpython/bin/python3.wasm ./.cross-venv --cc wasixcc
source .cross-venv/bin/activate
pip install cython build maturin
build-pip install build cffi setuptools

# maturin seems to like to install with a .wasm extension for some reason
mv .cross-venv/cross/bin/maturin.wasm .cross-venv/cross/bin/maturin

echo WARNING! You probably need a patched maturin binary for the wasm32-wasmer-wasi-dl target to work!