@echo off
setlocal enabledelayedexpansion
title Folder Monitor

rem REPLACE! With the path of the folder you want to monitor.
set "folder_to_monitor=C:\Users\Nico\Downloads\test"

set "temp_dir=%temp%"

set "current_file=%temp_dir%\current_file.txt"
set "previous_file=%temp_dir%\previous_file.txt"
set "current_hashes=%temp_dir%\current_hashes.txt"
set "previous_hashes=%temp_dir%\previous_hashes.txt"

dir /b /s "%folder_to_monitor%" > "%previous_file%"

del "%previous_hashes%" >nul 2>&1
for /f "delims=" %%A in ('type "%previous_file%"') do (
    certutil -hashfile "%%A" MD5 >> "%previous_hashes%"
)

echo Folder to monitor: %folder_to_monitor%

:loop
timeout /t 5 /nobreak >nul

dir /b /s "%folder_to_monitor%" > "%current_file%"

del "%current_hashes%" >nul 2>&1
for /f "delims=" %%A in ('type "%current_file%"') do (
    certutil -hashfile "%%A" MD5 >> "%current_hashes%"
)

rem Detectar archivos eliminados y renombrados
for /f "delims=" %%A in ('type "%previous_file%"') do (
    findstr /x /c:"%%A" "%current_file%" >nul
    if errorlevel 1 (
        set "deleted_file=%%A"
        set "deleted_hash="
        if exist "%previous_hashes%" (
            for /f "delims=" %%B in ('findstr /c:"%%A" "%previous_hashes%"') do set "deleted_hash=%%B"
        )

        set "renamed=0"
        for /f "delims=" %%C in ('type "%current_file%"') do (
            findstr /x /c:"%%C" "%previous_file%" >nul
            if errorlevel 1 (
                set "current_hash="
                if exist "%current_hashes%" (
                    for /f "delims=" %%D in ('findstr /c:"%%C" "%current_hashes%"') do set "current_hash=%%D"
                )
                if "!deleted_hash!" == "!current_hash!" (
                    echo [93mFile "!deleted_file!" renamed to "%%C".[0m
                    set "renamed=1"
                    rem Eliminar el archivo renombrado de las listas anteriores
                    findstr /x /v /c:"%%A" "%previous_file%" > "%previous_file%.tmp"
                    move /y "%previous_file%.tmp" "%previous_file%" >nul
                    findstr /x /v /c:"%%A" "%previous_hashes%" > "%previous_hashes%.tmp"
                    move /y "%previous_hashes%.tmp" "%previous_hashes%" >nul
                )
            )
        )
        if !renamed! == 0 (
            echo [1;91mFile "!deleted_file!" deleted.[0m
            rem Eliminar el archivo eliminado de las listas anteriores
            findstr /x /v /c:"%%A" "%previous_file%" > "%previous_file%.tmp"
            move /y "%previous_file%.tmp" "%previous_file%" >nul
            findstr /x /v /c:"%%A" "%previous_hashes%" > "%previous_hashes%.tmp"
            move /y "%previous_hashes%.tmp" "%previous_hashes%" >nul
        )
    )
)

rem Detectar archivos añadidos
for /f "delims=" %%A in ('type "%current_file%"') do (
    findstr /x /c:"%%A" "%previous_file%" >nul
    if errorlevel 1 echo [1;92mFile "%%A" added.[0m
)

rem Detectar archivos modificados
for /f "delims=" %%A in ('type "%previous_file%"') do (
    findstr /x /c:"%%A" "%current_file%" >nul
    if errorlevel 0 (
        set "current_hash="
        if exist "%current_hashes%" (
            for /f "delims=" %%B in ('findstr /c:"%%A" "%current_hashes%"') do set "current_hash=%%B"
        )
        set "previous_hash="
        if exist "%previous_hashes%" (
            for /f "delims=" %%B in ('findstr /c:"%%A" "%previous_hashes%"') do set "previous_hash=%%B"
        )
        if "!current_hash!" neq "!previous_hash!" echo [93mFile "%%A" modified.[0m
    )
)

rem Guardar la lista actual y los hashes como los previos para la siguiente iteración
copy /y "%current_file%" "%previous_file%" >nul
copy /y "%current_hashes%" "%previous_hashes%" >nul

goto loop
