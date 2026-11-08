# Matemódulos · Servidor de ejercicios de matemáticas

Plataforma web **modular** para practicar matemáticas: cada usuario inicia
sesión, elige un módulo y resuelve ejercicios con corrección automática. Los
administradores pueden crear temas y ejercicios desde la propia web.

Stack 100 % gratuito para empezar:

- **Next.js 15** (App Router, Server Actions, TypeScript)
- **Supabase** (PostgreSQL + autenticación con correo y contraseña)
- **Vercel** o **Netlify** (hosting)
- **KaTeX** para renderizar fórmulas LaTeX
- **Tailwind CSS** para los estilos

---

## Funcionalidades

- Registro e inicio de sesión con correo y contraseña.
- Roles de **estudiante** y **administrador**.
- Módulos (temas) publicados o en borrador.
- Ejercicios de **opción múltiple** y **respuesta numérica** con tolerancia.
- Corrección en el servidor: el navegador nunca recibe la respuesta correcta
  antes de responder.
- Progreso por usuario: ejercicios resueltos, puntaje, nota y precisión.
- Panel de administración para crear/editar módulos y agregar/eliminar
  ejercicios.
- **Puntaje por intento**: acierto al 1.er intento = 1,0; 2.º = 0,8; 3.er
  = 0,5; 4.º o más = 0. Cada ejercicio se cierra al acertar o al agotar los 4
  intentos.
- **Grupos de estudiantes**: asigna módulos a un grupo y limita su visibilidad
  únicamente a los miembros del grupo.
- **Exportación de notas** de un grupo en CSV compatible con Excel (nota de 0 a
  10, puntaje y porcentaje).
- **Límites de tiempo** opcionales por módulo y por pregunta, controlados en el
  servidor.
- Fórmulas matemáticas con sintaxis LaTeX: `$x^2 + 1$` o `$$...$$`.
- Seguridad con **Row Level Security (RLS)** en PostgreSQL.

---

## Requisitos

