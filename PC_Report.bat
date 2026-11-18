@echo off
setlocal EnableExtensions
set "report=%USERPROFILE%\Desktop\PC_Report.txt"
title Rapport Systeme

rem ============================================================
rem  EN-TETE DU RAPPORT
rem ============================================================
> "%report%" echo  ############################################################
>> "%report%" echo  #            RAPPORT SYSTEME - MON PC                      #
>> "%report%" echo  #            %date%  -  %time:~0,8%               #
>> "%report%" echo  ############################################################

call :section "1. SYSTEME D'EXPLOITATION ET RAM"
powershell -NoProfile -Command "Get-CimInstance Win32_OperatingSystem | ForEach-Object { 'Nom du systeme : ' + $_.Caption + ' (' + $_.OSArchitecture + ')'; 'Version        : ' + $_.Version; 'Build          : ' + $_.BuildNumber; 'Utilisateur    : ' + $env:USERNAME; 'PC             : ' + $env:COMPUTERNAME; 'RAM totale     : ' + [math]::Round($_.TotalVisibleMemorySize/1MB,1) + ' Go'; 'RAM libre      : ' + [math]::Round($_.FreePhysicalMemory/1MB,1) + ' Go' }" >> "%report%" 2>&1

call :section "2. PROCESSEUR - CPU"
powershell -NoProfile -Command "Get-CimInstance Win32_Processor | ForEach-Object { 'Modele    : ' + $_.Name.Trim(); 'Coeurs    : ' + $_.NumberOfCores; 'Threads   : ' + $_.NumberOfLogicalProcessors; 'Frequence : ' + [math]::Round($_.MaxClockSpeed/1000,2) + ' GHz'; 'Cache L3  : ' + [math]::Round($_.L3CacheSize/1024,0) + ' Mo' }" >> "%report%" 2>&1

call :section "3. CARTE GRAPHIQUE - GPU ET VRAM"
powershell -NoProfile -Command "Get-CimInstance Win32_VideoController | ForEach-Object { 'Carte      : ' + $_.Name; 'Pilote     : ' + $_.DriverVersion; 'Resolution : ' + $_.CurrentHorizontalResolution + ' x ' + $_.CurrentVerticalResolution; '---' }" >> "%report%" 2>&1
>> "%report%" echo   VRAM reelle - lecture du registre, exacte meme au-dela de 4 Go :
powershell -NoProfile -Command "Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*' -ErrorAction SilentlyContinue | Where-Object 'HardwareInformation.qwMemorySize' | ForEach-Object { $_.DriverDesc + '  -  VRAM : ' + [math]::Round($_.'HardwareInformation.qwMemorySize'/1GB,1) + ' Go' }" >> "%report%" 2>&1
where nvidia-smi >nul 2>&1 && (
  >> "%report%" echo   Utilisation GPU NVIDIA en direct - nvidia-smi :
  nvidia-smi --query-gpu=name,memory.total,memory.used,memory.free,utilization.gpu --format=csv >> "%report%" 2>&1
)

call :section "4. MEMOIRE RAM - BARETTES"
powershell -NoProfile -Command "Get-CimInstance Win32_PhysicalMemory | ForEach-Object { 'Barrette    : ' + [math]::Round($_.Capacity/1GB,0) + ' Go'; 'Fabricant   : ' + $_.Manufacturer; 'Frequence   : ' + $_.ConfiguredClockSpeed + ' MHz'; 'Emplacement : ' + $_.DeviceLocator; '---' }" >> "%report%" 2>&1

call :section "5. DISQUES PHYSIQUES"
powershell -NoProfile -Command "Get-PhysicalDisk | ForEach-Object { 'Disque    : ' + $_.FriendlyName; 'Type      : ' + $_.MediaType; 'Bus       : ' + $_.BusType; 'Capacite  : ' + [math]::Round($_.Size/1GB,0) + ' Go'; 'Sante     : ' + $_.HealthStatus; '---' }" >> "%report%" 2>&1

call :section "6. PARTITIONS - C:, D:, ..."
powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { $_.DeviceID + '  Total : ' + [math]::Round($_.Size/1GB,0).ToString().PadLeft(5) + ' Go   Libre : ' + [math]::Round($_.FreeSpace/1GB,0).ToString().PadLeft(5) + ' Go' }" >> "%report%" 2>&1

call :section "7. CARTE MERE ET BIOS"
powershell -NoProfile -Command "Get-CimInstance Win32_BaseBoard | ForEach-Object { 'Carte mere : ' + $_.Manufacturer + ' ' + $_.Product }; Get-CimInstance Win32_BIOS | ForEach-Object { 'BIOS       : ' + $_.Manufacturer + ' ' + $_.SMBIOSBIOSVersion; 'Date BIOS  : ' + $_.ReleaseDate }" >> "%report%" 2>&1

call :section "8. RESEAU"
powershell -NoProfile -Command "Get-CimInstance Win32_NetworkAdapter -Filter 'PhysicalAdapter=True' | ForEach-Object { 'Carte reseau : ' + $_.Name; 'Active       : ' + $_.NetEnabled; '---' }" >> "%report%" 2>&1

call :section "9. PILOTES INSTALLES - RESUME"
driverquery /fo table >> "%report%" 2>&1

echo.
echo  Rapport genere avec succes :
echo    %report%
start "" notepad "%report%"
pause
exit /b

rem ============================================================
rem  SOUS-ROUTINE : banniere de section - SANS bloc parenthese
rem ============================================================
:section
>> "%report%" echo.
>> "%report%" echo ==============================================================
>> "%report%" echo   %~1
>> "%report%" echo ==============================================================
>> "%report%" echo.
exit /b
