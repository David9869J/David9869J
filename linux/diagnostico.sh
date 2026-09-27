#!/bin/bash
# Muestra el estado de la laptop: distro, hardware, disco, memoria, batería, red y SSH.
# Uso: bash diagnostico.sh

echo "=== Sistema ==="
. /etc/os-release 2>/dev/null && echo "Distro: $PRETTY_NAME"
echo "Kernel: $(uname -r)"
echo "Equipo: $(cat /sys/class/dmi/id/sys_vendor 2>/dev/null) $(cat /sys/class/dmi/id/product_name 2>/dev/null)"

echo
echo "=== Procesador ==="
lscpu | grep -E "^Model name|^CPU\(s\):" | sed 's/  */ /g'

echo
echo "=== Memoria ==="
free -h | head -2

echo
echo "=== Disco ==="
df -h / | tail -1 | awk '{print "Raíz: usado "$3" de "$2" ("$5"), libre "$4}'
lsblk -d -n -o NAME,SIZE,ROTA,MODEL | grep -vE "^(loop|zram|sr)" \
  | while read -r nombre tam rota modelo; do
      [ "$rota" = 0 ] && tipo=SSD || tipo=HDD
      echo "$nombre: $tam $tipo $modelo"
    done

echo
echo "=== Batería ==="
encontrada=no
for bat in /sys/class/power_supply/BAT*; do
  [ -d "$bat" ] || continue
  encontrada=si
  echo "$(basename "$bat"): $(cat "$bat/capacity")% ($(cat "$bat/status"))"
  if [ -r "$bat/energy_full" ] && [ -r "$bat/energy_full_design" ]; then
    echo "Salud: $(( $(cat "$bat/energy_full") * 100 / $(cat "$bat/energy_full_design") ))% de la capacidad original"
  fi
  [ -r "$bat/cycle_count" ] && echo "Ciclos: $(cat "$bat/cycle_count")"
done
[ "$encontrada" = no ] && echo "No se detectó batería"

echo
echo "=== Red ==="
if command -v ip >/dev/null; then
  ip -4 -brief addr show | grep -v "^lo "
else
  echo "IPs: $(hostname -I)"
fi
echo "Nombre del equipo: $(hostname)"

echo
echo "=== SSH ==="
if systemctl list-unit-files ssh.service sshd.service 2>/dev/null | grep -qE "^sshd?\.service"; then
  for s in ssh sshd; do
    systemctl is-active --quiet "$s" 2>/dev/null && echo "Servidor SSH: activo ($s)"
  done
  systemctl is-active --quiet ssh 2>/dev/null || systemctl is-active --quiet sshd 2>/dev/null \
    || echo "Servidor SSH: instalado pero apagado"
else
  echo "Servidor SSH: no instalado"
fi
if [ -s "$HOME/.ssh/authorized_keys" ]; then
  echo "Llaves autorizadas: $(grep -cE '^(ssh-|ecdsa-)' "$HOME/.ssh/authorized_keys")"
else
  echo "Llaves autorizadas: ninguna"
fi
