#!/bin/bash
# Activa SSH en la Mac, agrega tu llave pública y (opcional) desactiva el
# acceso por contraseña. Pensado para macOS 10.12–10.15 (bash 3.2).
#
# Uso:
#   bash configurar-ssh.sh                      # solo activa SSH
#   bash configurar-ssh.sh "ssh-ed25519 AAAA..." # activa SSH y agrega la llave
#   bash configurar-ssh.sh "ssh-ed25519 AAAA..." --solo-llaves
#       ...y además desactiva el login por contraseña
set -e

LLAVE="$1"
SOLO_LLAVES="$2"
SSHD_CONFIG=/etc/ssh/sshd_config

echo "==> Activando Sesión remota (SSH)"
if ! sudo systemsetup -setremotelogin on 2>/dev/null; then
  sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
fi

if [ -n "$LLAVE" ]; then
  echo "==> Agregando llave pública a ~/.ssh/authorized_keys"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  touch "$HOME/.ssh/authorized_keys"
  if grep -qF "$LLAVE" "$HOME/.ssh/authorized_keys"; then
    echo "    La llave ya estaba agregada."
  else
    echo "$LLAVE" >> "$HOME/.ssh/authorized_keys"
  fi
  chmod 600 "$HOME/.ssh/authorized_keys"
fi

if [ "$SOLO_LLAVES" = "--solo-llaves" ]; then
  if [ ! -s "$HOME/.ssh/authorized_keys" ]; then
    echo "!! No hay llaves autorizadas; no desactivo la contraseña para no dejarte fuera."
    exit 1
  fi
  echo "==> Desactivando login por contraseña (respaldo en $SSHD_CONFIG.respaldo)"
  sudo cp "$SSHD_CONFIG" "$SSHD_CONFIG.respaldo"
  for opcion in PasswordAuthentication ChallengeResponseAuthentication PermitRootLogin; do
    sudo sed -i '' "/^#*[[:space:]]*$opcion[[:space:]]/d" "$SSHD_CONFIG"
  done
  printf '\nPasswordAuthentication no\nChallengeResponseAuthentication no\nPermitRootLogin no\n' \
    | sudo tee -a "$SSHD_CONFIG" > /dev/null
  if ! sudo /usr/sbin/sshd -t; then
    echo "!! La configuración quedó inválida; restaurando el respaldo."
    sudo cp "$SSHD_CONFIG.respaldo" "$SSHD_CONFIG"
    exit 1
  fi
  echo "    Listo. Las conexiones nuevas ya usan solo llaves."
fi

echo
echo "==> Para conectarte desde otra computadora de tu red:"
USUARIO=$(whoami)
for iface in en0 en1; do
  ip=$(ipconfig getifaddr "$iface" 2>/dev/null || true)
  [ -n "$ip" ] && echo "    ssh $USUARIO@$ip"
done
echo "    ssh $USUARIO@$(scutil --get LocalHostName).local"
