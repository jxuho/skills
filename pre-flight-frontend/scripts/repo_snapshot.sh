#!/usr/bin/env bash
set -eu

start_dir="${1:-.}"

if ! repo_root=$(git -C "$start_dir" rev-parse --show-toplevel 2>/dev/null); then
  echo "Not inside a Git repository: $start_dir" >&2
  exit 2
fi

printf 'repo_root: %s\n' "$repo_root"
printf 'branch: %s\n' "$(git -C "$repo_root" branch --show-current)"
printf 'head: %s\n' "$(git -C "$repo_root" rev-parse --short HEAD)"
printf '\nworking_tree:\n'
git -C "$repo_root" status --short || true

printf '\ntop_level:\n'
find "$repo_root" -mindepth 1 -maxdepth 1 -exec basename {} \; 2>/dev/null | sort | head -80

printf '\nworkspace_markers:\n'
for marker in package.json pnpm-workspace.yaml yarn.lock pnpm-lock.yaml package-lock.json bun.lockb bun.lock nx.json turbo.json lerna.json; do
  if [ -e "$repo_root/$marker" ]; then
    printf '%s\n' "$marker"
  fi
done

if [ -f "$repo_root/package.json" ]; then
  printf '\npackage_fingerprint:\n'
  python3 - "$repo_root/package.json" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    data = json.load(f)

deps = {}
deps.update(data.get("dependencies", {}))
deps.update(data.get("devDependencies", {}))
interesting = [
    "react", "react-dom", "next", "@remix-run/react", "gatsby",
    "vue", "nuxt", "svelte", "@sveltejs/kit", "@angular/core", "solid-js",
    "react-router", "react-router-dom", "vue-router", "@angular/router",
    "@tanstack/react-query", "@tanstack/vue-query", "swr", "@apollo/client",
    "redux", "@reduxjs/toolkit", "zustand", "pinia", "vuex", "rxjs",
    "react-hook-form", "formik", "vee-validate", "zod", "yup",
    "vite", "webpack", "rspack", "@vitejs/plugin-react", "@vitejs/plugin-vue",
    "jest", "vitest", "@testing-library/react", "@testing-library/vue",
    "playwright", "@playwright/test", "cypress"
]
for name in interesting:
    if name in deps:
        print(f"{name}: {deps[name]}")

workspaces = data.get("workspaces")
if workspaces:
    print(f"workspaces: {workspaces}")

scripts = data.get("scripts", {})
if scripts:
    print("scripts:")
    for name in sorted(scripts):
        if any(token in name.lower() for token in ("test", "lint", "type", "check", "build")):
            print(f"  {name}: {scripts[name]}")
PY
fi

printf '\npackage_candidates:\n'
find "$repo_root" -mindepth 1 -maxdepth 4 -type f -name package.json \
  -not -path '*/node_modules/*' -print 2>/dev/null | sed "s#^$repo_root/##" | sort | head -80

printf '\nconfig_candidates:\n'
find "$repo_root" -maxdepth 3 -type f \( \
  -name 'vite.config.*' -o -name 'next.config.*' -o -name 'nuxt.config.*' -o \
  -name 'svelte.config.*' -o -name 'angular.json' -o -name 'tsconfig.json' -o \
  -name 'vitest.config.*' -o -name 'jest.config.*' -o -name 'playwright.config.*' -o \
  -name 'cypress.config.*' -o -name '.eslintrc*' -o -name 'eslint.config.*' \
\) -not -path '*/node_modules/*' -print 2>/dev/null | sed "s#^$repo_root/##" | sort | head -100
