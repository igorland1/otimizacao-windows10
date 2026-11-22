<#
.SYNOPSIS
    Benchmark de desempenho e consumo de memória RAM antes e depois.
#>
param(
    [ValidateSet("Antes", "Depois")]
    [string]$Etapa = "Antes"
)

$OutputPath = "$PSScriptRoot\benchmark_$($Etapa.ToLower()).json"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       BENCHMARK DE PERFORMANCE WINDOWS 10 ($Etapa)       " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

Start-Sleep -Seconds 2

# Processos e Threads
$processes = Get-Process
$procCount = $processes.Count
$threadCount = ($processes | Measure-Object -Property Threads -Sum).Sum

# Memória RAM
$os = Get-CimInstance Win32_OperatingSystem
$totalRamMB = [math]::Round($os.TotalVisibleMemorySize / 1024, 2)
$freeRamMB = [math]::Round($os.FreePhysicalMemory / 1024, 2)
$usedRamMB = [math]::Round($totalRamMB - $freeRamMB, 2)
$ramUsagePct = [math]::Round(($usedRamMB / $totalRamMB) * 100, 2)

$data = [PSCustomObject]@{
    Etapa           = $Etapa
    DataHora        = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    ProcessosAtivos = $procCount
    ThreadsAtivas   = $threadCount
    RAM_Total_MB    = $totalRamMB
    RAM_EmUso_MB    = $usedRamMB
    RAM_Livre_MB    = $freeRamMB
    RAM_Percentual  = "$ramUsagePct%"
}

$data | ConvertTo-Json -Depth 2 | Set-Content -Path $OutputPath -Encoding UTF8

Write-Host "`n📊 Resultados ($Etapa):" -ForegroundColor Green
Write-Host "  - Processos em Execução : $procCount"
Write-Host "  - Threads Ativas        : $threadCount"
Write-Host "  - RAM em Uso            : $usedRamMB MB ($ramUsagePct% de $totalRamMB MB)"
Write-Host "  - Salvo em              : $OutputPath" -ForegroundColor DarkCyan

$beforePath = "$PSScriptRoot\benchmark_antes.json"
if ($Etapa -eq "Depois" -and (Test-Path $beforePath)) {
    Write-Host "`n==========================================================" -ForegroundColor Cyan
    Write-Host "              COMPARATIVO: ANTES vs DEPOIS                " -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Cyan
    
    $antes = Get-Content $beforePath | ConvertFrom-Json
    $diffProc = $procCount - $antes.ProcessosAtivos
    $diffRam = [math]::Round($usedRamMB - $antes.RAM_EmUso_MB, 2)

    Write-Host ("Processos: {0} -> {1} ({2})" -f $antes.ProcessosAtivos, $procCount, $(if ($diffProc -le 0) { "$diffProc" } else { "+$diffProc" })) -ForegroundColor $(if ($diffProc -le 0) { "Green" } else { "Red" })
    Write-Host ("RAM Usada: {0} MB -> {1} MB ({2} MB)" -f $antes.RAM_EmUso_MB, $usedRamMB, $(if ($diffRam -le 0) { "$diffRam" } else { "+$diffRam" })) -ForegroundColor $(if ($diffRam -le 0) { "Green" } else { "Red" })
    Write-Host "==========================================================`n" -ForegroundColor Cyan
}
