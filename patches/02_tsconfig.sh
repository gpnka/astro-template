#!/usr/bin/env bash
set -euo pipefail

jq '
  .compilerOptions.plugins = [{ "name": "@astrojs/ts-plugin" }] |
  .compilerOptions.verbatimModuleSyntax = true |
  .compilerOptions.baseUrl = "." |
  .compilerOptions.paths = { "@/*": ["./src/*"] }
' tsconfig.json > tsconfig.json.tmp
mv tsconfig.json.tmp tsconfig.json
