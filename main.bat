@echo off
setlocal enabledelayedexpansion
title Terrys - Script TI

:: ===== Verificando nivel de permissao =====
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs" 2>nul
    if !errorlevel! neq 0 (
        echo Falha ao solicitar elevacao de administrador.
        echo Voce cancelou o UAC ou ocorreu um erro.
        pause
    )
    exit /b
)

cls

echo.
echo ==========================
echo   TERRYS - TI
echo ==========================
echo.

:: ===== Bats de auxilio =====
if exist "%~dp0information.bat" (

    start "" "%~dp0information.bat"
)

:: ===== Verificando Winget =====
where winget >nul 2>&1 || (
    echo Erro: Winget nao encontrado, favor verificar se ele esta instalado na estacao.
    pause
    exit /b
)

:: Modificando tempo de tela e hibernação
powercfg /change monitor-timeout-ac 240
powercfg /change hibernate-timeout-ac 240

:: ===== Instalando softwares padrao =====
echo.
echo [1] Instalacao de Softwares
echo ----------------------------------------------------
echo.

for %%p in (
    7zip.7zip
    Adobe.Acrobat.Reader.64-bit
    Microsoft.VisualStudioCode
    JetBrains.IntelliJIDEA
    Git.Git
    OpenJS.NodeJS
    Python.Python.3.14
    EclipseAdoptium.Temurin.21.JDK
) do (
    echo Instalando %%p...
    winget install -e --id %%p --silent --accept-package-agreements --accept-source-agreements >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [OK] %%p
    ) else (
        echo   [ERRO] %%p
    )
)

:: ===== Atualizando softwares =====
echo.
echo.
echo [2] Atualizacao de Softwares
echo ----------------------------------------------------
echo.

winget upgrade --all --force --include-unknown --accept-package-agreements --accept-source-agreements

:: ===== Drivers e Updates =====
echo.
echo.
echo [3] Drivers e Updates
echo ----------------------------------------------------
echo.

:: Garantindo que o PowerShell pode rodar scripts
powershell -NoProfile -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"

:: Garantindo NuGet provider instalado (evita prompt interativo)
echo Verificando provider NuGet...
powershell -NoProfile -Command "if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false }"

:: Marcando o PSGallery como repositorio confiavel (evita prompt de "untrusted repository")
echo Configurando PSGallery como fonte confiavel...
powershell -NoProfile -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"

:: Verificando/instalando o modulo PSWindowsUpdate
echo Verificando modulo PSWindowsUpdate...
powershell -NoProfile -Command "if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) { Install-Module -Name PSWindowsUpdate -Force -Confirm:$false -Scope AllUsers }"

if !errorlevel! neq 0 (
    echo   [ERRO] Nao foi possivel instalar o modulo PSWindowsUpdate.
    echo   Verifique a conexao com a internet ou politicas de rede.
) else (
    echo   [OK] Modulo PSWindowsUpdate disponivel.
    echo.

    echo Buscando e instalando atualizacoes do Windows...
    powershell -NoProfile -Command "Import-Module PSWindowsUpdate; Get-WindowsUpdate -AcceptAll -Install -AutoReboot:$false -IgnoreReboot"

    echo.
    echo Buscando e instalando drivers via Windows Update...
    powershell -NoProfile -Command "Import-Module PSWindowsUpdate; Get-WindowsUpdate -UpdateType Driver -AcceptAll -Install -AutoReboot:$false -IgnoreReboot"
)

:: ===== Saude e integridade =====
echo.
echo.
echo [4] Saude e integridade
echo ----------------------------------------------------
echo.

:: ===== Verificacao e ativacao do Windows (KMS) =====
set GVLK_PRO=W269N-WFGWX-YVC9B-4J6C9-T83GX

powershell -NoProfile -Command "$lic = Get-CimInstance SoftwareLicensingProduct -Filter \"ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'\" | Where-Object { $_.PartialProductKey }; exit $(if ($lic.LicenseStatus -eq 1) { 0 } else { 1 })"

if !errorlevel! equ 0 (
    echo [OK] Windows ja esta ativado via KMS.
) else (
    echo [AVISO] Windows nao esta ativado.

    :: Verifica se existe alguma chave parcial instalada
    powershell -NoProfile -Command "$lic = Get-CimInstance SoftwareLicensingProduct -Filter \"ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'\" | Where-Object { $_.PartialProductKey }; exit $(if ($lic.PartialProductKey) { 0 } else { 1 })"

    if !errorlevel! equ 0 (
        echo Chave existente detectada. Tentando apenas renovar via KMS...
        cscript //nologo C:\Windows\System32\slmgr.vbs /ato
    ) else (
        echo Nenhuma chave instalada. Instalando GVLK Pro e ativando...
        cscript //nologo C:\Windows\System32\slmgr.vbs /ipk !GVLK_PRO!
        cscript //nologo C:\Windows\System32\slmgr.vbs /ato
    )

    echo.
    echo Resultado final:
    cscript //nologo C:\Windows\System32\slmgr.vbs /xpr
)

:: Status do Windows Defender
echo Verificando status do Windows Defender.....
powershell -NoProfile -Command "$mp = Get-MpComputerStatus; Write-Output ('Antivirus ativo: ' + $mp.AntivirusEnabled); Write-Output ('Tempo real ativo: ' + $mp.RealTimeProtectionEnabled); Write-Output ('Assinaturas atualizadas em: ' + $mp.AntivirusSignatureLastUpdated)"

:: Analise e limpeza de componentes do Windows
echo.
echo Analisando componentes do sistema (DISM)...
DISM /Online /Cleanup-Image /AnalyzeComponentStore

echo Limpando componentes antigos (DISM)...
DISM /Online /Cleanup-Image /StartComponentCleanup

:: Integridade do sistema
echo.
echo Verificando integridade do sistema (sfc)...
sfc /scannow

:: Saude do sistema
echo.
echo Restaurando saude da imagem do sistema (DISM)...
DISM /Online /Cleanup-Image /RestoreHealth

:: Disco - agenda verificacao/reparo para o proximo boot
echo.
echo Agendando verificacao de disco (chkdsk)...
echo Y| chkdsk %systemdrive% /f /r

:: Internet
echo.
echo Resetando configuracoes de rede...
ipconfig /flushdns
netsh winsock reset
netsh int ip reset

:: Politicas
echo.
echo Atualizando politicas de grupo...
gpupdate /force

:: ===== Limpeza e otimizacao =====
echo.
echo.
echo [5] Limpeza e otimizacao
echo ----------------------------------------------------
echo.

:: Limpeza de temporarios
echo Limpando temporarios.....
del /s /q "%temp%\*" >nul 2>&1
del /s /q "C:\Windows\Temp\*" >nul 2>&1

:: Limpeza de usuarios Locais
echo Limpeza de usuarios.....
for %%u in (
    "*aluno*"
    "*professor*"
) do (
    powershell -NoProfile -Command "Get-CimInstance -ClassName Win32_UserProfile | Where-Object { $_.LocalPath -like %%u } | Remove-CimInstance"
)

:: Limpeza da lixeira
echo Esvaziando lixeira.....
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

echo.
echo.
echo PROCESSO CONCLUIDO
echo ----------------------------------------------------
echo.
echo A estacao sera reiniciada automaticamente em 30 segundos
echo.

shutdown /r /t 30 /c "Manutencao TI concluida - reiniciando para aplicar atualizacoes."