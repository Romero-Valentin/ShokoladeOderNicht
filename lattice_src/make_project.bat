@echo off

cd ..

if exist "build" (
    echo Folder 'build' deleted.
	rmdir /s /q "build"
)

mkdir build
cd build

IF %ERRORLEVEL% NEQ 0 (
    echo Failed to change directory.
    exit /b 1
)

call C:\lscc\radiant\2024.2\bin\nt64\radiant.exe -tcl ..\lattice_src\make_project.tcl