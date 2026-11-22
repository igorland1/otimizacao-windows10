<#
.SYNOPSIS
    Script Master de Otimização do Windows 10 para Estações de Edição de Fotos (Photoshop, Lightroom, etc.)
.DESCRIPTION
    Focado em hardware modesto/limitado:
    - Camada 0: Criação de Ponto de Restauração
    - Camada 1: Debloat profundo de aplicativos UWP / Bloatware nativo (mantendo Fotos se necessário, ou limpando tudo)
    - Camada 2: Otimização de Registro (Desempenho de RAM, CPU, I/O de Disco, Prefetch/Superfetch para SSD, Foco de Janela)
    - Camada 3: Desativação de Serviços em Segundo Plano, Telemetria, Bing no Menu Iniciar, Cortana e Notícias e Interesses
    - Camada 4: Otimização de Memória Virtual (Pagefile) e Armazenamento (Trim SSD + Limpeza)
#>

# Forçar execução como Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Execute este script como Administrador!"
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "    OTIMIZAÇÃO WINDOWS 10 - WORKSTATION EDIÇÃO DE FOTOS (AGY)    " -ForegroundColor Yellow
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "1. [Segurança] Criar Ponto de Restauração do Windows"
    Write-Host "2. [Debloat] Remover Aplicativos Nativos Inúteis (Liberar RAM/Disco)"
    Write-Host "3. [Registro] Tweaks de Regedit (Foco CPU, Prioridade de I/O e RAM)"
    Write-Host "4. [Sistema] Desativar Telemetria, Bing no Iniciar e Feeds"
    Write-Host "5. [Serviços] Desativar Serviços Pesados de Segundo Plano"
    Write-Host "6. [Limpeza & Disco] Limpar Caches, Temporários e TRIM no SSD"
    Write-Host "7. [Rede Igreja] Fixar IP 192.168.100.10 (Infraestrutura da Igreja)"
    Write-Host "8. [EXECUÇÃO COMPLETA] Aplicar TODAS as otimizações recomendadas (1 a 7)"
    Write-Host "0. Sair"
    Write-Host "=================================================================" -ForegroundColor Cyan
}

function Invoke-RestorePoint {
    Write-Host "`n[1/6] Criando Ponto de Restauração..." -ForegroundColor Green
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "AGY_Pre_PhotoOpt" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host "✔️ Ponto de restauração 'AGY_Pre_PhotoOpt' criado com sucesso!" -ForegroundColor Green
    }
    catch {
        Write-Warning "Aviso: Não foi possível criar ponto de restauração automático ($_). Certifique-se de que a Proteção do Sistema está ativa em C:."
    }
}

function Invoke-DebloatApps {
    Write-Host "`n[2/6] Removendo aplicativos pré-instalados (Debloat UWP)..." -ForegroundColor Green
    
    # Lista de apps que consomem memória e processamento em segundo plano
    $bloatApps = @(
        "Microsoft.549981C3F5F10"              # Cortana
        "Microsoft.BingWeather"
        "Microsoft.BingNews"
        "Microsoft.BingFinance"
        "Microsoft.BingSports"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"                 # Dicas
        "Microsoft.MicrosoftOfficeHub"         # Atalho Office
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.People"
        "Microsoft.PowerAutomateDesktop"
        "Microsoft.Todos"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.ZuneVideo"                  # Filmes e TV
        "Microsoft.ZuneMusic"                  # Groove Música
        "Microsoft.YourPhone"                  # Vincular ao Celular
        "MicrosoftCorporationII.QuickAssist"
        "Clipchamp.Clipchamp"
        "SpotifyAB.SpotifyMusic"
        "Disney.37853FC22B2CE"
        "Microsoft.XboxApp"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.GamingApp"
        "Microsoft.MixedReality.Portal"
        "Microsoft.SkypeApp"
        "Microsoft.OneConnect"
    )

    foreach ($app in $bloatApps) {
        Write-Host "Removendo $app..." -ForegroundColor DarkYellow
        Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "*$app*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    }

    Write-Host "✔️ Aplicativos desnecessários removidos." -ForegroundColor Green
}

function Invoke-RegistryTweaks {
    Write-Host "`n[3/6] Aplicando Tweaks no Registro para Edição de Fotos (Photoshop/Lightroom)..." -ForegroundColor Green

    # 1. Prioridade de Processos em Primeiro Plano (Win32PrioritySeparation = 26 hex / 38 dec = máximo foco na janela ativa)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force -ErrorAction SilentlyContinue

    # 2. Resposta do Sistema: 0% de reserva para multimídia em background (100% de CPU para apps em uso)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force -ErrorAction SilentlyContinue

    # 3. Gerenciamento de Memória: Despejo de DLLs da RAM imediatamente após fechar programas pesados
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "AlwaysUnloadDLL" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

    # 4. Desativar GameDVR e Capturas que consomem GPU/RAM
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

    # 5. Otimização de I/O do Sistema de Arquivos NTFS (desativar criação de nomes curtos 8.3 e timestamp de último acesso para acelerar leitura de pastas com milhares de RAWs)
    fsutil behavior set disablelastaccess 1 | Out-Null
    fsutil behavior set disable8dot3 1 | Out-Null

    # 6. Ativar Plano de Energia de Alto Desempenho
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null

    # 7. Efeitos Visuais Essenciais: Desativa animações lentas, mas MANTÉM miniaturas de fotos e fontes suaves (ClearType)
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -Type String -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue # Garante miniaturas de fotos visíveis
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value 2 -Type String -Force -ErrorAction SilentlyContinue # Fontes nítidas

    Write-Host "✔️ Ajustes de registro de alto desempenho aplicados." -ForegroundColor Green
}

function Invoke-SystemTweaksWin10 {
    Write-Host "`n[4/6] Desativando Telemetria, Bing no Iniciar e Feeds no Windows 10..." -ForegroundColor Green

    # 1. Desativar Notícias e Interesses na Barra de Tarefas (Windows 10)
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue

    # 2. Desativar Pesquisa do Bing no Menu Iniciar (Economiza RAM e conexões de rede em segundo plano)
    New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

    # 3. Desativar Telemetria Básica e Coleta de Dados de Diagnóstico
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

    # 4. Desativar Anúncios, Sugestões de Apps e Dicas no Sistema
    $contentDelivery = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Set-ItemProperty -Path $contentDelivery -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $contentDelivery -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $contentDelivery -Name "SubscribedContent-353698Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $contentDelivery -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $contentDelivery -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

    # 5. Desativar Histórico de Atividades / Linha do Tempo (Timeline)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

    Write-Host "✔️ Recursos invasivos e feeds do Windows 10 desativados." -ForegroundColor Green
}

function Invoke-ServicesOptimization {
    Write-Host "`n[5/6] Otimizando Serviços do Windows..." -ForegroundColor Green

    # Serviços que não têm utilidade numa máquina de edição de fotos e pesam na RAM
    $servicesToDisable = @(
        "DiagTrack",                 # Connected User Experiences and Telemetry
        "dmwappushservice",          # WAP Push Message Routing Service (Telemetria)
        "MapsBroker",                # Downloaded Maps Manager
        "RetailDemo",                # Demonstração de Loja
        "XblAuthManager",            # Xbox Live Auth Manager
        "XblGameSave",               # Xbox Live Game Save
        "XboxNetApiSvc",             # Xbox Live Networking
        "WpcMonSvc"                  # Controle dos Pais (Parental Controls)
    )

    foreach ($service in $servicesToDisable) {
        if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
            Write-Host "Desativando serviço: $service..." -ForegroundColor DarkYellow
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        }
    }

    Write-Host "✔️ Serviços desnecessários desativados." -ForegroundColor Green
}

