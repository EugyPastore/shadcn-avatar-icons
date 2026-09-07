<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/preview-dark.png">
    <img alt="The six shadcn avatar icons in a row" src="assets/preview-light.png" width="720">
  </picture>
</p>

<h1 align="center">shadcn avatar icons</h1>

<p align="center">
  Six free SVG icons of the <a href="https://github.com/shadcn">shadcn</a> avatar, drawn on a 24 × 24 grid
  so they sit naturally next to <a href="https://lucide.dev">Lucide</a> in any <a href="https://ui.shadcn.com">shadcn/ui</a> project.
</p>

<p align="center">
  <a href="LICENSE"><img alt="MIT license" src="https://img.shields.io/badge/license-MIT-black"></a>
  <a href="https://github.com/EugyPastore/shadcn-avatar-icons/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/EugyPastore/shadcn-avatar-icons?color=black"></a>
  <a href="https://github.com/EugyPastore/shadcn-avatar-icons/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/EugyPastore/shadcn-avatar-icons?style=social"></a>
</p>

> **Unofficial.** This is fan art made with love. It is not affiliated with or endorsed by shadcn.

## The icons

| | Name | Description | Download |
|:-:|---|---|---|
| <picture><source media="(prefers-color-scheme: dark)" srcset="assets/dark/shadcn-avatar.svg"><img src="svg/shadcn-avatar.svg" width="40" alt=""></picture> | `shadcn-avatar` | Face with clear glasses | [SVG](svg/shadcn-avatar.svg) · [PNG](png/512/shadcn-avatar.png) |
| <picture><source media="(prefers-color-scheme: dark)" srcset="assets/dark/shadcn-avatar-sunglasses.svg"><img src="svg/shadcn-avatar-sunglasses.svg" width="40" alt=""></picture> | `shadcn-avatar-sunglasses` | Face with dark sunglasses | [SVG](svg/shadcn-avatar-sunglasses.svg) · [PNG](png/512/shadcn-avatar-sunglasses.png) |
| <picture><source media="(prefers-color-scheme: dark)" srcset="assets/dark/shadcn-avatar-sunglasses-filled.svg"><img src="svg/shadcn-avatar-sunglasses-filled.svg" width="40" alt=""></picture> | `shadcn-avatar-sunglasses-filled` | Sunglasses with a tinted face | [SVG](svg/shadcn-avatar-sunglasses-filled.svg) · [PNG](png/512/shadcn-avatar-sunglasses-filled.png) |
| <picture><source media="(prefers-color-scheme: dark)" srcset="assets/dark/shadcn-avatar-bust.svg"><img src="svg/shadcn-avatar-bust.svg" width="40" alt=""></picture> | `shadcn-avatar-bust` | Head and shoulders, clear glasses | [SVG](svg/shadcn-avatar-bust.svg) · [PNG](png/512/shadcn-avatar-bust.png) |
| <picture><source media="(prefers-color-scheme: dark)" srcset="assets/dark/shadcn-avatar-bust-sunglasses.svg"><img src="svg/shadcn-avatar-bust-sunglasses.svg" width="40" alt=""></picture> | `shadcn-avatar-bust-sunglasses` | Head and shoulders, dark sunglasses | [SVG](svg/shadcn-avatar-bust-sunglasses.svg) · [PNG](png/512/shadcn-avatar-bust-sunglasses.png) |
| <picture><source media="(prefers-color-scheme: dark)" srcset="assets/dark/shadcn-avatar-minimal.svg"><img src="svg/shadcn-avatar-minimal.svg" width="40" alt=""></picture> | `shadcn-avatar-minimal` | Just the glasses and the mouth | [SVG](svg/shadcn-avatar-minimal.svg) · [PNG](png/512/shadcn-avatar-minimal.png) |

**Want everything at once?** Download the [latest release zip](https://github.com/EugyPastore/shadcn-avatar-icons/releases/latest) (SVG + PNG + React), or use **Code → Download ZIP** above.

## Usage

### SVG (works anywhere)

Every icon uses `currentColor`, so it takes the surrounding text color and works in dark mode with no extra work.

```html
<!-- as an image -->
<img src="shadcn-avatar.svg" width="24" height="24" alt="shadcn avatar">

<!-- inline, styled with Tailwind -->
<svg class="size-6 text-foreground" viewBox="0 0 24 24" fill="none">…</svg>
```

### React (the shadcn way: copy, paste, own it)

Copy any file from [`react/`](react) into your project, for example `components/icons/shadcn-avatar.tsx`.
The components have no dependencies besides React, accept every normal SVG prop, and work in Server Components.

```tsx
import { ShadcnAvatar } from "@/components/icons/shadcn-avatar"

export function Example() {
  return (
    <>
      <ShadcnAvatar className="size-5 text-muted-foreground" />
      <ShadcnAvatar size={32} />
    </>
  )
}
```

### PNG

[`png/`](png) has every icon at 128, 256, 512 and 1024 px, black on a transparent background.
Handy for avatars, Slack, Notion, Figma or anywhere SVG is not an option.

## Design notes

- 24 × 24 px grid, the same grid Lucide uses
- 1 px stroke, rounded corners, expanded to filled paths so nothing depends on stroke settings
- One color via `currentColor`; the filled variant tints the face at 20 % opacity
- Optimized with SVGO, 1.4 to 3.2 KB per file

## Repository layout

```
svg/       optimized SVG sources, start here
png/       PNG exports at 128 / 256 / 512 / 1024 px
react/     one self-contained React component per icon (TSX)
assets/    README previews
scripts/   build scripts: SVG → React and SVG → PNG
```

## Contributing

Ideas for another variant? [Open an issue](https://github.com/EugyPastore/shadcn-avatar-icons/issues).
If you edit an SVG, run `npm install` once and then `npm run build` to regenerate the React components and PNGs.

## License

[MIT](LICENSE) © 2026 [Eugenia Pastore](https://github.com/EugyPastore).
Free for personal and commercial use. Keep the license notice if you redistribute the files; a link back is always appreciated.

If these are useful to you, a ⭐ on the repo helps other people find them.
