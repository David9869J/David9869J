# Instala y activa el servidor OpenSSH de Windows, agrega tu llave publica y
# (opcional) desactiva el acceso por contrasena. Requiere PowerShell como administrador.
#
# Uso (PowerShell como administrador):
#   $s = irm https://raw.githubusercontent.com/David9869J/David9869J/claude/ssh-laptop-config-81mevq/windows/configurar-ssh.ps1
#   & ([scriptblock]::Create($s))                                     # solo activa SSH
#   & ([scriptblock]::Create($s)) -Llave "ssh-ed25519 AAAA..."         # ademas agrega tu llave
#   & ([scriptblock]::Create($s)) -Llave "ssh-ed25519 AAAA..." -SoloLlaves
param(
    [string]$Llave,
    [switch]$SoloLlaves
)
$ErrorActionPreference = "Stop"

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "!! Abre PowerShell como administrador (clic derecho > Ejecutar como administrador) y vuelve a intentarlo." -ForegroundColor Red
    return
}

$config = "$env:ProgramData\ssh\sshd_config"

Write-Host "==> Instalando servidor OpenSSH (puede tardar unos minutos)" -ForegroundColor Cyan
$cap = Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*"
if ($cap.State -ne "Installed") {
    Add-WindowsCapability -Online -Name $cap.Name | Out-Null
} else {
    Write-Host "    Ya estaba instalado."
}

Write-Host "==> Activando el servicio (tambien al reiniciar)" -ForegroundColor Cyan
Set-Service sshd -StartupType Automatic
Start-Service sshd

Write-Host "==> Abriendo el puerto 22 en el firewall" -ForegroundColor Cyan
if (-not (Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName "OpenSSH Server (sshd)" `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
} else {
    Enable-NetFirewallRule -Name "OpenSSH-Server-In-TCP"
}

Write-Host "==> Usando PowerShell como consola al entrar por SSH" -ForegroundColor Cyan
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -PropertyType String -Force `
    -Value "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" | Out-Null

# Como este script corre como administrador, el usuario es administrador y
# Windows solo lee sus llaves de administrators_authorized_keys.
$llaves = "$env:ProgramData\ssh\administrators_authorized_keys"

if ($Llave) {
    Write-Host "==> Agregando llave publica" -ForegroundColor Cyan
    $existentes = if (Test-Path $llaves) { Get-Content $llaves } else { @() }
    if ($existentes -contains $Llave.Trim()) {
        Write-Host "    La llave ya estaba agregada."
    } else {
        Add-Content -Path $llaves -Value $Llave.Trim() -Encoding Ascii
    }
    # Solo Administradores y SYSTEM pueden leerlo; si no, sshd lo ignora.
    icacls $llaves /inheritance:r /grant "*S-1-5-32-544:F" /grant "*S-1-5-18:F" | Out-Null
}

if ($SoloLlaves) {
    if (-not (Test-Path $llaves) -or -not (Get-Content $llaves)) {
        Write-Host "!! No hay llaves autorizadas; no desactivo la contrasena para no dejarte fuera." -ForegroundColor Red
        return
    }
    Write-Host "==> Desactivando login por contrasena (respaldo en sshd_config.respaldo)" -ForegroundColor Cyan
    Copy-Item $config "$config.respaldo" -Force
    $lineas = Get-Content $config | Where-Object { $_ -notmatch '^\s*#?\s*PasswordAuthentication\s' }
    # Debe ir antes de cualquier bloque "Match", por eso va al inicio.
    Set-Content -Path $config -Value (@("PasswordAuthentication no") + $lineas) -Encoding Ascii
    & "$env:WINDIR\System32\OpenSSH\sshd.exe" -t
    if ($LASTEXITCODE -ne 0) {
        Write-Host "!! La configuracion quedo invalida; restaurando el respaldo." -ForegroundColor Red
        Copy-Item "$config.respaldo" $config -Force
        return
    }
    Restart-Service sshd
    Write-Host "    Listo: solo se puede entrar con llave."
}

Write-Host "`n==> Para conectarte desde otra computadora de tu red:" -ForegroundColor Green
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" -and $_.InterfaceAlias -notlike "vEthernet*" } |
    ForEach-Object { Write-Host "    ssh $env:USERNAME@$($_.IPAddress)" }
Write-Host "    La contrasena es la de tu cuenta de Windows (no el PIN)."
if (Get-NetConnectionProfile | Where-Object NetworkCategory -eq "Public") {
    Write-Host "!! Tu red esta como 'Publica'. Si no puedes conectarte, cambiala a 'Privada' en" -ForegroundColor Yellow
    Write-Host "   Configuracion > Red e Internet > (tu Wi-Fi) > Tipo de perfil de red." -ForegroundColor Yellow
}
