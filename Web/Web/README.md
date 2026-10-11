# web-vue

SPA application built with Vue.js and Bootstrap for Vue.

## Prerequisites

You must add file ```.env.local``` based on ```.env-example``` .

## Project setup
```
npm ci --legacy-peer-deps
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Lints and fixes files
```
npm run lint
```

The supplied Vue 2 / Webpack 4 application uses Dart Sass in place of
the old native node-sass dependency. On Node 24, run the following in
PowerShell before `npm run serve` or `npm run build`:

```powershell
$env:NODE_OPTIONS='--openssl-legacy-provider'
```

Use package-lock.json as the active dependency lock. The original yarn.lock
is retained as supplied; it does not describe the updated Sass dependency.
