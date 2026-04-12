import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

function visit(node, type, fn) {
  if (node.type === type) fn(node);
  (node.children || []).forEach((child) => visit(child, type, fn));
}

/** Rewrites relative `.md` links (e.g. `./natural-vs-purism.md`) to their
 *  Astro route equivalents (e.g. `/patterns/natural-vs-purism`) at build time,
 *  so the raw markdown files stay usable as-is on GitHub / in editors. */
function remarkMdLinks() {
  return (tree) => {
    visit(tree, 'link', (node) => {
      const { url } = node;
      if (url && !url.startsWith('/') && !url.startsWith('http') && url.endsWith('.md')) {
        const slug = url.split('/').pop().replace(/\.md$/, '');
        node.url = `/patterns/${slug}`;
      }
    });
  };
}

export default defineConfig({
  markdown: {
    remarkPlugins: [remarkMdLinks],
  },
  site: 'https://metastarter.wzulfikar.com',
  vite: {
    plugins: [tailwindcss()],
    server: {
      fs: {
        allow: ['..'],
      },
    },
  },
});
