#!/usr/bin/env bash
set -euo pipefail

# Grab the original <body> content (trimmed) before moving the file.
body_content="$(perl -0ne 'if (/<body>(.*?)<\/body>/s) { $c = $1; $c =~ s/^\s+|\s+$//g; print $c }' src/pages/index.astro)"

mkdir -p src/layouts
mv src/pages/index.astro src/layouts/base-layout.astro

# Replace everything between <body> and </body> with a single <slot />,
# keeping the original indentation around it.
perl -0pi -e 's{<body>.*?</body>}{<body>\n\t\t<slot />\n\t</body>}s' src/layouts/base-layout.astro

# Rebuild index.astro from the moved layout, embedding the original
# <body> content between the layout tags.
{
  printf -- '---\nimport BaseLayout from "@/layouts/base-layout.astro";\n---\n\n<BaseLayout>\n\t%s\n</BaseLayout>\n' "$body_content"
} > src/pages/index.astro
