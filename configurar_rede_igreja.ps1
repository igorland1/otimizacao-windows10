<#
.SYNOPSIS
    Configuração de IP Estático e DNS para a rede da Igreja.
.DESCRIPTION
    Aplica as configurações de rede solicitadas:
    - IP: 192.168.100.10
    - Máscara: 255.255.255.0 (/24)
    - Gateway Padrão: 192.168.100.1
    - DNS Primário: 192.168.100.1 (ou 1.1.1.1 / 8.8.8.8)
    Detecta automaticamente o adaptador de rede Ethernet/Wi-Fi conectado ou configurável.
#>

[CmdletBinding()]
param(
    [string]$IPAddress = "192.168.100.10",
    [int]$PrefixLength = 24, # Máscara 255.255.255.0
    [string]$Gateway = "192.168.100.1",
    [string[]]$DnsServers = @("192.168.100.1", "1.1.1.1", "8.8.8.8")
)

# Checa privilégio de Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Execute este script como Administrador no PowerShell!"
    exit
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     CONFIGURAÇÃO DE IP ESTÁTICO - REDE DA IGREJA         " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Identificar Adaptadores de Rede Físicos (priorizando Ethernet)
$adapters = Get-NetAdapter -Physical | Where-Object { $_.Status -ne "Disabled" }

if (-not $adapters) {
    Write-Warning "Nenhum adaptador de rede físico ativo foi encontrado."
    exit
}

Write-Host "Adaptadores encontrados:" -ForegroundColor Gray
$adapters | Format-Table ifIndex, Name, InterfaceDescription, Status, LinkSpeed

# Selecionar o adaptador: se houver apenas um ou se houver Ethernet, preferir Ethernet
$targetAdapter = $adapters | Where-Object { $_.Name -like "*Ethernet*" -or $_.InterfaceDescription -like "*Ethernet*" -or $_.InterfaceDescription -like "*Gigabit*" -or $_.InterfaceDescription -like "*Realtek*" -or $_.InterfaceDescription -like "*Intel*" } | Select-Object -First 1

if (-not $targetAdapter) {
    $targetAdapter = $adapters[0]
}

Write-Host "Configurando adaptador: $($targetAdapter.Name) (Índice: $($targetAdapter.ifIndex))..." -ForegroundColor Cyan

try {
    # 2. Remover IPs estáticos ou DHCP existentes na interface
    Get-NetIPAddress -InterfaceIndex $targetAdapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
    Get-NetRoute -InterfaceIndex $targetAdapter.ifIndex -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Remove-NetRoute -Confirm:$false -ErrorAction SilentlyContinue

    # 3. Aplicar o novo IP Estático e Gateway
    New-NetIPAddress -InterfaceIndex $targetAdapter.ifIndex -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway -ErrorAction Stop | Out-Null
    Write-Host "✔️ IP $IPAddress e Gateway $Gateway definidos com sucesso!" -ForegroundColor Green

    # 4. Configurar Servidores DNS
    Set-DnsClientServerAddress -InterfaceIndex $targetAdapter.ifIndex -ServerAddresses $DnsServers -ErrorAction Stop
    Write-Host "✔️ DNS configurado: $($DnsServers -join ', ')" -ForegroundColor Green

    # 5. Exibir status final
    Write-Host "`nResumo da Conexão:" -ForegroundColor Cyan
    Get-NetIPConfiguration -InterfaceIndex $targetAdapter.ifIndex | Format-List InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer
}
catch {
    Write-Error "Ocorreu um erro ao configurar a rede: $_"
}
