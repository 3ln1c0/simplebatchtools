@echo off

REM Replace this text! You can replace it with the name of your program or whatever you want.
echo (ReplaceThisText!) Batch Simple Installer - Created by Nico (ReplaceThisText!)
title (ReplaceThisText!) Batch Simple Installer - Created by Nico (ReplaceThisText!)

set /p destination_route=Enter the path where the program will be installed:

if not exist "%destination_route%\" (
    echo The specified destination route is invalid. Installation canceled.
    pause
    exit
)

if exist "%destination_route%" (
    echo The destination route already exists. Do you want to proceed? (Y/N)
    set /p opcion=
    if /I "%opcion%" NEQ "Y" (
        echo Installation canceled.
        pause
        exit
    )
)

REM Replace with the name of the .zip file that contains the files you want the installer to install.
set "file_path=ReplaceWithFileName.zip"

if not exist "%file_path%" (
    echo The specified .zip file does not exist. Installation canceled.
    pause
    exit
)

powershell Expand-Archive -Path "%file_path%" -DestinationPath "%destination_route%"

echo Installation completed.
pause
