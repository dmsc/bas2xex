#!/bin/sh

# Build LINUX
zig cc -Os -I build/ -o bas2xex src/bas2xex.c  -target x86_64-linux-musl
zip -9v bas2xex-linux.zip bas2xex README.md
rm -f bas2xex

# Build Win32
zig cc -Os -I build/ -o bas2xex.exe src/bas2xex.c  -target x86-windows
zip -9v bas2xex-windows32.zip bas2xex.exe README.md
rm -f bas2xex.exe

# Build MAC OS
zig cc -Os -I build/ -o bas2xex-arm src/bas2xex.c  -target aarch64-macos
zig cc -Os -I build/ -o bas2xex-x86 src/bas2xex.c  -target x86_64-macos
zip -9v bas2xex-macos.zip bas2xex-arm bas2xex-x86 README.md
rm -f bas2xex-arm
rm -f bas2xex-x86


