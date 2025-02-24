@echo off
setlocal enabledelayedexpansion
cd /D "%~dp0"

:: ~ unpack args  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for %%a in (%*) do set "%%a=1"
if not "%release%"=="1" set debug=1
if "%debug%"=="1" set release=0 && echo [debug mode]
if "%release%"=="1" set debug=0 && echo [release mode]
echo [clang @ ..\code\third_party\wasi\win32\bin\clang.exe]
if "%~1"=="" echo [default mode, assuming `index` build] && set index=1
if "%~1"=="release" if "%~2"=="" echo [default mode, assuming `index` build] && set index=1

:: ~ unpack cmdln build args  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set auto_compile_flags=
if "%asan%"=="1" set auto_compile_flags=%auto_compile_flags% -fsanitize=address && echo [asan enabled]

:: ~ compile defs ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set compile_common=     --target=wasm32-wasi --sysroot=..\code\third_party\wasi\win32\share\wasi-sysroot -I..\code\ -I..\local\ -gcodeview -fdiagnostics-absolute-paths -Wall -Wno-unknown-warning-option -Wno-missing-braces -Wno-unused-function -Wno-writable-strings -Wno-unused-value -Wno-unused-variable -Wno-unused-local-typedef -Wno-deprecated-register -Wno-deprecated-declarations -Wno-unused-but-set-variable -Wno-single-bit-bitfield-constant-conversion -Wno-compare-distinct-pointer-types -Wno-initializer-overrides -Wno-incompatible-pointer-types-discards-qualifiers -Xclang -flto-visibility-public-std -ferror-limit=10000
set compile_debug=      call ..\code\third_party\wasi\win32\bin\clang.exe -g -O0 -DBUILD_DEBUG=1 %compile_common% %auto_compile_flags%
set compile_release=    call ..\code\third_party\wasi\win32\bin\clang.exe -g -O2 -DBUILD_DEBUG=0 %compile_common% %auto_compile_flags%
set link=               -fuse-ld=..\code\third_party\wasi\win32\bin\lld.exe -Xlinker /MANIFEST:EMBED -Xlinker /pdbaltpath:%%%%_PDB%%%% -Xlinker
set out=                -o

:: ~ compile mode ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if "%debug%"=="1"       set compile=%compile_debug%
if "%release%"=="1"     set compile=%compile_release%

:: ~ NOTE(mmcwsk): just export procedures, no entry point ~~~~~~~~~~~~~~~~~~~~~
set compile=%compile% -nostartfiles
set compile=%compile% -Wl,--no-entry

:: ~ prepare dirs ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if not exist build mkdir build
if not exist local mkdir local

:: ~ get git commit hash ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for /f %%i in ('call git describe --always --dirty') do set compile=%compile% -DBUILD_GIT_HASH=\"%%i\"
for /f %%i in ('call git rev-parse HEAD')            do set compile=%compile% -DBUILD_GIT_HASH_FULL=\"%%i\"

:: ~ build targets ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pushd build
if "%index%"=="1" set built=1 && %compile% ..\code\index\index_main.c %compile_link% %link_icon% %out%index.wasm || exit /b 1
popd

:: ~ warn on no builds ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if "%built%"=="" (
  echo [WARNING] no valid build target specified; must use build target names as arguments to this script, like `build index`.
  exit /b 1
)