# Natural vs Purism

## The tension

There are principled, well-designed solutions for common TypeScript problems:

- **Error handling**: Effect.ts, neverthrow
- **API layer**: tRPC, ts-rest
- **Validation + schema**: zod-to-openapi, typebox

So why does meta-starter not use them?

## The problem with purism

Principled libraries optimize for correctness and completeness. The tradeoff is that they require you to adopt a mental model and *stay inside it*. Effect.ts has its own primitives: pipe, gen, fiber, layer. tRPC requires a router structure and a per-framework client adapter. neverthrow wraps everything and removes the option to throw at all.

These models pay off when you're in the codebase daily. They become friction when you return after a month and spend the first session re-learning library conventions instead of solving the actual problem.

**The heuristic:** if re-entering a codebase costs more than 15 minutes of framework archaeology, the abstraction is working against you.

## The natural approach

Natural means the abstraction matches how you already think, not how a library wants you to think. It should be re-enterable with near-zero warm-up.

In meta-starter this looks like:

- `Result<T, E>`: just `{ data, error }`. No new primitives to learn
- `tryCatch` / `throwOnError` from saas-maker: one line each, obvious intent
- `AppError`: plain class extension, typed metadata, no runtime magic
- Route helpers instead of tRPC: just functions with typed input/output

None of this is novel. It is deliberately boring.

## Why not just use the standard?

| Library | Actual cost |
|---------|-------------|
| Effect.ts | Full mental model adoption. Pipe, gen, fiber, layer are new primitives, not just new syntax |
| neverthrow | One-way door. Wraps everything; you lose the ability to throw at all |
| tRPC | Client-server coupling; specific adapter per frontend; re-learn on each return |
| ts-rest | Contract-first: right for public APIs, overhead for internal product code |

The cost is never the library itself. It is the context switch every time you re-enter.

## The LLM factor

LLMs extend whatever patterns exist in a codebase. A codebase using Effect.ts will get LLM-generated Effect.ts — including subtle mistakes from a model that has seen far more plain TypeScript than Effect code. A codebase using plain TypeScript gets reliable, predictable output.

Keeping patterns natural is not only about human readability. It keeps AI-assisted development predictable and consistent.

## When to reconsider

This is a cost-benefit frame, not a rule against sophisticated libraries:

- Team in the codebase daily → Effect.ts cost amortizes, worth adopting
- Large public API with multiple consumers → tRPC or ts-rest pays for itself
- Correctness matters more than simplicity → neverthrow's discipline may be right

For most products touched infrequently by a small team: boring patterns win.

---

See [think-in-shapes.md](./think-in-shapes.md) for the underlying philosophy this approach is built on.
