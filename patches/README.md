# Patches

A set of scripts applied on top of the upstream Astro template right after it
is reset to the `UPSTREAM_SHA`. Each file is applied as a separate commit, in
**name order** (`00_`, `01_`, …), so the numbering matters.

Supported formats: `.sh` (executed) and `.patch` / `.diff` (applied via
`git apply`). Any other file (including this `README.md`) is ignored.

## Patch list

| № | File | What it does |
|---|------|--------------|
| 00 | `00_create-dirs.sh` | Creates `src/layouts` and `src/styles` |
| 01 | `01_add-ts-plugin.sh` | Adds `@astrojs/ts-plugin` to `devDependencies` |
| 02 | `02_tsconfig.sh` | Sets up `tsconfig.json`: plugin, TypeScript flags, `@/*` alias |
| 03 | `03_create-env-dts.sh` | Creates `src/env.d.ts` |
| 04 | `04_check-build.sh` | Changes `build` to `astro check && astro build` |
| 05 | `05_extract-layout.sh` | Moves the page markup into a shared layout |
| 06 | *(planned)* | Docker image (Dockerfile + `.dockerignore`) |

## 00 — `create-dirs.sh`

Creates `src/layouts/.gitkeep` and `src/styles/.gitkeep`, so the folders exist
in the repository before real files land there.

Reference: <https://docs.astro.build/en/basics/project-structure/>

## 01 — `add-ts-plugin.sh`

Adds the dependency used for editor highlighting/typing to `package.json`:

Reference: <https://docs.astro.build/en/guides/typescript/#typescript-editor-plugin>

```json
{
  "devDependencies": {
    "@astrojs/ts-plugin": "*"
  }
}
```

The version is not pinned (`*`); the current one is resolved at
`npm/pnpm install` time.

## 02 — `tsconfig.sh`

Extends `tsconfig.json`:
- `compilerOptions.plugins`: `@astrojs/ts-plugin`;
- `verbatimModuleSyntax: true` — strict type-import handling;
- `baseUrl: "."` and `paths: { "@/*": ["./src/*"] }` — the `@/` import alias.

References:
- <https://docs.astro.build/en/guides/typescript/#type-imports>
- <https://docs.astro.build/en/guides/typescript/#import-aliases>
- <https://ui.shadcn.com/docs/installation/astro#edit-tsconfigjson-file>

## 03 — `create-env-dts.sh`

Creates `src/env.d.ts`:

```ts
/// <reference path="../.astro/types.d.ts" />
```

Reference: <https://docs.astro.build/en/guides/typescript/#extending-global-types>

## 04 — `check-build.sh`

Changes the build script to type-check before building:

Reference: <https://docs.astro.build/en/guides/typescript/#type-checking>

```json
"build": "astro check && astro build"
```

## 05 — `extract-layout.sh`

Moves the page skeleton into a reusable layout:
1. Extracts the `<body>` content from `src/pages/index.astro` and remembers it;
2. Moves the file: `mv src/pages/index.astro src/layouts/base-layout.astro`;
3. In the layout, replaces all `<body>` content with a single `<slot />`;
4. Creates a new `src/pages/index.astro` that imports the layout via the `@/`
   alias and wraps the previous page content in it:

```astro
---
import BaseLayout from "@/layouts/base-layout.astro";
---

<BaseLayout>
	<!-- previous <body> content -->
</BaseLayout>
```

The content is taken from the actual file, not hardcoded, so the patch survives
upstream changes.

## 06 — *(planned)* Docker

Future patch: `06_add-docker.sh`, adding a `Dockerfile` and a `.dockerignore`
to the template root. Not implemented yet, documented only.

Reference: <https://pnpm.io/docker>

**`.dockerignore`:**

```gitignore
node_modules
.git
.gitignore
*.md
dist
```

**`Dockerfile`** (multi-stage pnpm build):

```dockerfile
FROM node:24-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME/bin:$PATH"
RUN corepack enable
COPY . /app
WORKDIR /app

FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

FROM base
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist
EXPOSE 8000
CMD [ "pnpm", "start" ]
```
