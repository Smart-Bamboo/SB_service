@ECHO OFF
@setlocal enableextensions
@cd /d "%~dp0"

set actual_dir=%cd%
set currentpath=%cd%


set sb_service_path="C:\SB_Service\"
set sb_service=SmartBambooApiService
set sb_api=sb_api_service.py

set sf_systems="C:\SF Systems\"

ECHO Installing choco ...

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" >NUL
SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin" >NUL
choco feature enable -n allowGlobalConfirmation >NUL
choco upgrade chocolatey >NUL
:: choco upgrade all

ECHO Installing python ...
choco install python --pre >NUL

ECHO Installing nssm ...
choco install nssm >NUL

ECHO Installing 7zip ...
choco install 7zip.portable >NUL

ECHO Installing python dependencies ...
python -m pip install --upgrade pip >NUL
python -m pip install fastapi uvicorn python-multipart "sentry-sdk[fastapi]" >NUL

ECHO Checking if RelaySinPantallas service exists ...
powershell Get-Service uPayService -ErrorAction SilentlyContinue >NUL
if exist %sf_systems% (
    ECHO Remove RelaySinPantallas previous installation ...
    nssm stop uPayService >NUL
    nssm remove uPayService confirm >NUL
)

ECHO Checking if RelaySinPantallas folder exists ...
if exist %sf_systems% (
    ECHO Remove RelaySinPantallas folder ...
    rd /s /q %sf_systems% >NUL
)

ECHO Copying RelaySinPantallas folder ...
mkdir %sf_systems% >NUL
7z x RelaySinPantallas.zip -o%sf_systems% >NUL

ECHO Installing RelaySinPantallas service ...
nssm install uPayService Application "C:\SF Systems\RelaySinPantallas\uPayService.exe" >NUL

ECHO Checking if SmartBambooApiService exists ...
powershell Get-Service %sb_service% -ErrorAction SilentlyContinue >NUL
if %errorlevel% == 0 (
    ECHO Removing SmartBambooApiService ...
    nssm stop %sb_service% >NUL
    nssm remove %sb_service% confirm >NUL
)

ECHO Checking if SB_Service folder exists ...
if exist "C:\SB_Service\" (
    ECHO Removing SB_Service folder ...
    rd /s /q "C:\SB_Service\" >NUL
)

ECHO Creating SB_Service folder ...
mkdir "C:\SB_Service\" >NUL
mkdir "C:\SB_Service\logs" >NUL
copy %actual_dir%\service.log "C:\SB_Service\logs\service.log" >NUL
copy %actual_dir%\service_error.log "C:\SB_Service\logs\service_error.log" >NUL

ECHO Copying SB_Service folder ...
copy "%actual_dir%\%sb_api%" "C:\SB_Service\" >NUL

ECHO Installing SmartBambooApiService  ...
nssm install %sb_service% "python" "C:\SB_Service\sb_api_service.py" >NUL
nssm set  %sb_service% AppStdout "C:\SB_Service\logs\service.log" >NUL
nssm set  %sb_service% AppStderr "C:\SB_Service\logs\service_error.log" >NUL
nssm start %sb_service% >NUL

ECHO Checking SmartBambooApiService status ...
FOR /F %%A IN ('nssm status SmartBambooApiService') DO SET service_status=%%A

IF "%service_status%"=="SERVICE_RUNNING" (
    ECHO SmartBambooApiService is running correctly
    PAUSE
) ELSE (
    ECHO SmartBambooApiService is not running
    PAUSE
    EXIT /B 1
)
