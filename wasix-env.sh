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
build-pip install build cffi setuptools maturin

# maturin seems to like to install with a .wasm extension for some reason
rm .cross-venv/build/bin/maturin
# instead we put in a patched version with WASIX compatibility
cp ../python-wasix-binaries/bin/maturin .cross-venv/build/bin/maturin
cp .cross-venv/build/bin/maturin .cross-venv/bin/maturin