- [Node.js 20 LTS o superior](https://nodejs.org/) (incluye npm).
- Una cuenta gratuita en [Supabase](https://supabase.com/).
- Una cuenta gratuita en [Vercel](https://vercel.com/) para publicar.
- Git (opcional, para desplegar desde GitHub).

---

## Puesta en marcha local

### 1. Crear el proyecto en Supabase

1. Entra en [supabase.com](https://supabase.com/) y crea un proyecto nuevo
   (elige la región más cercana y guarda la contraseña de la base de datos).
2. Espera a que termine la provisión.

### 2. Crear las tablas

1. En el panel de Supabase abre **SQL Editor → New query**.
2. Copia y ejecuta el contenido de [`supabase/schema.sql`](supabase/schema.sql).
3. Opcionalmente, ejecuta [`supabase/seed.sql`](supabase/seed.sql) para cargar
   el módulo de ejemplo **Álgebra básica** con 4 ejercicios.
4. Opcionalmente, ejecuta
   [`supabase/seed-factorizacion.sql`](supabase/seed-factorizacion.sql) para
   cargar el módulo **Factorización** con 14 ejercicios y variantes por
   estudiante.

> **Si ya tenías la base de datos creada** antes de las variantes por
> estudiante, ejecuta una vez
> [`supabase/migration-student-variants.sql`](supabase/migration-student-variants.sql)
> antes del seed de factorización.
>
> **Si tu base de datos ya existía antes de los grupos y los tiempos**, ejecuta
> una vez
> [`supabase/migration-groups-timing.sql`](supabase/migration-groups-timing.sql).
> Ese archivo agrega grupos, correos, sesiones de tiempo y las políticas de
> acceso. No borra datos existentes.
>
> **Visibilidad estricta por grupos (obligatorio):** ejecuta también
> [`supabase/migration-module-visibility.sql`](supabase/migration-module-visibility.sql).
> A partir de ese cambio, un módulo que no esté asignado a ningún grupo no lo ve
> ningún estudiante.

### 3. Obtener las claves

En **Project Settings → API** copia:

- `Project URL`
- `anon public key`

> **Importante:** usa solo la clave `anon` en el frontend. Nunca publiques la
> clave `service_role`.

### 4. Configurar las variables de entorno

Crea un archivo `.env.local` en la raíz del proyecto (junto a `package.json`):

```bash
cp .env.example .env.local
```

En Windows (PowerShell) puedes crearlo manualmente y pegar:

```env
NEXT_PUBLIC_SUPABASE_URL=https://tu-proyecto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=tu-clave-anonima-publica
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

`NEXT_PUBLIC_SITE_URL` es opcional, pero ayuda a construir el enlace de
confirmación de correo.

### 5. Instalar y ejecutar

```bash
npm install
npm run dev
```

Abre <http://localhost:3000>.

### 6. Crear el primer administrador

1. Regístrate en la web con tu correo.
2. En Supabase ve a **SQL Editor** y ejecuta (cambiando el correo):

```sql
update public.profiles
set role = 'admin'
where id = (
  select id from auth.users where email = 'tu@correo.com'
);
```

3. Cierra sesión y vuelve a entrar. Verás el enlace **Administración** en la
   cabecera.

### 7. Configurar la autenticación (correo)

En Supabase: **Authentication → URL Configuration**.

Desarrollo local:

- **Site URL:** `http://localhost:3000`
- **Redirect URLs:** `http://localhost:3000/auth/callback`

Producción (cuando tengas el dominio de Vercel):

- **Site URL:** `https://tu-app.vercel.app`
- **Redirect URLs:** `https://tu-app.vercel.app/auth/callback`

Por defecto Supabase pide confirmar el correo. Para probar rápido en local
puedes desactivarlo en **Authentication → Providers → Email → Confirm email**.
En producción es recomendable dejarlo activado.

---

## Desplegar gratis en Vercel

1. Sube el proyecto a un repositorio de GitHub:

```bash
git init
git add .
git commit -m "Servidor de ejercicios de matemáticas"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/TU-REPO.git
git push -u origin main
```

2. Entra en [vercel.com](https://vercel.com/), pulsa **Add New → Project** e
   importa el repositorio.
3. En **Environment Variables** agrega:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `NEXT_PUBLIC_SITE_URL` (por ejemplo `https://tu-app.vercel.app`)
4. Pulsa **Deploy**.
5. Copia el dominio de Vercel y actualiza en Supabase:
   - **Site URL** y **Redirect URLs** (incluyendo `/auth/callback`).
6. Vuelve a desplegar si cambiaste variables de entorno.

### Alternativa: desplegar en Netlify

El repositorio ya incluye `netlify.toml` y `.nvmrc`, así que Netlify detecta
Next.js y usa Node 22 automáticamente.

1. Sube el proyecto a GitHub siguiendo los pasos anteriores.
2. Entra en [netlify.com](https://www.netlify.com/) y accede con GitHub.
3. Pulsa **Add new site → Import an existing project**.
4. Elige **GitHub**, autoriza a Netlify y selecciona el repositorio.
5. Comprueba la configuración de build:
   - **Branch to deploy:** `main`
   - **Build command:** `npm run build`
   - **Publish directory:** `.next`
6. En **Environment variables** agrega:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `NEXT_PUBLIC_SITE_URL` con tu URL de Netlify, por ejemplo
     `https://tu-sitio.netlify.app`
7. Pulsa **Deploy site**.
8. En Supabase actualiza **Authentication → URL Configuration**:
   - **Site URL:** `https://tu-sitio.netlify.app`
   - **Redirect URLs:** agrega
     `https://tu-sitio.netlify.app/auth/callback`
9. Si agregaste las variables después del primer deploy, ve a
   **Deploys → Trigger deploy → Clear cache and deploy site**.

> Netlify aplica automáticamente su runtime de Next.js. Si por alguna razón no
> lo detecta, instala el plugin **Next.js Runtime** desde
> **Plugins → Add plugins**.

### Límites gratuitos (referencia)

- **Vercel Hobby:** suficiente para proyectos personales y educativos.
- **Netlify Free:** 100 GB de tráfico y 300 minutos de build al mes,
  aproximadamente. Incluye HTTPS y dominio `*.netlify.app`.
- **Supabase Free:** base de datos de 500 MB, autenticación y API incluidas.
  Los proyectos gratuitos se **pausan tras una semana sin actividad**; se
  reactivan desde el panel de Supabase.
- Los límites pueden cambiar. Revisa siempre las páginas oficiales de precios.

Alternativas si algún día superas los límites gratuitos: Neon (PostgreSQL),
Render, Fly.io o Cloudflare Pages/Workers.

---

## Cómo usar el panel de administración

1. Inicia sesión con un usuario administrador.
2. Ve a **Administración → Nuevo módulo**.
3. Completa título, descripción, orden y deja marcado **Publicado**.
4. Guarda. Serás redirigido a la página del módulo.
5. En **Agregar ejercicio**:
   - **Opción múltiple:** escribe una opción por línea y el número de la opción
     correcta (la primera es 1).
   - **Respuesta numérica:** escribe la respuesta correcta y una tolerancia
     (por defecto `0.000001`).
   - Usa `$...$` para fórmulas: `Resuelve $2x + 5 = 13$`.
   - La explicación se muestra al acertar.
6. Los estudiantes verán el módulo en **Mis módulos** en cuanto esté publicado.
7. Para despublicar un tema, edita el módulo y desmarca **Publicado**.

---

## Variantes de ejercicios por estudiante

En el formulario de un módulo puedes activar **Variantes por estudiante** y
definir cuántos **Ejercicios por estudiante** verá cada alumno:

- `0` = todos los ejercicios del módulo.
- Un número mayor que `0` = se seleccionan al azar esa cantidad del banco.
- Si el módulo tiene más ejercicios que el límite, cada estudiante recibe una
  combinación distinta.
- La combinación es **estable**: el mismo estudiante ve siempre los mismos
  ejercicios y en el mismo orden, aunque cierre sesión o cambie de dispositivo.
- El progreso y el porcentaje de completado se calculan solo sobre los
  ejercicios asignados a ese estudiante.

La selección se genera de forma determinista a partir del ID del usuario y del
módulo, sin necesidad de tablas adicionales. Si editas el banco de ejercicios o
cambias la cantidad por estudiante, las combinaciones pueden cambiar.

El módulo **Factorización** viene configurado con 14 ejercicios y 6 por
estudiante. Puedes ajustar esos valores desde **Administración → Factorización**.

---

## Grupos y exportación de notas

En **Administración → Grupos** puedes crear grupos (por ejemplo, `3.º A`) y:

1. **Agregar estudiantes** ya registrados en la plataforma.
2. **Asignar módulos** marcando las casillas correspondientes.
3. **Descargar las notas** del grupo con los botones **Planilla de notas (CSV)**
   o **Detalle por módulo (CSV)**.

### Visibilidad de los módulos

- Un módulo **solo es visible** para los estudiantes que pertenecen a algún grupo
  al que el módulo esté asignado.
- Un módulo **sin grupos asignados** no lo ve ningún estudiante (el
  administrador sí lo ve desde el panel).
- Un estudiante puede pertenecer a varios grupos. Verá la unión de los módulos
  asignados a todos ellos.

### Formato de la exportación

Los archivos `.csv` se abren directamente en Excel (usan punto y coma como
separador y UTF-8 con BOM para conservar tildes y eñes). Hay dos opciones:

- **Planilla de notas:** una fila por estudiante y columnas de nota y porcentaje
  para cada módulo, más el promedio.
- **Detalle por módulo:** una fila por estudiante y módulo con ejercicios
  asignados, resueltos, puntos obtenidos, puntaje máximo, nota y porcentaje.

La nota va de **0 a 10** y se calcula sobre la selección personalizada de
ejercicios de cada estudiante, igual que en el panel del alumno. La nota depende
del número de intento en que se acierta (ver la sección de puntaje).

### Puntaje por intento

Cada ejercicio vale un máximo de 1 punto:

| Acierto en | Puntos |
| ---------- | ------ |
| 1.er intento | 1,0 |
| 2.º intento | 0,8 |
| 3.er intento | 0,5 |
| 4.º intento o más | 0 |

Un ejercicio nunca acertado vale 0. Al acertar, o al llegar al cuarto intento,
el ejercicio **queda cerrado** y el servidor rechaza cualquier respuesta
posterior. La nota del módulo es `puntos obtenidos / ejercicios asignados × 10`
y la misma fórmula se usa en la exportación del grupo.

---

## Límites de tiempo

En el formulario de cada módulo puedes definir dos límites independientes:

- **Tiempo máximo del módulo (minutos):** el reloj empieza la primera vez que el
  estudiante abre el módulo y no se reinicia al recargar la página.
- **Tiempo máximo por pregunta (segundos):** cada pregunta empieza a contar
  cuando se muestra y se cierra al agotarse el tiempo.

Deja el campo vacío para no aplicar ese límite. Si un módulo tiene cualquier
límite activo, el estudiante lo recorre **una pregunta a la vez** con
contadores visibles.

La validación se hace en el servidor: una respuesta enviada después del plazo se
rechaza y la pregunta se registra como **tiempo agotado** (intento incorrecto).
El contador del navegador es solo informativo; no se puede burlar recargando la
página.

Para **reiniciar el tiempo** de un estudiante en un módulo, un administrador
puede borrar su fila en `module_sessions` desde el SQL Editor:

```sql
delete from public.module_sessions
where user_id = (
  select id from auth.users where email = 'estudiante@correo.com'
)
and module_id = (
  select id from public.modules where slug = 'factorizacion'
);
```

---

## Módulo de Factorización

El archivo [`supabase/seed-factorizacion.sql`](supabase/seed-factorizacion.sql)
crea el tema **Factorización** con ejercicios de:

- Factor común.
- Diferencia de cuadrados.
- Trinomios cuadrados perfectos.
- Trinomios de la forma `x² + bx + c`.
- Suma y diferencia de cubos.
- Factorización por agrupación.

Incluye 12 ejercicios de opción múltiple y 2 numéricos. Los estudiantes reciben
6 ejercicios distintos cada uno.

---

## Estructura del proyecto

```text
math-server/
├─ supabase/
│  ├─ schema.sql          # Tablas, roles, RLS y triggers
│  ├─ seed.sql            # Módulo de ejemplo Álgebra básica
│  ├─ seed-factorizacion.sql  # Módulo Factorización con variantes
│  ├─ migration-student-variants.sql  # Columnas para variantes
│  ├─ migration-groups-timing.sql     # Grupos, notas y tiempos
│  └─ migration-module-visibility.sql # Visibilidad estricta por grupos
├─ src/
│  ├─ app/
│  │  ├─ (auth)/          # Login, registro y Server Actions de sesión
│  │  ├─ admin/           # Panel de administración
│  │  ├─ auth/callback/   # Confirmación de correo de Supabase
│  │  ├─ dashboard/       # Panel del estudiante
│  │  ├─ modules/         # Módulos y corrección de ejercicios
│  │  ├─ layout.tsx
│  │  └─ page.tsx         # Landing pública
│  ├─ components/         # Header, tarjetas de ejercicio, formularios
│  ├─ lib/                # Cliente Supabase, tipos, utilidades y selección
│  └─ middleware.ts       # Refresco de sesión y rutas protegidas
├─ .env.example
├─ netlify.toml           # Configuración de despliegue en Netlify
├─ .nvmrc                 # Versión de Node para Netlify
├─ package.json
└─ README.md
```

### Modelo de datos

| Tabla               | Descripción                                                    |
| ------------------- | -------------------------------------------------------------- |
| `profiles`          | Nombre, correo y rol (`student` / `admin`) de cada usuario.    |
| `modules`           | Temas, variantes y límites de tiempo.                          |
| `exercises`         | Ejercicios de un módulo, con su respuesta correcta.            |
| `attempts`          | Intentos de cada usuario (orden y base del puntaje y las notas). |
| `groups`            | Grupos de estudiantes.                                         |
| `group_members`     | Estudiantes que pertenecen a cada grupo.                       |
| `group_modules`     | Módulos asignados a cada grupo (controlan la visibilidad).     |
| `module_sessions`   | Reloj del módulo por estudiante (inicio y vencimiento).        |
| `question_sessions` | Reloj de cada pregunta y cierre por tiempo agotado.            |

La respuesta correcta vive solo en la base de datos. La corrección se hace en
un **Server Action** (`src/app/modules/actions.ts`), nunca en el navegador.

---

## Seguridad

- RLS activado en todas las tablas.
- Los estudiantes solo pueden leer los módulos publicados y asignados a algún
  grupo al que pertenezcan, y sus propios intentos.
- Un módulo sin grupos asignados no es visible para ningún estudiante.
- Los módulos asignados a un grupo solo son visibles para sus miembros.
- Solo los administradores pueden crear, editar o borrar contenido, grupos y
  asignaciones.
- Un trigger impide que un estudiante se cambie el rol a `admin`.
- No se expone la clave `service_role`.
- Los enlaces de redirección se validan para evitar *open redirects*.

---

## Solución de problemas

| Problema | Solución |
| --- | --- |
| `Faltan NEXT_PUBLIC_SUPABASE_URL...` | Crea `.env.local` con las dos variables y reinicia `npm run dev`. |
| `relation "public.profiles" does not exist` | Ejecuta `supabase/schema.sql` en el SQL Editor. |
| `new row violates row-level security policy` | El usuario no es admin o el módulo no está publicado. Revisa el rol. |
| No veo módulos en el panel | Verifica que estén marcados como **Publicados**. |
| El correo de confirmación lleva a localhost | Actualiza **Site URL** y **Redirect URLs** en Supabase. |
| Se repite el login o hay un bucle | Revisa que las variables de entorno sean correctas y borra las cookies. |
| Las fórmulas se ven como texto | Usa `$...$` alrededor de la expresión LaTeX. |

---

## Próximos pasos sugeridos

- Editar ejercicios existentes (hoy se pueden eliminar y volver a crear).
- Importación masiva de estudiantes y ejercicios desde CSV/JSON.
- Recuperación de contraseña.
- Exportación real `.xlsx` con varias hojas (hoy se entrega CSV compatible).
- Ranking o reportes históricos por grupo.
- Pistas opcionales antes de mostrar la explicación.
- Tests automáticos y CI con GitHub Actions.

---

Hecho para aprender y enseñar matemáticas. Si mejoras el proyecto, ¡comparte los
cambios!
