# Otimização Windows 10 para Estação de Edição de Fotos 🎨📸

Toolkit desenvolvido sob medida para **Windows 10** em máquinas com **hardware modesto/limitado**, voltadas especificamente para programas de edição de fotos (Photoshop, Lightroom, RawTherapee, Capture One, etc.).

---

## 🎯 Por que esta versão é diferente?
1. **Foco em RAM e CPU:** Softwares de fotografia consomem gigabytes de cache de imagem (Scratch Disk e RAM). O script ajusta `Win32PrioritySeparation` para dar prioridade quântica ao processo em primeiro plano e força o Windows a descarregar DLLs não utilizadas (`AlwaysUnloadDLL`).
2. **I/O de Disco (Acesso a Cartões e SSDs):** Desativa o `disablelastaccess` e compatibilidade 8.3 do NTFS, acelerando a navegação em diretórios com milhares de arquivos RAW/JPEG.
3. **Miniaturas e Fontes Preservadas:** Ao contrário de scripts genéricos de jogos que desativam tudo e deixam as fotos como ícones brancos genéricos, este mantém `IconsOnly = 0` (miniaturas visíveis no Explorer) e ClearType ativo.
4. **Debloat Específico:** Remove Xbox, Cortana, Mapas, Jogos da Microsoft e utilitários que geram tráfego e consomem RAM em segundo plano.
5. **Windows 10 Específico:** Desativa o widget "Notícias e Interesses" da barra de tarefas e a pesquisa web do Bing embutida no Menu Iniciar.

---

## 🚀 Como Executar no Novo Computador

### Passo 1: Abrir o PowerShell como Administrador
Pressione as teclas `Win + X` e selecione **Windows PowerShell (Administrador)**.

### Passo 2: Executar o Menu Interativo
Navegue até a pasta e execute:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
cd C:\caminho\para\otimizacao-windows10
.\otimizar_windows10.ps1
```

Escolha a opção **`7`** para rodar a otimização completa recomendada ou navegue pelas opções individuais.

---

## 📊 Medindo o Ganho (Benchmark)
Antes de aplicar as alterações, execute:
```powershell
.\benchmark.ps1 -Etapa Antes
```
Após aplicar e reiniciar o computador, execute:
```powershell
.\benchmark.ps1 -Etapa Depois
```
O script exibirá na tela a redução exata na quantidade de processos e megabytes de memória RAM liberados.

---

## 🔄 Reversão (Rollback)
Se por qualquer motivo desejar retornar os parâmetros ao padrão do Windows:
```powershell
.\reverter_windows10.ps1
```
