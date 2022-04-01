@ECHO OFF
set actual_dir=%cd%

ECHO Verificando sistema
POWERSHELL -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
choco feature enable -n=allowGlobalConfirmation

ECHO Instalando requeriminentos
choco install python
choco install nssm
choco install 7zip.portable

py -m pip install fastapi uvicorn python-multipart

nssm stop "SmartBambooApiService"
nssm remove "SmartBambooApiService" confirm
nssm install "SmartBambooApiService" "py" "%actual_dir%\sb_api_service.py"
nssm start "SmartBambooApiService"

if not exist "C:\SF Systems2\" (
  mkdir "C:\SF Systems2\"
) 
@REM else (
@REM   rmdir /Q /S "C:\SF Systems\"
@REM   mkdir "C:\SF Systems\"
@REM )

7z e installer.zip -o"C:\SF Systems2"

PAUSE