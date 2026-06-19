
@echo off
title Script Principal

:: Verificando nivel de permissão
net session >nul 2>&1
if %errorlevel% neq 0 (

    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

echo.
echo ==========================
echo   TERRYS - SCRIPT
echo ==========================
echo.


:: Verificando Winget
where winget >nul 2>&1 || (

    echo Erro: Winget não encontrado, favor verificar se ele esta instalado na estação.
    exit /b
)

:: Instalando softwares padrão
echo.
echo ----------------------------------------------------
echo [1] Instalacao de Softwares 
echo ----------------------------------------------------
echo.

for %%p in (
    RARLab.WinRAR
    Microsoft.WindowsTerminal
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
    Oracle.JDK.26
) do (

    winget install -e --id %%p --silent
)

:: Atualizando softwares
echo.
echo ----------------------------------------------------
echo [2] Atualizacao de Softwares
echo ----------------------------------------------------
echo.

winget upgrade --all --force --include-unknown

echo ----------------------------------------------------

:: Saúde e integridade
echo.
echo ----------------------------------------------------
echo [3] Saude e integridade
echo ----------------------------------------------------
echo.

:: Interidade do sistema
sfc /scannow

:: Saúde do sistema
DISM /Online /Cleanup-Image /ScanHealth

:: Disco
chkdsk

:: Internet 
ipconfig /flushdns
netsh winsock reset
netsh int ip reset

:: Politicas
gpupdate /force 

:: Saúde e integridade
echo.
echo ----------------------------------------------------
echo [4] Limpeza e otimizacao
echo ----------------------------------------------------
echo.

:: Desativando a hibernação
powercfg -h off

:: Limpeza de temporarios
del /s /q %temp%\*
del /s /q C:\Windows\Temp\*

:: Limpeza de arquivos do usuario
set /p confirm=Deseja realizar a limpeza das pastas de conteúdo do usuário? [y] || [n]

if %confirm%=="Y" || %confirm%=="y"(
    if exist "%userprofile%\Downloads\"  del /s /q "%userprofile%\Downloads\*" >nul 2>&1
    if exist "%userprofile%\Documents\"  del /s /q "%userprofile%\Documents\*" >nul 2>&1
    if exist "%userprofile%\Pictures\"   del /s /q "%userprofile%\Pictures\*"  >nul 2>&1
    if exist "%userprofile%\Videos\"     del /s /q "%userprofile%\Videos\*"    >nul 2>&1
    if exist "%userprofile%\Music\"      del /s /q "%userprofile%\Music\*"     >nul 2>&1
)

pause