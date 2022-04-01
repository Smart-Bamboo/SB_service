@ECHO OFF
set actual_dir=%cd%

set sb_service_path="C:\SB Service\"
set sb_service=SmartBambooApiService
set sb_api=sb_api_service.py

set sf_systems="C:\SF Systems\"

powershell choco -v
if not %errorlevel% == 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
    choco feature enable -n=allowGlobalConfirmation
)

choco install python
choco install nssm
choco install 7zip.portable

py -m pip install fastapi uvicorn python-multipart >NUL


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

if not exist %sb_service_path% (
    mkdir %sb_service_path% >NUL
    copy %actual_dir%\%sb_api% %sb_service_path% >NUL
) else (
    del %sb_service_path%\%sb_api% >NUL
    copy %actual_dir%\%sb_api% %sb_service_path% >NUL
)

nssm install %sb_service% "py" %sb_service_path%\%sb_api%
nssm start %sb_service% >NUL


PAUSE