// SVGO config used by `npm run optimize`. Keeps viewBox and width/height so the
// icons stay a predictable 24x24 when dropped into a page.
export default {
  multipass: true,
  plugins: [
    {
      name: "preset-default",
      params: { overrides: { removeViewBox: false } },
    },
  ],
};
