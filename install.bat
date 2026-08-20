@echo off
rem Windows entry point. The real work happens in install.ps1 .
rem Run from a terminal so you can read the output:
rem     install.bat
rem     install.bat -DryRun
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
endlocal
