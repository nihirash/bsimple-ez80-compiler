#!/bin/bash

# This script automatically prepares release for publishing it on github

make clean
make docs

rm -rf tmp
mkdir -p tmp/cross
mkdir -p tmp/cross/lib
mkdir -p tmp/cross/examples

mkdir -p tmp/native/bin
mkdir -p tmp/native/mos
mkdir -p tmp/native/bsimple/lib
mkdir -p tmp/native/bsimple/examples

make
OSNAME=`uname -sm`
RELEASE_NAME="${OSNAME// /_}"

cp compiler/bsc tmp/cross
cp lib/*.i tmp/cross/lib
cp examples/*.bs tmp/cross/examples
(cd tmp/cross && zip -r bs-$RELEASE_NAME.zip ./)

make agon
cp compiler/bin/bsc.bin tmp/native/bin
cp native-tools/bs.bin tmp/native/mos
cp -r tmp/cross/lib tmp/native/bsimple
cp -r tmp/cross/examples tmp/native/bsimple
(cd tmp/native && zip -r bs-agon.zip ./)