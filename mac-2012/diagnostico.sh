#!/bin/bash
# Muestra el estado de la Mac: modelo, macOS, disco, memoria, batería y SSH.
# Uso: bash diagnostico.sh

echo "=== Equipo ==="
system_profiler SPHardwareDataType | grep -E "Model Name|Model Identifier|Processor Name|Memory|Serial Number" | sed 's/^ *//'

echo
echo "=== macOS ==="
sw_vers

echo
echo "=== Disco ==="
df -h / | tail -1 | awk '{print "Usado: "$3" de "$2" ("$5"), libre: "$4}'
diskutil info / | grep -E "Solid State|Media Name" | sed 's/^ *//'

echo
echo "=== Memoria (uso actual) ==="
vm_stat | awk '/Pages free/ {f=$3} /Pages active/ {a=$3} END {printf "Libre: %.0f MB, activa: %.0f MB\n", f*4096/1048576, a*4096/1048576}'

echo
echo "=== Batería ==="
pmset -g batt | tail -n +2
system_profiler SPPowerDataType | grep -E "Cycle Count|Condition" | sed 's/^ *//'

echo
echo "=== Red ==="
for iface in en0 en1; do
  ip=$(ipconfig getifaddr "$iface" 2>/dev/null)
  [ -n "$ip" ] && echo "$iface: $ip"
done
echo "Nombre en la red: $(scutil --get LocalHostName 2>/dev/null).local"

echo
echo "=== SSH ==="
sudo systemsetup -getremotelogin 2>/dev/null || echo "(ejecuta con sudo para ver el estado de SSH)"
if [ -s "$HOME/.ssh/authorized_keys" ]; then
  echo "Llaves autorizadas: $(grep -cE '^(ssh-|ecdsa-)' "$HOME/.ssh/authorized_keys")"
else
  echo "Llaves autorizadas: ninguna"
fi
