<#
.SYNOPSIS
    Script de Instalação e Inicialização Automática do AGY (Antigravity CLI).
.DESCRIPTION
    Instala o AGY na máquina e adiciona ao PATH se ainda não estiver instalado.
    Funciona tanto online quanto via instalador nativo da Google.
#>

[CmdletBinding()]
param()

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       INSTALADOR AUTOMÁTICO DO AGY (ANTIGRAVITY)        " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Verificar se o agy já está instalado
$agyPath = Join-Path $env:LOCALAPPDATA "agy\bin\agy.exe"
if (Test-Path $agyPath) {
    Write-Host "✔️ AGY já está instalado em: $agyPath" -ForegroundColor Green
} else {
    Write-Host "Baixando e instalando o AGY..." -ForegroundColor Cyan
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        irm https://antigravity.google/cli/install.ps1 | iex
        Write-Host "✔️ AGY instalado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Error "Falha ao baixar/instalar o AGY: $_"
        Write-Host "Verifique se a máquina possui conexão com a internet." -ForegroundColor Yellow
        exit 1
    }
}

# 2. Garantir que o binário está no PATH da sessão atual
$targetDir = Join-Path $env:LOCALAPPDATA "agy\bin"
if ($env:Path -notlike "*$targetDir*") {
    $env:Path = "$targetDir;" + $env:Path
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "🎉 AGY pronto para uso! Para iniciar o assistente:" -ForegroundColor Yellow
Write-Host "   Digite: agy" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
