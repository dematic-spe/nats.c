

@echo off

set ERROR_CODE=0

@REM ==== START VALIDATION ====
if not "%VCPKG_HOME%"=="" goto OK_VCPKG_HOME
echo The VCPKG_HOME environment variable is not defined correctly >&2
echo This environment variable is needed to run this program >&2
goto error

echo The VCPKG_HOME environment variable exists
:OK_VCPKG_HOME
@REM Check if vcpkg is checked out, if not then check it out
if exist "%VCPKG_HOME%\bootstrap-vcpkg.bat" goto VCPKG_GIT
echo The VCPKG_HOME environment variable exists but the code is not checked out, so it will be checked out >&2
git clone https://github.com/microsoft/vcpkg.git %VCPKG_HOME%

:VCPKG_GIT
REM echo The VCPKG_HOME git project is checked out
set VCPKG_CMD="%VCPKG_HOME%/vcpkg.exe"
if exist "%VCPKG_CMD%" goto VCPKG_BUILT
call "%VCPKG_HOME%\bootstrap-vcpkg.bat"

:VCPKG_BUILT
@REM ==== Checking if libraries are built ====
REM echo The %VCPKG_CMD% has already been built
if not exist "%VCPKG_HOME%/installed/x64-windows/include/openssl"   %VCPKG_CMD% install openssl --triplet x64-windows
if not exist "%VCPKG_HOME%/installed/x64-windows/include/zlib.h"      %VCPKG_CMD% install zlib --triplet x64-windows
if not exist "%VCPKG_HOME%/installed/x64-windows/include/Protobuf"     %VCPKG_CMD% install Protobuf --triplet x64-windows

REM pull protobuf-c and switch to a known tag 
git clone https://github.com/protobuf-c/protobuf-c.git repos\protobuf-c
cd repos\protobuf-c
git checkout v1.3.3
cd %~dp0

if exist "%VCPKG_HOME%\installed\x64-windows\bin\nats.dll" goto END

mkdir build
cd build

REM copy protobuf-c into our project.. easier then trying to get that project to build/link/export on windows
mkdir  ..\src\include\protobuf-c\
copy ..\repos\protobuf-c\protobuf-c\protobuf-c.h ..\src\include\protobuf-c\protobuf-c.h
copy ..\repos\protobuf-c\protobuf-c\protobuf-c.h ..\src\protobuf-c.h
copy ..\repos\protobuf-c\protobuf-c\protobuf-c.c ..\src\protobuf-c.c
mkdir  ..\src\protobuf-c\
copy ..\repos\protobuf-c\protobuf-c\protobuf-c.h ..\src\protobuf-c\protobuf-c.h

cmake .. -DCMAKE_TOOLCHAIN_FILE=%VCPKG_HOME%\scripts\buildsystems\vcpkg.cmake -DNATS_BUILD_STREAMING=ON

cmake --build . --config Debug
cmake --build . --config Release

cd %~dp0

mkdir %VCPKG_HOME%\installed\x64-windows\include\nats
copy src/nats.h %VCPKG_HOME%\installed\x64-windows\include\nats
copy src/version.h %VCPKG_HOME%\installed\x64-windows\include\nats
copy src/status.h %VCPKG_HOME%\installed\x64-windows\include\nats

copy  build\src\Release\*.lib %VCPKG_HOME%\installed\x64-windows\lib
copy  build\src\Release\*.dll %VCPKG_HOME%\installed\x64-windows\bin

copy  build\src\Debug\*.lib %VCPKG_HOME%\installed\x64-windows\debug\lib
copy  build\src\Debug\*.dll %VCPKG_HOME%\installed\x64-windows\debug\bin
copy  build\src\Debug\*.pdb %VCPKG_HOME%\installed\x64-windows\debug\bin

goto END

:error
set ERROR_CODE=1

:END
