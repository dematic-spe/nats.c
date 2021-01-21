#!/bin/sh

#Setup
sudo apt-get update && sudo apt-get install -y g++ rsync zip openssh-server pkg-config make gdb ninja-build git cmake automake
sudo apt-get -y upgrade

mkdir repos

git clone https://github.com/microsoft/vcpkg.git repos/vcpkg
cd repos/vcpkg 
git checkout 2020.11
./bootstrap-vcpkg.sh
./vcpkg install zlib openssl protobuf-c --triplet x64-linux

cd ../

cmake .. -DCMAKE_TOOLCHAIN_FILE=../repos/vcpkg/scripts/buildsystems/vcpkg.cmake -DNATS_BUILD_STREAMING=ON

cmake --build . --config Debug
cmake --build . --config Release
