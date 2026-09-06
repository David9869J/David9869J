<h1 align="center">Jose David Alvarado Muñoz</h1>

<p align="center">
  <strong>Ingeniero de Sistemas</strong> · Software transaccional y financiero<br>
  <sub>La Libertad, Perú</sub>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/TypeScript-3178C6?style=flat-square&logo=typescript&logoColor=white" alt="TypeScript">
  <img src="https://img.shields.io/badge/Next.js-000000?style=flat-square&logo=nextdotjs&logoColor=white" alt="Next.js">
  <img src="https://img.shields.io/badge/React-087EA4?style=flat-square&logo=react&logoColor=white" alt="React">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=flat-square&logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Supabase-3FCF8E?style=flat-square&logo=supabase&logoColor=white" alt="Supabase">
  <img src="https://img.shields.io/badge/Cloudflare-F38020?style=flat-square&logo=cloudflare&logoColor=white" alt="Cloudflare">
</p>

---

Construyo sistemas que manejan dinero de otras personas. Eso condiciona cómo trabajo:
antes de escribir una función pienso en qué pasa cuando falla a la mitad, cuando dos
usuarios la ejecutan a la vez, y cuando dentro de seis meses alguien tenga que entender
por qué está escrita así.

Mi trabajo se concentra en **cobranza, conciliación bancaria y facturación electrónica**:
la parte del software donde un error no es un pixel mal puesto, sino un pago que se
aplica dos veces o un comprobante que la SUNAT rechaza.

<br>

## Conciliación bancaria

<p align="left">
  <img src="https://img.shields.io/badge/BCP-EA5B0C?style=for-the-badge&logoColor=white" alt="BCP">
  <img src="https://img.shields.io/badge/BBVA-004481?style=for-the-badge&logoColor=white" alt="BBVA">
  <img src="https://img.shields.io/badge/Interbank-00A94F?style=for-the-badge&logoColor=white" alt="Interbank">
  <img src="https://img.shields.io/badge/Scotiabank-EC111A?style=for-the-badge&logoColor=white" alt="Scotiabank">
  <img src="https://img.shields.io/badge/Yape-742284?style=for-the-badge&logoColor=white" alt="Yape">
  <img src="https://img.shields.io/badge/Plin-00BFA5?style=for-the-badge&logoColor=white" alt="Plin">
</p>

Sistemas que reciben el voucher de un depósito y lo convierten en un pago aplicado, sin
que nadie teclee el monto a mano:

- **Lectura automática del comprobante.** OCR sobre la foto del voucher para extraer
  monto, banco, número de operación y cuenta de destino.
- **Detección de depósitos a cuentas ajenas.** Si el dinero no llegó a una cuenta
  oficial, el sistema lo marca antes de que alguien lo dé por cobrado.
- **Aplicación en cascada.** Un pago que supera la cuota salda las siguientes en orden
  de vencimiento, hasta agotarse — nada de excedentes perdidos en un campo de texto.
- **Un voucher no se usa dos veces.** Huella SHA-256 del archivo, con restricción de
  unicidad en la base: el mismo comprobante no puede aplicarse a dos deudas distintas.

<br>

## Facturación electrónica ante SUNAT

Emisión de comprobantes electrónicos de punta a punta, sin intermediarios:

| | |
|---|---|
| **Formato** | XML **UBL 2.1**, validado contra el catálogo oficial de códigos antes de enviar |
| **Firma** | XML-DSig con certificado digital **PKCS#12**, con verificación de vigencia y de RUC |
| **Envío** | Servicio SOAP de SUNAT, con lectura de la constancia de recepción (CDR) |
| **Anulación** | Notas de crédito enlazadas al comprobante original |

Cada rechazo de SUNAT consume un correlativo que no se recupera, así que la validación
va **antes** del envío y no después del error.

<br>

## Integridad y concurrencia

<table>
<tr><td width="50%" valign="top">

**Auditoría encadenada**

Registro inmutable donde cada entrada incluye el hash **SHA-256** de la anterior.
Alterar o borrar una fila rompe la cadena de todas las siguientes y queda a la vista.
Ni siquiera la llave de servicio puede modificarlo.

</td><td width="50%" valign="top">

**Bloqueo pesimista**

`SELECT … FOR UPDATE NOWAIT` para que dos usuarios no puedan reservar el mismo activo
a la vez. En un pico de tráfico eso no es teoría: es la misma cosa vendida dos veces.

</td></tr>
<tr><td width="50%" valign="top">

**Nada financiero se borra**

Los registros contables no admiten `DELETE`, ni desde la aplicación ni desde la llave
de servicio. Se anulan con transacciones de compensación que dejan constancia de
quién, cuándo y por qué.

</td><td width="50%" valign="top">

**Seguridad por capas**

Row Level Security estricto en PostgreSQL, permisos configurables sin desplegar,
credenciales cifradas con **AES-256-GCM** y almacenamiento perimetral con URLs
prefirmadas de vida corta.

</td></tr>
</table>

<br>

## Stack

| Capa | Herramientas |
|---|---|
| **Lenguaje** | TypeScript en modo estricto |
| **Frontend** | Next.js (App Router, Server Components y Server Actions), React, Tailwind CSS, Framer Motion |
| **Backend** | PostgreSQL con PL/pgSQL, Supabase, Row Level Security |
| **Infraestructura** | Vercel, Cloudflare R2 (S3 API), almacenamiento con retención inmutable |
| **Integraciones** | SUNAT (SOAP · UBL 2.1 · XML-DSig), WhatsApp Cloud API, consulta por DNI, OCR |

<br>

## Cómo trabajo

**El código explica el porqué, no el qué.** Lo que hace una función se lee en la función.
Lo que no se lee es por qué está escrita de esa forma y no de la evidente — y eso es
justo lo que alguien va a necesitar dentro de seis meses para no romperla.

**La base de datos es la última línea de defensa.** Una validación en el formulario es
una cortesía para el usuario. La que impide de verdad un cobro duplicado es la
restricción en PostgreSQL, porque esa no se puede saltar llamando a la API directamente.

**Un error silencioso es peor que una caída.** Prefiero que algo falle fuerte y temprano
a que devuelva un resultado incompleto que nadie note hasta el cierre de mes.

<br>

## Contacto

<a href="mailto:josedavid132j@gmail.com">
  <img src="https://img.shields.io/badge/Correo-josedavid132j@gmail.com-EA4335?style=flat-square&logo=gmail&logoColor=white" alt="Correo">
</a>

📍 La Libertad, Perú

<br>

<sub>Trabajo bajo acuerdos de confidencialidad, así que el código vive en repositorios privados. Si necesitas ver ejemplos o conversar sobre un proyecto, escríbeme.</sub>
