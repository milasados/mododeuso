# mododeuso.com

Sitio auxiliar de MIL ASADOS. Es el destino del **código QR impreso en el packaging**.

La página que importa es **`/iniciador-premium/`**: video tutorial y pasos escritos del
Iniciador de Fuego. No vende nada. No tiene JavaScript, ni frameworks, ni dependencias
externas. Son archivos HTML sueltos, y esa es la idea: el QR ya está impreso en cajas que
no se pueden recuperar, así que esta página tiene que ser imposible de romper.

---

## ⚠️ Lo primero: las tres frases que no se tocan

Estas tres líneas están **palabra por palabra** iguales en cuatro lugares:

1. La etiqueta física de la caja
2. El grabado del producto
3. `milasados.com/seguridad/`
4. Este sitio, en el bloque "Antes de usar"

```
Usar únicamente alcohol etílico 96°.
NUNCA recargar en caliente, aunque parezca apagado.
Recargar solo cuando el cuerpo metálico agujereado —no el mango— pueda tocarse con la mano desnuda.
```

**Si cambiás una de estas frases, hay que cambiarla en los cuatro lugares.** Incluido el
`NUNCA` en mayúsculas. Una etiqueta que dice una cosa y una página que dice otra es un
problema legal, no un detalle de redacción.

---

## Cómo se publica

El sitio está conectado a Netlify. **Un `git push` a la rama principal lo publica solo**,
en unos 20 segundos. No hay que compilar ni construir nada.

```bash
git add .
git commit -m "Cambio lo que sea"
git push
```

Si algo sale mal, Netlify guarda todos los deploys anteriores y se puede volver atrás con
un click desde el panel.

---

## Cómo reemplazar el video

El archivo lleva `v1` en el nombre a propósito. Al subir un video nuevo se le pone `v2`,
`v3`, y así. Es la única forma de que el celular del cliente no siga mostrando el video
viejo durante días por el caché.

**Nunca reemplaces el archivo dejándole el mismo nombre.**

### Paso 1 — Comprimir el video nuevo

Necesitás `ffmpeg`. Pegá esto en la terminal, cambiando `mi-video-nuevo.mov` por tu archivo:

```bash
ffmpeg -i mi-video-nuevo.mov -an -c:v libx264 -profile:v main -level 4.0 -crf 28 -preset slow -pix_fmt yuv420p -movflags +faststart assets/video/tutorial-iniciador-premium-v2.mp4
```

Y el poster, que es la imagen que se ve antes de darle play (cambiá `00:00:25` por el
segundo del video que mejor se vea):

```bash
ffmpeg -ss 00:00:25 -i assets/video/tutorial-iniciador-premium-v2.mp4 -frames:v 1 -vf scale=810:1440 -c:v libwebp -quality 72 assets/video/tutorial-iniciador-premium-v2.webp
```

Después fijate cuánto pesó el `.mp4`:

- **Menos de 12 MB:** listo, seguí al paso 2.
- **Más de 12 MB:** repetí el comando subiendo el `-crf 28` a `-crf 30` o `-crf 32`.
  Cuanto más alto el número, más liviano y un poco menos nítido. **Subí el CRF antes de
  bajar la resolución.**

Dos cosas del comando que no hay que sacar:

- **`-movflags +faststart`** — sin esto, el iPhone descarga el video entero antes de
  mostrar el primer cuadro. Es el error clásico.
- **`-an`** — saca el audio. El video actual es mudo, así que el audio sólo sumaba peso.
  **Si tu video nuevo tiene voz en off, sacá el `-an` y agregá `-c:a aac -b:a 96k`.**

### Paso 2 — Poner los archivos en su lugar

Los dos archivos nuevos van en `assets/video/`. Dejá los viejos ahí por ahora; se borran
después, cuando confirmes que el nuevo anda.

### Paso 3 — Cambiar `v1` por `v2` en el HTML

Abrí `iniciador-premium/index.html` y buscá este comentario, que está justo arriba del
video:

```
<!-- ============================================================
     VIDEO TUTORIAL — PARA REEMPLAZARLO:
```

Debajo hay **dos rutas** que dicen `v1`. Cambiá las dos por `v2`:

```html
poster="/assets/video/tutorial-iniciador-premium-v1.webp"     ← esta
<source src="/assets/video/tutorial-iniciador-premium-v1.mp4" ← y esta
```

Si el video nuevo no es vertical, cambiá también el `width="1080" height="1920"` por las
medidas reales, y en el CSS la línea `aspect-ratio:1080 / 1920`. Si es vertical como el
actual, no toques nada de eso.

Guardá, `git push`, y listo.

---

## Cómo cambiar un texto

Todo el contenido está en `iniciador-premium/index.html`. No hay base de datos ni panel:
se edita el archivo directamente.

- **Los 6 pasos** están en el bloque `<ol class="steps">`. Cada paso es un `<li>` con el
  título en `<b>` y la descripción en `<p>`.
- **Las preguntas frecuentes** están más abajo, cada una en un `<details>`: el `<summary>`
  es la pregunta, el `<p>` es la respuesta.
- **El bloque de seguridad** está en `<div class="safety">`. Acordate de las tres frases
  que no se tocan.

### Si cambiás un paso, cambialo en dos lugares

Al final del archivo hay un bloque `<script type="application/ld+json">`. Es lo que lee
Google para mostrar los pasos en los resultados de búsqueda, y **repite los mismos seis
pasos**. Si cambiás el texto de un paso arriba, cambialo también ahí abajo. Si quedan
distintos, Google marca error.

### El orden de los pasos es una decisión de seguridad

El iniciador **se ubica y se carga en frío, y recién después se enciende**. Nunca se mueve
encendido. No reordenes los pasos ni los "mejores": ese orden coincide con
`milasados.com/seguridad/` y es lo que evita que alguien se queme.

---

## Qué hay en cada carpeta

```
index.html                   Portada mínima del dominio (noindex). Lista de productos.
iniciador-premium/
  index.html                 LA página. Todo el CSS va adentro del archivo, a propósito.
assets/
  video/                     Video tutorial + poster. Versionados (-v1, -v2...).
  img/                       Logo, favicons e imagen de preview para WhatsApp.
  fonts/                     Barlow Condensed 700 (licencia OFL, incluida).
  captions/                  Subtítulos, si algún día el video lleva voz.
netlify.toml                 Caché, redirects y cabeceras de seguridad.
robots.txt / sitemap.xml     Para Google.
```

---

## Reglas que conviene no romper

- **Cero JavaScript.** Las preguntas que se abren y cierran son HTML nativo
  (`<details>`), y el reproductor es el del navegador. Nada que pueda fallar.
- **Cero dependencias externas.** Ni Google Fonts, ni CDN, ni Analytics, ni Pixel. Todo lo
  que la página necesita está en este repo.
- **Nada de precios, botón de comprar ni promociones.** La persona ya compró. Está parada
  al lado de la parrilla con el teléfono en la mano. Todo lo que no la ayude a prender el
  fuego, sobra.
- **El video pesa menos de 12 MB.** Es el techo razonable para datos móviles en un fondo
  con mala señal.

---

## Antes de imprimir un QR nuevo

1. Que `mododeuso.com` resuelva y tenga HTTPS.
2. Probar `https://mododeuso.com/iniciador-premium/` **desde un celular con datos móviles,
   no con WiFi**.
3. Escanear el QR ya impreso y confirmar que cae donde tiene que caer.
