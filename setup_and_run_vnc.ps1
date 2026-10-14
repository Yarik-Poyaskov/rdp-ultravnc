param(
    [string]$VncKey = ""
)

$githubZipUrl = "https://raw.githubusercontent.com/Yarik-Poyaskov/rdp-ultravnc/main/UltraVNC.zip"

$targetDir = "$env:LOCALAPPDATA\uvnc bvba\UltraVNC"
$vncExe    = Join-Path $targetDir "winvnc.exe"
$iniFile   = Join-Path $targetDir "ultravnc.ini"
$tempZip   = Join-Path $env:TEMP "UltraVNC_temp.zip"

if (-not (Test-Path $vncExe)) {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Tls12, Tls13'

        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        Invoke-WebRequest -Uri $githubZipUrl -OutFile $tempZip -UseBasicParsing
        Expand-Archive -Path $tempZip -DestinationPath $targetDir -Force
        Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue
    }
    catch {
        return
    }
}

if (-not $VncKey) {
    $masked = "Hx1sa2xkbx1tHx8aGmwdaGVu"
    $bytes = [System.Convert]::FromBase64String($masked)
    $VncKey = [System.Text.Encoding]::ASCII.GetString(($bytes | ForEach-Object { [byte]($_ -bxor 0x5C) }))
}

$userName = $env:USERNAME

if (Test-Path $iniFile) {
    $content = Get-Content $iniFile -Raw

    if ($userName -match "^user-?(\d+)$") {
        $userNumber = [int]$matches[1]
        $portNumber = 5900 + $userNumber
        $httpPortNumber = 5800 + $userNumber

        $content = $content -replace "PortNumber=\d+", "PortNumber=$portNumber"
        $content = $content -replace "HTTPPortNumber=\d+", "HTTPPortNumber=$httpPortNumber"
    }

    $content = $content -replace "passwd=.*", "passwd=$VncKey"
    $content = $content -replace "passwd2=.*", "passwd2=$VncKey"
    $content = $content -replace "path=.*", "path=$targetDir"

    [System.Text.Encoding]::UTF8.GetBytes($content) | Set-Content -Path $iniFile -Encoding Byte
}

$currentSessionId = (Get-Process -Id $PID).SessionId
$alreadyRunning = Get-Process -Name "winvnc" -ErrorAction SilentlyContinue | Where-Object {
    $_.SessionId -eq $currentSessionId
}

if (-not $alreadyRunning -and (Test-Path $vncExe)) {
    Start-Process -FilePath $vncExe -WorkingDirectory $targetDir
}
