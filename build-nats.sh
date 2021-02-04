#!/bin/sh

#Setup
#sudo apt-get update && sudo apt-get install -y g++ rsync zip openssh-server pkg-config make gdb ninja-build git cmake automake
#sudo apt-get -y upgrade

if [ ! -x "$VCPKG_HOME" ] ; then
  echo "The VCPKG_HOME environment variable is not defined correctly" >&2
  echo "This environment variable is needed to run this program" >&2
  echo "Hint: export VCPKG_HOME=<somedir> example export VCPKG_HOME=~/vcpkg"
  exit 1
fi

if [ -d "$VCPKG_HOME" ]; then
  echo "$VCPKG_HOME exists"
else
  git clone https://github.com/microsoft/vcpkg.git "$VCPKG_HOME"
  git checkout 2020.11
fi

echo The vcpkg git project is checked out to $VCPKG_HOME
VCPKG_CMD="$VCPKG_HOME/vcpkg"

if [ -e "$VCPKG_CMD" ] ; then
    echo "$VCPKG_CMD exists"
else
    echo "$VCPKG_CMD missing so it will be built"
	sudo $VCPKG_HOME/bootstrap-vcpkg.sh
fi

if [ ! -d "$VCPKG_HOME/installed/x64-linux/include/openssl"      ]; then $VCPKG_CMD install openssl --triplet x64-linux    ; fi
if [ ! -d "$VCPKG_HOME/installed/x64-linux/include/zlib.h"       ]; then $VCPKG_CMD install zlib --triplet x64-linux       ; fi
if [ ! -d "$VCPKG_HOME/installed/x64-linux/include/protobuf-c"   ]; then $VCPKG_CMD install protobuf-c --triplet x64-linux ; fi

mkdir debug
cd debug
cmake .. -DNATS_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=$VCPKG_HOME/scripts/buildsystems/vcpkg.cmake \
	 -DCMAKE_INSTALL_PREFIX:PATH=$VCPKG_HOME/installed/x64-linux/debug \
	 -DCMAKE_INSTALL_LIBDIR:PATH=$VCPKG_HOME/installed/x64-linux/debug/lib \
	 -DNATS_BUILD_STREAMING=ON

cmake --build .  
cmake --install .  
cd ../

mkdir release
cd release
cmake .. -DNATS_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=$VCPKG_HOME/scripts/buildsystems/vcpkg.cmake \
	 -DCMAKE_INSTALL_PREFIX:PATH=$VCPKG_HOME/installed/x64-linux/ \
	 -DCMAKE_INSTALL_LIBDIR:PATH=$VCPKG_HOME/installed/x64-linux/lib \
	 -DNATS_BUILD_STREAMING=ON
cmake --build .  
cmake --install .  
cd ../

