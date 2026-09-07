#!/usr/bin/env node
// Generates one self-contained React component per icon in react/ from svg/*.svg.
// Run after editing any SVG:  node scripts/build-react.mjs
import { mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { basename, join } from "node:path";
import { fileURLToPath } from "node:url";

const SVG_DIR = fileURLToPath(new URL("../svg/", import.meta.url));
const OUT_DIR = fileURLToPath(new URL("../react/", import.meta.url));

const DESCRIPTIONS = {
  "shadcn-avatar": "Face with clear glasses.",
  "shadcn-avatar-sunglasses": "Face with dark sunglasses.",
  "shadcn-avatar-sunglasses-filled": "Face with dark sunglasses and a tinted face.",
  "shadcn-avatar-bust": "Head and shoulders, clear glasses.",
  "shadcn-avatar-bust-sunglasses": "Head and shoulders, dark sunglasses.",
  "shadcn-avatar-minimal": "Just the glasses and the mouth.",
};

const toPascal = (s) => s.replace(/(^|-)([a-z0-9])/g, (_, __, c) => c.toUpperCase());
const toJsxAttr = (s) => s.replace(/-([a-z])/g, (_, c) => c.toUpperCase());

mkdirSync(OUT_DIR, { recursive: true });
const files = readdirSync(SVG_DIR).filter((f) => f.endsWith(".svg")).sort();
const indexLines = [];

for (const file of files) {
  const name = basename(file, ".svg");
  const component = toPascal(name);
  const svg = readFileSync(join(SVG_DIR, file), "utf8");
  const inner = svg
    .replace(/^[\s\S]*?<svg[^>]*>/, "")
    .replace(/<\/svg>\s*$/, "")
    .trim();
  const children = inner
    .replace(/\s([a-z]+(?:-[a-z]+)+)=/g, (_, attr) => ` ${toJsxAttr(attr)}=`)
    .replace(/></g, ">\n      <")
    .replace(/\/>/g, " />");

  const source = `import * as React from "react"

export type ${component}Props = React.SVGProps<SVGSVGElement> & {
  /** Width and height in px (default 24). Tailwind classes such as \`size-6\` work too. */
  size?: number | string
}

/** shadcn avatar icon: ${DESCRIPTIONS[name] ?? name} */
export function ${component}({ size = 24, ...props }: ${component}Props) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      aria-hidden="true"
      {...props}
    >
      ${children}
    </svg>
  )
}
`;
  writeFileSync(join(OUT_DIR, `${name}.tsx`), source);
  indexLines.push(`export * from "./${name}"`);
  console.log(`react/${name}.tsx  ->  <${component} />`);
}

writeFileSync(join(OUT_DIR, "index.ts"), indexLines.join("\n") + "\n");
