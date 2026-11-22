@echo off
:: Forçar execução como Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Solicitando privilegios de Administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title Configuracao e Otimizacao Windows 10 - Workstation Edicao de Fotos
cd /d "%~dp0"

echo =================================================================
echo   INICIANDO CONFIGURACAO DE IP DA IGREJA E OTIMIZACAO DO WINDOWS 10
echo =================================================================
echo.
echo 1. Configurando IP Estatico: 192.168.100.10
echo 2. Debloat de Apps UWP, Foco de CPU/RAM para Fotos e Limpeza
echo.

powershell -ExecutionPolicy Bypass -NoProfile -Command "& { . '.\otimizar_windows10.ps1'; Invoke-RestorePoint; Invoke-NetworkConfigIgreja; Invoke-DebloatApps; Invoke-RegistryTweaks; Invoke-SystemTweaksWin10; Invoke-ServicesOptimization; Invoke-DiskCleanupAndTrim }"

echo.
echo =================================================================
echo Processo concluido! Reinicie o computador para aplicar todas as alteracoes.
echo =================================================================
pause
