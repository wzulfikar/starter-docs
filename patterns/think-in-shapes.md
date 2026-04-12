# Think in Shapes

## The idea

When approaching a problem, most people jump straight to _how_: what steps, what logic, what code. Thinking in shapes says: slow down and answer a simpler set of questions first.

1. **What do you want to do?** → State the goal plainly.
2. **What is the shape of "input" that can possibly do it?**
3. **What process can we do with such shape, that will achieve the goal?** → This is the actual work (the how).
4. **What is the output shape that it produces?** → What comes out at the other side?

The payoff: once you know the input shape and the output shape, the process in the middle becomes almost mechanical and you don't have to think much about it. It's just "implementation details". Now you can think simply in term of _what goes in_ and _what comes out_.

## Why it reduces mental load

A process that takes a clear shape and produces a clear shape is easy to reason about in isolation. You do not need to hold the entire system in your head. You just need to know:

- If I give this, I get that

Which conversely means:

- If I want that, I give this

This also makes it easy to _chain_ processes, build one upon another (ie. composable). The output of one becomes the input of the next. As long as the shapes match, the chain works, regardless of what each step does internally.

## Variations matter

A shape is not just a list of fields. It includes the _possible states_ that shape can be in. A loan application is not one thing: it is a draft, a submitted form, an approved one, or a rejected one. Each state carries different information and allows different processes.

Being explicit about variations upfront means:

- Illegal actions become structurally impossible (you cannot approve a draft that was never submitted)
- Each process only handles what it actually needs to handle
- The code reads like the domain, not like defensive logic guarding against things that should not happen

> Engineers call this "type-driven design." Here, we call it "think in shapes" because the idea is intuitive and does not require a technical background to apply.

## In practice

When you sit down with a problem, resist the urge to think about the steps first. Instead, ask:

- What information do I have at the start?
- What are the valid states that information can be in?
- What process applies to each state?
- What does that process return?

Get those four answers on paper before writing anything. The implementation will follow.
