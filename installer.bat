@ECHO OFF
set actual_dir=%cd%

ECHO Verificando sistema
POWERSHELL -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
choco feature enable -n=allowGlobalConfirmation

ECHO Instalando requeriminentos
choco install python
choco install nssm

py -m pip install fastapi uvicorn python-multipart

nssm stop "SmartBambooApiService"
nssm remove "SmartBambooApiService" confirm
nssm install "SmartBambooApiService" "py" "%actual_dir%\sb_api_service.py"
nssm start "SmartBambooApiService"

PAUSE