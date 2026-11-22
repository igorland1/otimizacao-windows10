<#
.SYNOPSIS
    Script de Rollback / Reversão das alterações do Windows 10.
#>

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Execute este script como Administrador!"
    exit
}

Write-Host "Restaurando configurações do Windows 10 para os padrões de fábrica..." -ForegroundColor Yellow

# 1. Prioridade de processos padrão (Win32PrioritySeparation = 2)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue

# 2. Resposta multimídia padrão
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 20 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 10 -Type DWord -Force -ErrorAction SilentlyContinue

# 3. GameDVR padrão
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

# 4. Plano de energia Equilibrado
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null

# 5. Notícias e Interesses ativado
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

# 6. Pesquisa Bing no menu Iniciar restaurada
Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

# 7. Reativar Serviços
$services = @("DiagTrack", "dmwappushservice", "MapsBroker", "XblAuthManager", "XblGameSave", "XboxNetApiSvc")
foreach ($s in $services) {
    if (Get-Service -Name $s -ErrorAction SilentlyContinue) {
        Set-Service -Name $s -StartupType Manual -ErrorAction SilentlyContinue
    }
}

Write-Host "✔️ Configurações revertidas para o padrão do Windows 10." -ForegroundColor Green
