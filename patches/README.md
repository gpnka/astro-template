https://docs.astro.build/en/basics/project-structure/

Create `src/layouts/.gitkeep`

Create `src/styles/.gitkeep`

https://docs.astro.build/en/guides/typescript/#typescript-editor-plugin

run `pnpm add @astrojs/ts-plugin`

Then, add the following to your tsconfig.json:

```tsconfig.json
{
  "compilerOptions": {
    "plugins": [
      {
        "name": "@astrojs/ts-plugin"
      },
    ],
  }
}
```

https://docs.astro.build/en/guides/typescript/#type-imports

```tsconfig.json
{
  "compilerOptions": {
    "verbatimModuleSyntax": true
  }
}
```

https://docs.astro.build/en/guides/typescript/#import-aliases

Take alieses from https://ui.shadcn.com/docs/installation/astro#edit-tsconfigjson-file

```tsconfig.json
{
  "compilerOptions": {
    // ...
    "baseUrl": ".",
    "paths": {
      "@/*": [
        "./src/*"
      ]
    }
    // ...
  }
}
```

https://docs.astro.build/en/guides/typescript/#extending-global-types

create `src/env.d.ts`

put there /// <reference path="../.astro/types.d.ts" />

https://docs.astro.build/en/guides/typescript/#type-checking

```package.json
{
  "scripts": {
-    "build": "astro build",
+    "build": "astro check && astro build",
  },
}
```