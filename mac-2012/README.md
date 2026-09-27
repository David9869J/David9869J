# Configuración de la Mac 2012 por SSH

Scripts para revisar el estado de la Mac y dejarla accesible por SSH.
Funcionan en macOS Sierra a Catalina (10.12–10.15), las versiones que
soporta oficialmente una Mac de 2012.

## 1. Ver cómo está la Mac

En la Mac, abre **Terminal** y ejecuta:

```bash
curl -fsSLO https://raw.githubusercontent.com/David9869J/David9869J/claude/ssh-laptop-config-81mevq/mac-2012/diagnostico.sh
bash diagnostico.sh
```

Muestra modelo, versión de macOS, disco, memoria, batería (ciclos y
condición), IP en la red y si SSH está activo.

## 2. Activar SSH

```bash
curl -fsSLO https://raw.githubusercontent.com/David9869J/David9869J/claude/ssh-laptop-config-81mevq/mac-2012/configurar-ssh.sh
bash configurar-ssh.sh
```

Pide tu contraseña (por `sudo`) y al final imprime el comando para
conectarte, por ejemplo `ssh david@192.168.1.20`.

## 3. Entrar con llave en vez de contraseña (recomendado)

En **tu otra computadora**, si aún no tienes llave:

```bash
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub
```

Copia la línea que empieza con `ssh-ed25519` y en la Mac ejecuta:

```bash
bash configurar-ssh.sh "ssh-ed25519 AAAA...tu-llave..."
```

Prueba que entras sin contraseña. **Solo cuando funcione**, desactiva el
acceso por contraseña:

```bash
bash configurar-ssh.sh "ssh-ed25519 AAAA...tu-llave..." --solo-llaves
```

El script guarda un respaldo en `/etc/ssh/sshd_config.respaldo`, valida la
configuración antes de aplicarla y se niega a desactivar la contraseña si no
hay ninguna llave autorizada.

## Notas

- Para que la Mac no se duerma mientras la usas por SSH:
  `sudo pmset -a sleep 0` (y `sudo pmset -a sleep 10` para volver).
- Para entrar desde fuera de tu casa, lo más sencillo y seguro es
  [Tailscale](https://tailscale.com); no abras el puerto 22 en el router.
