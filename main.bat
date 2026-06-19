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

start "" "%~dp0information.bat"

:: ===== Verificando Winget =====
where winget >nul 2>&1 || (
    echo Erro: Winget nao encontrado, favor verificar se ele esta instalado na estacao.
    pause
    exit /b
)

:: ===== Instalando softwares padrao =====
echo.
echo [1] Instalacao de Softwares
echo ----------------------------------------------------
echo.

for %%p in (
    RARLab.WinRAR
    7zip.7zip
    Adobe.Acrobat.Reader.64-bit
    Microsoft.WindowsTerminal
    Notepad++.Notepad++
    Google.Chrome
    Microsoft.Teams
    Zoom.Zoom
    Microsoft.VisualStudioCode
    JetBrains.IntelliJIDEA
    Git.Git
    OpenJS.NodeJS
    Python.Python.3
    EclipseAdoptium.Temurin.21.JDK
    Insomnia.Insomnia
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

winget upgrade --all --force --include-unknown

:: ===== Limpeza e otimizacao =====
echo.
echo.
echo [3] Limpeza e otimizacao
echo ----------------------------------------------------
echo.

:: Desativando a hibernacao
powercfg -h off

:: Garantindo plano de energia equilibrado
powercfg /setactive SCHEME_BALANCED

:: Limpeza de temporarios
echo Limpando temporarios.....
del /s /q "%temp%\*" >nul 2>&1
del /s /q "C:\Windows\Temp\*" >nul 2>&1

:: Limpeza de arquivos do usuario
echo Limpeza de arquivos do usuario.....
if exist "%userprofile%\Downloads\"  del /s /q "%userprofile%\Downloads\*" >nul 2>&1
if exist "%userprofile%\Documents\"  del /s /q "%userprofile%\Documents\*" >nul 2>&1
if exist "%userprofile%\Pictures\"   del /s /q "%userprofile%\Pictures\*"  >nul 2>&1
if exist "%userprofile%\Videos\"     del /s /q "%userprofile%\Videos\*"    >nul 2>&1
if exist "%userprofile%\Music\"      del /s /q "%userprofile%\Music\*"     >nul 2>&1

:: Limpeza da lixeira
echo Esvaziando lixeira.....
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

:: ===== Saude e integridade =====
echo.
echo.
echo [4] Saude e integridade
echo ----------------------------------------------------
echo.

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

echo.
echo.
echo PROCESSO CONCLUIDO
echo ----------------------------------------------------
echo.
echo IMPORTANTE: Reinicie a estacao para concluir o chkdsk
echo e aplicar o reset das configuracoes de rede.
echo.
pause