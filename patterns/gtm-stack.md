# GTM Stack

GTM (Go-to Market) in short: The plan for how to get your product to the people who need it, at the moment they are ready to pay, through a channel you can use repeatedly. It's not the launch day, but the system before launch day that makes launch day matter.

## The five components

| Component   | What it means                                            |
| ----------- | -------------------------------------------------------- |
| Problem     | The pain you are solving and how urgent it is            |
| Positioning | How you frame that pain for the people you'll sell it to |
| ICP         | The people who you are selling to                        |
| Channel     | The place to reliably reach most of your ICP             |
| Motion      | The process to turns interest into revenue               |

Without these five, you don't have GTM. You just have a scattered marketing activity with no clear distribution plan.

Example of motion: awareness -> interest -> trial -> conversion.

## The stack

This is the tool stack for filling those GTM needs.

| Need                | Tool                                                                                                                                                                                     |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Market research     | Claude or ChatGPT with a product thesis template                                                                                                                                         |
| Forms / surveys     | [Tally](https://tally.so), [Google Forms](https://forms.google.com)                                                                                                                      |
| Product analytics   | [Mixpanel](https://mixpanel.com), [Metabase](https://www.metabase.com), [PostHog](https://posthog.com)                                                                                   |
| Marketing           | [Typefully](https://typefully.com)                                                                                                                                                       |
| Reddit distribution | [Redreach.ai](https://redreach.ai)                                                                                                                                                       |
| Web onboarding      | [Flows](https://flows.sh)                                                                                                                                                                |
| Expo onboarding     | [react-native-onboarding](https://github.com/software-mansion-labs/react-native-onboarding), [react-native-spotlight-tour](https://github.com/stackbuilders/react-native-spotlight-tour) |

## Market research

Use Claude or ChatGPT with a product thesis template to research the problem and sharpen the first four parts of GTM: problem, positioning, ICP, and likely channels.

Use for:

- Writing the initial product thesis
- Breaking a vague idea into a specific user pain
- Comparing possible ICPs
- Finding where those users already spend time
- Turning interview notes into repeated themes

The goal is not to ask AI for random marketing ideas. The goal is to make the thesis specific enough that the ICP and channel become obvious.

## Forms and surveys

**Tally** and **Google Forms** are the fastest way to collect structured feedback from prospects and early users.

Use for:

- Problem interviews
- Waitlist collection
- Pricing and willingness-to-pay questions
- Feature prioritization
- Post-onboarding follow-up

Use Tally when you want a cleaner and more branded form. Use Google Forms when speed and ubiquity matter more than presentation.

## Product analytics

Analytics exists to measure the motion. If it does not help you understand the path from awareness to revenue, it is dashboard theater.

**Mixpanel** is strong for funnels, retention, and conversion analysis.
**PostHog** is strong when you also want session replay, feature flags, and experimentation.
**Metabase** is strong when you want SQL-first reporting on top of your own database.

Track events that map to the motion:

- Awareness: first visit, landing page CTA click, waitlist visit
- Interest: signup, email capture, demo request
- Trial: onboarding completed, first core action
- Conversion: paid, upgraded, renewed

If you cannot tell where users drop between those stages, the GTM motion is still unclear.

## Marketing

**Typefully** is for scheduling and iterating on X, Threads, and LinkedIn content.

Use for:

- Posting consistently without being online all day
- Testing different positioning angles
- Reusing the same idea across multiple channels

For Reddit, use **Redreach.ai** when your ICP already lives in subreddits and you want a repeatable way to reach them.

The rule is simple: pick a channel because your ICP is there, not because the platform is popular.

## Onboarding

Onboarding is part of GTM because interest is useless if new users never reach first value.

### Web app: Flows

Use **Flows** for in-app tours, checklists, and guided onboarding in web products.

### Expo: react-native-onboarding

Use **react-native-onboarding** for native onboarding flows in Expo and React Native apps.

## How it fits together

1. Use AI plus a product thesis template to define the problem, positioning, ICP, and possible channels.
2. Use Tally or Google Forms to validate the thesis with real users.
3. Use Typefully or Reddit via Redreach.ai to reach the chosen channel repeatedly.
4. Use Flows or react-native-onboarding to move users to first value quickly.
5. Use Mixpanel, PostHog, or Metabase to measure the motion and tighten it over time.

That is the GTM stack: tools that make the five components concrete instead of vague.
