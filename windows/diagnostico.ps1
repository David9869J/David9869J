# Muestra el estado de la laptop: Windows, equipo, memoria, discos, bateria, red y SSH.
# Uso (PowerShell):
#   irm https://raw.githubusercontent.com/David9869J/David9869J/claude/ssh-laptop-config-81mevq/windows/diagnostico.ps1 | iex

$os  = Get-CimInstance Win32_OperatingSystem
$cs  = Get-CimInstance Win32_ComputerSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

Write-Host "=== Sistema ===" -ForegroundColor Cyan
Write-Host "Windows: $($os.Caption) (build $($os.BuildNumber))"
Write-Host "Equipo:  $($cs.Manufacturer) $($cs.Model)"
Write-Host "CPU:     $($cpu.Name.Trim())"
Write-Host ("RAM:     {0:N1} GB total, {1:N1} GB libres" -f ($cs.TotalPhysicalMemory / 1GB), ($os.FreePhysicalMemory * 1KB / 1GB))

Write-Host "`n=== Discos ===" -ForegroundColor Cyan
try {
    Get-PhysicalDisk | ForEach-Object {
        Write-Host ("{0}: {1:N0} GB, {2}, salud: {3}" -f $_.FriendlyName, ($_.Size / 1GB), $_.MediaType, $_.HealthStatus)
    }
} catch { Write-Host "No se pudo leer la lista de discos" }
$c = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
Write-Host ("C: {0:N1} GB libres de {1:N1} GB" -f ($c.FreeSpace / 1GB), ($c.Size / 1GB))

Write-Host "`n=== Bateria ===" -ForegroundColor Cyan
$bat = Get-CimInstance Win32_Battery
if ($bat) {
    Write-Host "Carga: $($bat.EstimatedChargeRemaining)%"
    try {
        $actual  = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity
        $diseno  = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity
        if ($actual -and $diseno) { Write-Host ("Salud: {0:N0}% de la capacidad original" -f ($actual * 100 / $diseno)) }
    } catch { Write-Host "Salud: ejecuta como administrador para verla" }
} else {
    Write-Host "No se detecto bateria"
}

Write-Host "`n=== Red ===" -ForegroundColor Cyan
Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" -and $_.InterfaceAlias -notlike "vEthernet*" } |
    ForEach-Object { Write-Host "$($_.InterfaceAlias): $($_.IPAddress)" }
Get-NetConnectionProfile -ErrorAction SilentlyContinue | ForEach-Object {
    $tipo = if ($_.NetworkCategory -eq "Public") { "Publica (bloquea conexiones entrantes)" } else { "Privada" }
    Write-Host "Red '$($_.Name)': $tipo"
}
Write-Host "Nombre del equipo: $env:COMPUTERNAME"

Write-Host "`n=== SSH ===" -ForegroundColor Cyan
$sshd = Get-Service sshd -ErrorAction SilentlyContinue
if ($sshd) {
    Write-Host "Servidor SSH: $($sshd.Status) (inicio: $($sshd.StartType))"
} else {
    Write-Host "Servidor SSH: no instalado"
}
Write-Host "Usuario para SSH: $env:USERNAME"
