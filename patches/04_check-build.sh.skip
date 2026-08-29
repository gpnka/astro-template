#!/usr/bin/env bash
set -euo pipefail

jq '.scripts.build = "astro check && astro build"' package.json > package.json.tmp
mv package.json.tmp package.json
