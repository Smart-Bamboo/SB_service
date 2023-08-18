@ECHO OFF
@setlocal enableextensions
@cd /d "%~dp0"

set actual_dir=%cd%
set currentpath=%cd%


set sb_service_path="C:\SB_Service\"
set sb_service=SmartBambooApiService
set sb_api=sb_api_service.py

set sf_systems="C:\SF Systems\"

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin" >NUL 2>&1
choco feature enable -n allowGlobalConfirmation >NUL
choco upgrade chocolatey >NUL
:: choco upgrade all

choco install python --pre >NUL
choco install nssm >NUL
choco install 7zip.portable >NUL

python -m pip install --upgrade pip >NUL
python -m pip install fastapi uvicorn python-multipart "sentry-sdk[fastapi]" >NUL

if not exist %sf_systems% (
    mkdir %sf_systems%
    7z x RelaySinPantallas.zip -o%sf_systems%
)
nssm install uPayService Application "C:\SF Systems\RelaySinPantallas\uPayService.exe"

powershell Get-Service %sb_service% -ErrorAction SilentlyContinue >NUL
if %errorlevel% == 0 (
  nssm stop %sb_service% >NUL
  nssm remove %sb_service% confirm >NUL
)

if not exist "C:\SB_Service\" (
    mkdir "C:\SB_Service\" >NUL
    mkdir "C:\SB_Service\logs" >NUL
    copy %actual_dir%\service.log "C:\SB_Service\logs\service.log"
    copy %actual_dir%\service_error.log "C:\SB_Service\logs\service_error.log"
) else (
    nssm stop %sb_service% >NUL
    nssm remove %sb_service% confirm >NUL
    del "C:\SB_Service\sb_api_service.py" >NUL
)

copy "%actual_dir%\%sb_api%" "C:\SB_Service\"

nssm install %sb_service% "python" "C:\SB_Service\sb_api_service.py"
nssm set  %sb_service% AppStdout "C:\SB_Service\logs\service.log"
nssm set  %sb_service% AppStderr "C:\SB_Service\logs\service_error.log"
nssm start %sb_service% >NUL

PAUSE
