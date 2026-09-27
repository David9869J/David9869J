# Configuración de la laptop Linux por SSH

Scripts para revisar el estado de la laptop y dejarla accesible por SSH.
Funcionan en Ubuntu, Debian, Linux Mint, Fedora, Arch/Manjaro y openSUSE.

## 1. Ver cómo está la laptop

En la laptop, abre una **Terminal** y ejecuta:

```bash
curl -fsSLO https://raw.githubusercontent.com/David9869J/David9869J/claude/ssh-laptop-config-81mevq/linux/diagnostico.sh
bash diagnostico.sh
```

Muestra distro, procesador, memoria, discos (SSD/HDD), batería (carga y
salud), IP y si SSH está activo.

> Si no tienes `curl`: `sudo apt install curl` (Ubuntu/Debian/Mint) o
> `sudo dnf install curl` (Fedora).

## 2. Instalar y activar SSH

```bash
curl -fsSLO https://raw.githubusercontent.com/David9869J/David9869J/claude/ssh-laptop-config-81mevq/linux/configurar-ssh.sh
bash configurar-ssh.sh
```

Instala `openssh-server`, lo deja encendido también al reiniciar, abre el
puerto en el firewall si hay uno activo (`ufw` o `firewalld`) y al final
imprime el comando para conectarte, por ejemplo `ssh david@192.168.1.30`.

## 3. Entrar con llave en vez de contraseña (recomendado)

En **la computadora desde la que te vas a conectar**, si aún no tienes llave:

```bash
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub
```

Copia la línea que empieza con `ssh-ed25519` y en la laptop ejecuta:

```bash
bash configurar-ssh.sh "ssh-ed25519 AAAA...tu-llave..."
```

Prueba que entras sin contraseña. **Solo cuando funcione**, desactiva el
acceso por contraseña:

```bash
bash configurar-ssh.sh "ssh-ed25519 AAAA...tu-llave..." --solo-llaves
```

El script valida la configuración con `sshd -t` antes de aplicarla, deshace
el cambio si algo sale mal y se niega a desactivar la contraseña si no hay
ninguna llave autorizada.

## Notas

- Para que la laptop no se suspenda al cerrar la tapa mientras la usas por
  SSH, en `/etc/systemd/logind.conf` pon `HandleLidSwitch=ignore` y ejecuta
  `sudo systemctl restart systemd-logind`.
- Para entrar desde fuera de tu casa, lo más sencillo y seguro es
  [Tailscale](https://tailscale.com); no abras el puerto 22 en el router.
