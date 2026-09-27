#!/bin/bash
# Instala y activa el servidor SSH, agrega tu llave pública y (opcional)
# desactiva el acceso por contraseña. Funciona en Ubuntu/Debian/Mint,
# Fedora, Arch/Manjaro y openSUSE.
#
# Uso:
#   bash configurar-ssh.sh                       # solo instala y activa SSH
#   bash configurar-ssh.sh "ssh-ed25519 AAAA..."  # además agrega tu llave
#   bash configurar-ssh.sh "ssh-ed25519 AAAA..." --solo-llaves
#       ...y además desactiva el login por contraseña
set -e

LLAVE="$1"
SOLO_LLAVES="$2"

echo "==> Instalando servidor SSH"
if command -v apt-get >/dev/null; then
  sudo apt-get update -qq && sudo apt-get install -y -qq openssh-server
elif command -v dnf >/dev/null; then
  sudo dnf install -y -q openssh-server
elif command -v pacman >/dev/null; then
  sudo pacman -S --needed --noconfirm openssh
elif command -v zypper >/dev/null; then
  sudo zypper --non-interactive install openssh-server
else
  echo "!! No reconozco el gestor de paquetes; instala openssh-server a mano."
  exit 1
fi

# Debian/Ubuntu llaman al servicio "ssh"; el resto, "sshd".
if systemctl list-unit-files ssh.service | grep -q "^ssh\.service"; then
  SERVICIO=ssh
else
  SERVICIO=sshd
fi

echo "==> Activando el servicio $SERVICIO (también al reiniciar)"
sudo systemctl enable --now "$SERVICIO"

echo "==> Abriendo el puerto SSH en el firewall (si hay uno activo)"
if command -v ufw >/dev/null && sudo ufw status | grep -q "Status: active"; then
  sudo ufw allow OpenSSH
elif command -v firewall-cmd >/dev/null && sudo firewall-cmd --state >/dev/null 2>&1; then
  sudo firewall-cmd --permanent --add-service=ssh && sudo firewall-cmd --reload
else
  echo "    No hay firewall activo; nada que hacer."
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
  echo "==> Desactivando login por contraseña"
  AJUSTES="PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no"
  if grep -qE "^Include /etc/ssh/sshd_config.d/" /etc/ssh/sshd_config; then
    # Va primero en orden alfabético para ganarle a otros archivos
    # (p. ej. 50-cloud-init.conf de Ubuntu), porque en sshd gana el primer valor.
    ARCHIVO=/etc/ssh/sshd_config.d/00-solo-llaves.conf
    echo "$AJUSTES" | sudo tee "$ARCHIVO" > /dev/null
  else
    ARCHIVO=/etc/ssh/sshd_config
    sudo cp "$ARCHIVO" "$ARCHIVO.respaldo"
    for opcion in PasswordAuthentication KbdInteractiveAuthentication ChallengeResponseAuthentication PermitRootLogin; do
      sudo sed -i "/^#*[[:space:]]*$opcion[[:space:]]/d" "$ARCHIVO"
    done
    printf '\n%s\n' "$AJUSTES" | sudo tee -a "$ARCHIVO" > /dev/null
  fi
  if ! sudo sshd -t; then
    echo "!! La configuración quedó inválida; deshaciendo el cambio."
    if [ "$ARCHIVO" = /etc/ssh/sshd_config ]; then
      sudo cp "$ARCHIVO.respaldo" "$ARCHIVO"
    else
      sudo rm -f "$ARCHIVO"
    fi
    exit 1
  fi
  sudo systemctl reload "$SERVICIO"
  echo "    Listo: solo se puede entrar con llave. (Cambio en $ARCHIVO)"
fi

echo
echo "==> Para conectarte desde otra computadora de tu red:"
for ip in $(hostname -I 2>/dev/null || true); do
  case "$ip" in *:*) continue ;; esac
  echo "    ssh $(whoami)@$ip"
done
