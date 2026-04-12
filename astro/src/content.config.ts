import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';

const patterns = defineCollection({
  loader: glob({ pattern: '**/*.md', base: '../patterns' }),
});

export const collections = { patterns };
