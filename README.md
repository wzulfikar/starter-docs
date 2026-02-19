# Starter Docs

Collection of scripts, configs, documentations,and LLM prompts to add to your favorite starter/template repositories.

## Why

You have your favorite starter template but there are things that you don't quite like it and so you want to change. With AI agents, it's easy now but you still want some structure. This repo helps with that. 

## How it works

I have starter templates that I like. For example, [supa-next-starter](https://github.com/michaeltroya/supa-next-starter) is my default when I want to start a web app project. However, I want to use specific things, like `biome` instead of `eslint`, `tsgo` instead of `tsc`. Instead of tweaking the template manually, I can: 

1. Clone the template like usual, e.g. into `my-app`
2. Copy everything in template's folder to the app folder, e.g. from `starter-docs/supa-next-starter/*` to `my-app/`
3. Use AI agent to start the tweak by including `docs/agents/customize-starter-template.md`. The markdown file contains prompt to modify the template to my liking.

With this approach, I can keep my preference and replicate it when starting new projects, without having to keep up with the changes in upstream (because AI agent will handle it on demand).

Hope it helps :)