function Invoke-DiskCleanupAndTrim {
    Write-Host "`n[6/6] Limpeza de Cache, Temporários e Otimização de SSD..." -ForegroundColor Green

    # Limpeza de pastas temporárias
    $tempFolders = @(
        "$env:LOCALAPPDATA\Temp\*",
        "$env:WINDIR\Temp\*",
        "$env:WINDIR\Prefetch\*"
    )

    foreach ($folder in $tempFolders) {
        Write-Host "Limpando $folder..." -ForegroundColor DarkYellow
        Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Trim no drive C:
    Write-Host "Enviando comando TRIM para os SSDs..." -ForegroundColor Cyan
    Optimize-Volume -DriveLetter C -Defrag -ReTrim -Verbose -ErrorAction SilentlyContinue

    Write-Host "✔️ Limpeza e TRIM concluídos." -ForegroundColor Green
}

function Invoke-NetworkConfigIgreja {
    Write-Host "`n[7/7] Configurando IP Estático da Igreja (192.168.100.10)..." -ForegroundColor Green
    if (Test-Path "$PSScriptRoot\configurar_rede_igreja.ps1") {
        & "$PSScriptRoot\configurar_rede_igreja.ps1"
    } else {
        Write-Warning "Arquivo configurar_rede_igreja.ps1 não encontrado."
    }
}

# Execução do Menu
do {
    Show-Menu
    $choice = Read-Host "Selecione uma opção (0-8)"
    switch ($choice) {
        "1" { Invoke-RestorePoint; Pause }
        "2" { Invoke-DebloatApps; Pause }
        "3" { Invoke-RegistryTweaks; Pause }
        "4" { Invoke-SystemTweaksWin10; Pause }
        "5" { Invoke-ServicesOptimization; Pause }
        "6" { Invoke-DiskCleanupAndTrim; Pause }
        "7" { Invoke-NetworkConfigIgreja; Pause }
        "8" {
            Invoke-RestorePoint
            Invoke-DebloatApps
            Invoke-RegistryTweaks
            Invoke-SystemTweaksWin10
            Invoke-ServicesOptimization
            Invoke-DiskCleanupAndTrim
            Invoke-NetworkConfigIgreja
            Write-Host "`n🎉 Todas as otimizações e a configuração de rede foram concluídas com sucesso!" -ForegroundColor Green
            Write-Host "Reinicie o computador para garantir que todos os serviços e registros sejam carregados perfeitamente." -ForegroundColor Yellow
            Pause
        }
        "0" { Write-Host "Saindo..."; break }
        default { Write-Warning "Opção inválida."; Start-Sleep -Seconds 1 }
    }
} while ($choice -ne "0")
