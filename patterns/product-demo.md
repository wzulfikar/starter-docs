# Product Demo

Tools for creating polished visuals for demos, App Store listings, landing pages, and press kits. These are Mac apps — use them after the feature is built and working in the simulator.

## Screen recording — RocketSim

**RocketSim** records the iOS simulator and produces clean, professional video output. Adds device frames, touch indicators, and removes the simulator chrome so the recording looks like it was shot on a real device.

Use for:
- Product demos and feature walkthroughs
- Landing page hero videos
- Social media clips

Workflow:
1. Get the feature working in the simulator
2. Open RocketSim, select the simulator window
3. Record the interaction
4. Export with device frame

## Screenshots with mockup — TinyShot

**TinyShot** takes simulator screenshots and wraps them in beautiful device mockups. Faster than doing it in Figma or Photoshop.

Use for:
- Landing page feature screenshots
- Press kit images
- README and documentation visuals

Workflow:
1. Set up the screen state you want to capture in the simulator
2. Take a screenshot via TinyShot
3. Choose device frame and background
4. Export

## App Store screenshots — Butterkit

**Butterkit** generates App Store screenshots at all required sizes and localizations. Lets you design a template once and render it across every device size Apple requires (6.9", 6.5", 5.5", iPad, etc.).

Use for:
- App Store listing screenshots (required for submission)
- Re-generating screenshots after UI changes
- Localised screenshots for different markets

Workflow:
1. Design the screenshot template (background, device, caption)
2. Connect your simulator screenshots
3. Export at all required sizes in one shot

## When to use which

| Situation | Tool |
|-----------|------|
| Recording a feature in motion | RocketSim |
| One-off screenshot for docs or landing page | TinyShot |
| App Store submission screenshots | Butterkit |
| Multiple device sizes needed | Butterkit |

## Notes

- All three tools work with the iOS simulator — get the feature polished there before capturing
- RocketSim and TinyShot are useful throughout development; Butterkit is primarily a pre-release task
- Keep raw simulator screenshots alongside exports in case you need to re-render with a different frame or layout
