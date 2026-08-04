#!/usr/bin/env bash
set -euo pipefail

jq '.devDependencies["@astrojs/ts-plugin"] = "*"' package.json > package.json.tmp
mv package.json.tmp package.json
