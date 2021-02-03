#!/bin/sh

#Setup
#sudo apt-get update && sudo apt-get install -y g++ rsync zip openssh-server pkg-config make gdb ninja-build git cmake automake
#sudo apt-get -y upgrade

if [ ! -x "$VCPKG_HOME" ] ; then
  echo "The VCPKG_HOME environment variable is not defined correctly" >&2
  echo "This environment variable is needed to run this program" >&2
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

mkdir build
cd build

cmake .. -DCMAKE_TOOLCHAIN_FILE=$VCPKG_HOME/scripts/buildsystems/vcpkg.cmake -DNATS_BUILD_STREAMING=ON

cmake --build . --config Debug
cmake --build . --config Release

cd ..
echo Integrate nats build with vcpkg

mkdir "$VCPKG_HOME/installed/x64-linux/include/nats"
cp src/nats.h "$VCPKG_HOME/installed/x64-linux/include/nats"
cp src/version.h "$VCPKG_HOME/installed/x64-linux/include/nats"
cp src/status.h "$VCPKG_HOME/installed/x64-linux/include/nats"

cp  build/src/Release/*.lib "$VCPKG_HOME/installed/x64-linux/lib"
cp  build/src/Release/*.dll "$VCPKG_HOME/installed/x64-linux/bin"

cp  build/src/Debug/*.lib "$VCPKG_HOME/installed/x64-linux/debug/lib"
cp  build/src/Debug/*.dll "$VCPKG_HOME/installed/x64-linux/debug/bin"
cp  build/src/Debug/*.pdb "$VCPKG_HOME/installed/x64-linux/debug/bin"
