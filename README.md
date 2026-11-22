# 🚀 AGY Workstation Setup & Instructions

> **Nota para o Agente AGY (Antigravity CLI):**  
> Ao iniciar o atendimento neste repositório no novo computador com Windows 10, siga rigorosamente as diretrizes operacionais descritas abaixo.

---

## 🎯 Objetivo da Estação de Trabalho
- **Perfil da Máquina:** Computador com hardware modesto/limitado dedicado exclusivamente para **edição de fotos** (Adobe Photoshop, Lightroom, Capture One, etc.).
- **Sistema Operacional:** Windows 10.
- **Prioridades:**
  1. Máxima liberação de memória RAM e CPU.
  2. Aceleração de leitura/escrita de disco (I/O para pastas pesadas de arquivos RAW).
  3. **OBRIGATÓRIO:** Manter miniaturas visíveis no Explorer (`IconsOnly = 0`) e ClearType ativo.
  4. Eliminação de telemetria, feeds, pesquisas web no Menu Iniciar e serviços de segundo plano.

---

## 🤖 Protocolo de Ação do AGY (Passo a Passo Automático)

Quando o usuário disser que baixou o repositório no novo computador ou pedir para "aplicar a otimização", execute as seguintes etapas:

### 1. Diagnóstico do Ambiente
- Checar se o terminal está com privilégios de Administrador:
  ```powershell
  ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  ```
- Obter a versão e build do Windows 10:
  ```powershell
  Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer
  ```
- Obter informações de hardware (RAM total, CPU e se a unidade C: é SSD/NVMe):
  ```powershell
  Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum | ForEach-Object { [math]::Round($_.Sum / 1GB, 2) }
  Get-PhysicalDisk | Select-Object FriendlyName, MediaType, BusType
  ```

### 2. Coleta de Benchmark Inicial
- Executar a medição do estado de fábrica:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\benchmark.ps1 -Etapa Antes
  ```

### 3. Configuração de Rede Estática e Otimização
- Configurar a interface de rede da Igreja com IP estático:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\configurar_rede_igreja.ps1
  ```
  *(Parâmetros: IP 192.168.100.10, Máscara /24, Gateway 192.168.100.1, DNS 192.168.100.1, 1.1.1.1, 8.8.8.8)*

- Executar a rotina completa (`Opção 8` do menu ou chamada direta das funções):
  ```powershell
  powershell -ExecutionPolicy Bypass -Command "& { . .\otimizar_windows10.ps1; Invoke-RestorePoint; Invoke-DebloatApps; Invoke-RegistryTweaks; Invoke-SystemTweaksWin10; Invoke-ServicesOptimization; Invoke-DiskCleanupAndTrim; Invoke-NetworkConfigIgreja }"
  ```

### 4. Validação de Saúde do Sistema
- Confirmar que o serviço de proteção/restauração criou o ponto:
  ```powershell
  Get-ComputerRestorePoint | Select-Object -Last 1
  ```
- Validar configuração de IP na interface:
  ```powershell
  Get-NetIPAddress -InterfaceAlias (Get-NetAdapter -Physical | Where-Object Status -ne Disabled | Select-Object -First 1).Name -AddressFamily IPv4
  ```
- Validar se o plano de energia de alto desempenho está ativo:
  ```powershell
  powercfg /getactivescheme
  ```
- Confirmar que a visualização de miniaturas no Explorer está preservada:
  ```powershell
  Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly"
  ```

### 5. Benchmark Comparativo e Orientação
- Instruir o usuário a reiniciar o sistema para carregar todas as chaves de registro e descarregar serviços.
- Após o reinício, rodar:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\benchmark.ps1 -Etapa Depois
  ```
- Apresentar a economia de processos e RAM em formato amigável.

---

## 📂 Mapa de Arquivos do Repositório

| Arquivo | Função |
| :--- | :--- |
| `instalar_agy.bat` | Instalador do AGY com duplo-clique no Windows (dispensa comandos manuais). |
| `instalar_agy.ps1` | Script PowerShell de instalação/atualização do Antigravity CLI e inclusão no PATH. |
| `otimizar_windows10.ps1` | Script principal modular (Restauração, Debloat, Regedit, Win10 Tweaks, Serviços, TRIM, Rede). |
| `configurar_rede_igreja.ps1` | Script dedicado para aplicar IP estático (192.168.100.10), Gateway e DNS na rede da Igreja. |
| `reverter_windows10.ps1` | Rollback completo para os padrões de fábrica da Microsoft. |
| `benchmark.ps1` | Coletor de métricas de RAM, processos e threads (Gera JSON e comparativo na tela). |
| `README.md` | Guia operacional e instruções para o AGY e para o usuário. |

---

## 🛡️ Procedimento de Emergência / Reversão
Se algum aplicativo de fotografia apresentar comportamento anômalo ou o usuário solicitar o retorno dos padrões:
```powershell
powershell -ExecutionPolicy Bypass -File .\reverter_windows10.ps1
```
Ou restaurar pelo Ponto de Restauração criado (`AGY_Pre_PhotoOpt`):
```powershell
Restore-Computer -RestorePoint (Get-ComputerRestorePoint | Where-Object { $_.Description -match "AGY" } | Select-Object -Last 1).SequenceNumber
```
