@echo off
title Informacoes da estacao
setlocal enabledelayedexpansion
cls

echo ==========================================
echo           %COMPUTERNAME%
echo ==========================================
echo.

echo Usuario: %USERNAME%
echo Pasta do Usuario: %USERPROFILE%
echo.

echo ==========================================
echo SISTEMA OPERACIONAL
echo ==========================================
powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption + ' - Build ' + (Get-CimInstance Win32_OperatingSystem).BuildNumber"
echo.

echo ==========================================
echo TEMPO LIGADO (UPTIME)
echo ==========================================
powershell -NoProfile -Command "$up = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime; Write-Output ($up.Days.ToString() + ' dias, ' + $up.Hours.ToString() + ' horas, ' + $up.Minutes.ToString() + ' minutos')"
echo.

echo ==========================================
echo BIOS / PLACA-MAE
echo ==========================================
powershell -NoProfile -Command "$bios = Get-CimInstance Win32_BIOS; $board = Get-CimInstance Win32_BaseBoard; $fw = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\').PEFirmwareType; $modo = if ($fw -eq 2) { 'UEFI' } elseif ($fw -eq 1) { 'Legacy (BIOS)' } else { 'Desconhecido' }; Write-Output ('Fabricante BIOS: ' + $bios.Manufacturer); Write-Output ('Versao BIOS: ' + $bios.SMBIOSBIOSVersion); Write-Output ('Data: ' + $bios.ReleaseDate); Write-Output ('Serial: ' + $bios.SerialNumber); Write-Output ('Modo: ' + $modo); Write-Output ('Placa-mae: ' + $board.Manufacturer + ' ' + $board.Product)"
echo.

echo ==========================================
echo CPU
echo ==========================================
powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).Name"
echo.

echo ==========================================
echo GPU
echo ==========================================
powershell -NoProfile -Command "Get-CimInstance Win32_VideoController | ForEach-Object { $_.Name }"
echo.

echo ==========================================
echo MEMORIA
echo ==========================================
powershell -NoProfile -Command "$os = Get-CimInstance Win32_OperatingSystem; $freeGB = [math]::Round($os.FreePhysicalMemory/1MB,2); $totalGB = [math]::Round($os.TotalVisibleMemorySize/1MB,2); Write-Output ('Livre: ' + $freeGB + ' GB / Total: ' + $totalGB + ' GB')"
echo.

echo ==========================================
echo DISCO
echo ==========================================
powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object { $freeGB = [math]::Round($_.FreeSpace/1GB,2); $totalGB = [math]::Round($_.Size/1GB,2); Write-Output ($_.DeviceID + '  Livre: ' + $freeGB + ' GB / Total: ' + $totalGB + ' GB') }"
echo.

echo ==========================================
echo REDE (IPv4)
echo ==========================================
ipconfig | findstr "IPv4"
echo.

echo ==========================================
echo GATEWAY E DNS
echo ==========================================
powershell -NoProfile -Command "Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true } | ForEach-Object { Write-Output ('Adaptador: ' + $_.Description); Write-Output ('Gateway: ' + ($_.DefaultIPGateway -join ', ')); Write-Output ('DNS: ' + ($_.DNSServerSearchOrder -join ', ')); Write-Output '' }"
echo.