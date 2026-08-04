#!/usr/bin/env bash
set -euo pipefail

mkdir -p src
printf '/// <reference path="../.astro/types.d.ts" />\n' > src/env.d.ts
