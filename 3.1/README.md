# P3.1 — Configuración Entorno PWA + Primer Despliegue TV

Dashboard de clima en tiempo real para Smart TV (1920x1080), construido como PWA.

## Antes de correrlo: configurar la API key

Este proyecto usa la API de [OpenWeatherMap](https://openweathermap.org/api). Por seguridad, la API key **no está incluida en este repositorio** (ver `.gitignore`: `.env` y `js/env.js`).

Para correr el proyecto localmente:

1. Consigue una API key gratuita en https://openweathermap.org/api
2. Crea el archivo `js/env.js` en esta carpeta con el siguiente contenido:

   ```js
   // js/env.js — NUNCA subir a Git (ver .gitignore)
   window.ENV_API_KEY = 'tu_api_key_aqui';
   ```

3. (Opcional) Crea también `.env` en esta carpeta, por si algún script de build lo necesita:

   ```
   OPENWEATHER_API_KEY=tu_api_key_aqui
   OPENWEATHER_BASE_URL=https://api.openweathermap.org/data/2.5/weather
   ```

4. Sirve la carpeta con un servidor estático (Live Server de VS Code, `python -m http.server`, etc.) y abre `index.html`.

**Nunca** pongas la key directamente en `js/weather.js` ni en ningún otro archivo versionado — ese es exactamente el archivo que sí sube a GitHub.

## Estructura

```
3.1/
├── index.html
├── manifest.json
├── sw.js
├── css/styles.css
├── js/
│   ├── app.js          ← orquestación principal
│   ├── weather.js       ← llamadas a la API
│   ├── navigation.js    ← lógica D-pad
│   └── env.js            ← API key (crear localmente, NO versionado)
├── assets/
│   ├── videos/           ← fondos por condición climática
│   └── posters/          ← fallback estático
└── icons/
```

## Notas

- Los videos de fondo (`assets/videos/*.mp4`) son placeholders sintéticos generados con `ffmpeg` (gradientes animados), no metraje real. Se pueden reemplazar por clips de Pixabay/Pexels siguiendo el mismo formato (1920x1080, H.264, sin audio).
- El Service Worker (`sw.js`) usa estrategia **Cache First** para estáticos/videos y **Network First** para la API de clima.
