@echo off
title Instalador AGY - Antigravity CLI
echo ==========================================================
echo        INSTALADOR AUTOMATICO DO AGY (WINDOWS)
echo ==========================================================
echo.
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0instalar_agy.ps1"
echo.
pause
