@ECHO OFF
set actual_dir=%cd%

set sb_service_path="C:\SB Service\"
set sb_service="SmartBambooApiService"
set sb_api="sb_api_service.py"

set sf_systems="C:\SF Systems\"

POWERSHELL -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
choco feature enable -n=allowGlobalConfirmation

choco install python
choco install nssm
choco install 7zip.portable

py -m pip install fastapi uvicorn python-multipart


if not exist %sf_systems% (
    mkdir %sf_systems%
    7z x RelaySinPantallas.zip -o%sf_systems%
)

if (Get-Service %sb_service% -ErrorAction SilentlyContinue) {
  $running=Get-Service %sb_service%
  if ($running.Status -eq "Running") {
    nssm stop %sb_service%
    nssm remove %sb_service% confirm
  }
}

if not exist %sb_service_path% (
    mkdir %sb_service_path%
    copy "%actual_dir%\%sb_api%" "%sb_service_path%"
) else (
    del "%sb_service_path%\%sb_api%"
    copy "%actual_dir%\%sb_api%" "%sb_service_path%"
)

nssm install %sb_service% "py" %sb_service_path%\%sb_api%"
nssm start "%sb_service%"


PAUSE