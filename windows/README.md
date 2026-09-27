# Configuración de la laptop Windows por SSH

Windows 10 (1809 o más nuevo) y Windows 11 traen un servidor SSH incluido.
Estos scripts lo activan sin instalar nada externo ni usar USB.

## 1. Ver cómo está la laptop

Abre **PowerShell** y pega:

```powershell
irm https://raw.githubusercontent.com/David9869J/David9869J/claude/ssh-laptop-config-81mevq/windows/diagnostico.ps1 | iex
```

## 2. Activar SSH

Abre **PowerShell como administrador** (clic derecho en el menú Inicio →
*Terminal (administrador)* o *Windows PowerShell (administrador)*) y pega:

```powershell
$s = irm https://raw.githubusercontent.com/David9869J/David9869J/claude/ssh-laptop-config-81mevq/windows/configurar-ssh.ps1
& ([scriptblock]::Create($s))
```

Instala y enciende el servidor SSH, abre el puerto 22 en el firewall y al
final te muestra el comando para conectarte, por ejemplo `ssh HP@192.168.1.30`.
La contraseña es la de tu cuenta de Windows (no el PIN).

## 3. Entrar con llave en vez de contraseña (recomendado)

En la computadora desde la que te vas a conectar:

```bash
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub        # en Windows: type $HOME\.ssh\id_ed25519.pub
```

En la laptop (PowerShell como administrador, con `$s` ya cargado):

```powershell
& ([scriptblock]::Create($s)) -Llave "ssh-ed25519 AAAA...tu-llave..."
```

Prueba que entras sin contraseña. **Solo cuando funcione**:

```powershell
& ([scriptblock]::Create($s)) -Llave "ssh-ed25519 AAAA...tu-llave..." -SoloLlaves
```
