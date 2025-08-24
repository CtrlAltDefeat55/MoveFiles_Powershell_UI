@echo off
setlocal

:: Set a title for the command window for clarity
title MoveFiles Launcher

:: ====================================================================
::  This batch file locates and runs a PowerShell script
::  relative to its own location.
:: ====================================================================

:: Change the current directory to the directory where this batch file is located.
:: %~dp0 is a special variable that expands to the Drive and Path of the current script.
pushd "%~dp0"

:: Define the name of the PowerShell script to look for.
set "psScript=MoveFilesScript_Upgrade.ps1"
:: set "psScript=MoveFilesScript_Upgrade_V2.ps1"

:: Check if the PowerShell script exists in this folder.
IF EXIST "%psScript%" (
    ECHO Found %psScript%. Launching the script...
    
    :: If found, launch it using the specified parameters.
    :: %* passes any arguments from this batch file to the PowerShell script
    powershell -NoProfile -ExecutionPolicy Bypass -File "%psScript%" %*
    
) ELSE (
    :: If the script is not found, display an error message.
    ECHO.
    ECHO ERROR: PowerShell script not found!
    ECHO.
    ECHO This batch file was looking for "%psScript%"
    ECHO in the following directory:
    ECHO %cd%
    ECHO.
    ECHO Please ensure "%psScript%" is in the same folder as this batch file.
    
    :: Keep the window open so the user can read the error.
    pause
)

:: Restore the original directory (good practice)
popd

goto :eof