<h1 align="center">Jose David Alvarado Muñoz</h1>

<p align="center">
  <strong>Ingeniero de Sistemas</strong> · Desarrollo de software a medida<br>
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

Mi trabajo actual es un **ERP inmobiliario completo**, en producción, que lleva la venta
de terrenos de punta a punta: del primer contacto con el cliente hasta el comprobante
electrónico aceptado por SUNAT.

<br>

## En qué estoy trabajando

**ERP para Inmobiliaria Rodval E.I.R.L.** — repositorio privado

Un sistema en producción que cubre el ciclo completo de una venta inmobiliaria:
catálogo de lotes, contratos con su cronograma de cuotas, cobranza, conciliación de
vouchers bancarios y facturación electrónica.

<table>
<tr><td width="50%" valign="top">

**Facturación electrónica SUNAT**

Emisión de boletas y notas de crédito con XML **UBL 2.1**, firmado digitalmente con
certificado PKCS#12. Validación previa contra el catálogo oficial de códigos, porque
cada rechazo de SUNAT consume un correlativo que no se recupera.

</td><td width="50%" valign="top">

**Integridad financiera**

Registro de auditoría **inmutable y encadenado con SHA-256**: cada entrada incluye el
hash de la anterior, así que alterar o borrar una rompe la cadena de todas las
siguientes y queda a la vista.

</td></tr>
<tr><td width="50%" valign="top">

**Concurrencia crítica**

Bloqueo pesimista (`SELECT … FOR UPDATE NOWAIT`) para que dos asesores no puedan
reservar el mismo lote a la vez. En una feria inmobiliaria eso no es teoría: es una
venta duplicada del mismo terreno.

</td><td width="50%" valign="top">

**Seguridad por capas**

Row Level Security estricto en PostgreSQL, permisos configurables desde el panel,
credenciales cifradas con AES-256-GCM y almacenamiento perimetral con URLs
prefirmadas de vida corta.

</td></tr>
<tr><td width="50%" valign="top">

**Lectura automática de vouchers**

OCR sobre la foto del comprobante bancario para extraer monto, banco y número de
operación, con aviso cuando el depósito no fue a una cuenta oficial de la empresa.

</td><td width="50%" valign="top">

**Portal del cliente**

PWA instalable donde el comprador consulta su cronograma y envía sus pagos, con
notificaciones push y contraseña de un solo uso en la primera entrada.

</td></tr>
</table>

<br>

## Stack

| | |
|---|---|
| **Lenguaje** | TypeScript en modo estricto |
| **Frontend** | Next.js (App Router, Server Components y Server Actions), React, Tailwind CSS, Framer Motion |
| **Backend** | PostgreSQL con PL/pgSQL, Supabase, Row Level Security |
| **Infraestructura** | Vercel, Cloudflare R2 (S3 API), almacenamiento con retención inmutable |
| **Integraciones** | SUNAT (SOAP/UBL 2.1, firma XML-DSig), WhatsApp Cloud API, pasarelas de consulta por DNI |

<br>

## Cómo trabajo

**El código explica el porqué, no el qué.** Lo que hace una función se lee en la función.
Lo que no se lee es por qué está escrita de esa forma y no de la evidente — y eso es
justo lo que alguien va a necesitar dentro de seis meses para no romperla.

**La base de datos es la última línea de defensa.** Una validación en el formulario es
una cortesía para el usuario. La que impide de verdad una venta duplicada o un pago
aplicado dos veces es la restricción en PostgreSQL, porque esa no se puede saltar
llamando a la API directamente.

**Nada se borra si es financiero.** Un comprobante puede haber generado una boleta que
ya existe ante SUNAT; borrar la fila no la retira de allí, solo deja el hecho sin
explicación. Se anula, se compensa y queda registrado quién, cuándo y por qué.

**Un error silencioso es peor que una caída.** Prefiero que algo falle fuerte y temprano
a que devuelva un resultado incompleto que nadie note hasta el cierre de mes.

<br>

## Contacto

<a href="mailto:josedavid132j@gmail.com">
  <img src="https://img.shields.io/badge/Correo-josedavid132j@gmail.com-EA4335?style=flat-square&logo=gmail&logoColor=white" alt="Correo">
</a>

📍 La Libertad, Perú

<br>

<sub>La mayor parte de mi trabajo está en repositorios privados de clientes. Si necesitas ver código o quieres conversar sobre un proyecto, escríbeme.</sub>
