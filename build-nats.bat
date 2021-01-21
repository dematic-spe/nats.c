@echo.
@echo This script will build nats.c for windows. it assumes you are running in the
@echo "x86_x64 Cross Tools Command Prompt for VS 2019" command shell. if you are not
@echo stop this script and first run this command shell

PAUSE

mkdir repos

REM pull vcpckg and build the 2020.11 tag 
git clone https://github.com/microsoft/vcpkg.git repos\vcpkg
cd repos\vcpkg 
git checkout 2020.11
cmd /c bootstrap-vcpkg.bat
vcpkg install zlib openssl Protobuf --triplet x64-windows

cd %~dp0

REM pull protobuf-c and switch to a known tag 
git clone https://github.com/protobuf-c/protobuf-c.git repos\protobuf-c
cd repos\protobuf-c
git checkout v1.3.3
cd %~dp0

mkdir build
cd build

REM copy protobuf-c into our project.. easier then trying to get that project to build/link/export on windows
mkdir  ..\src\include\protobuf-c\
copy ..\repos\protobuf-c\protobuf-c\protobuf-c.h ..\src\include\protobuf-c\protobuf-c.h
copy ..\repos\protobuf-c\protobuf-c\protobuf-c.h ..\src\protobuf-c.h
copy ..\repos\protobuf-c\protobuf-c\protobuf-c.c ..\src\protobuf-c.c
mkdir  ..\src\protobuf-c\
copy ..\repos\protobuf-c\protobuf-c\protobuf-c.h ..\src\protobuf-c\protobuf-c.h

cmake .. -DCMAKE_TOOLCHAIN_FILE=..\repos\vcpkg\scripts\buildsystems\vcpkg.cmake -DNATS_BUILD_STREAMING=ON

cmake --build . --config Debug
cmake --build . --config Release
