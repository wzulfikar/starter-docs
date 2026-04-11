# Icons

Three libraries cover all icon needs. Each has a clear role.

## Lucide — default

[lucide-react](https://lucide.dev) is the default for all UI icons. Large icon set, consistent stroke style, tree-shakeable.

```tsx
import { Settings, ChevronRight, X } from "lucide-react"

<Settings size={20} strokeWidth={1.5} className="text-muted-foreground" />
```

For React Native use `lucide-react-native` instead — same API.

### Using the raw SVG

Lucide icons are plain SVGs, so when you need full control — custom paths, tweaked geometry, composite icons — copy the SVG source directly from [lucide.dev](https://lucide.dev) and inline it:

```tsx
// Copied and tweaked from lucide.dev
export function CustomIcon({ size = 24, ...props }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.5}
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      {/* paste and modify path here */}
      <path d="M12 2L2 7l10 5 10-5-10-5z" />
    </svg>
  )
}
```

This is preferable to wrapping a library component when you need to animate individual paths, combine two icons, or adjust geometry that `strokeWidth` alone can't fix.

## Lucide Animated — for animated icons

[lucide-animated](https://lucide-animated.com) provides drop-in animated variants of lucide icons. Same icon names, same props — just add motion.

```tsx
import { Settings, ChevronRight } from "lucide-animated"

<Settings size={20} />
```

Use these selectively — for interactive elements where motion adds meaning (loading states, toggles, confirmations). Don't replace all lucide icons with animated ones.

**Web only.** Not available for React Native.

## Simple Icons — brand logos

[@icons-pack/react-simple-icons](https://github.com/icons-pack/react-simple-icons) provides SVG logos for hundreds of brands (GitHub, X, Stripe, Vercel, etc.), sourced from [simpleicons.org](https://simpleicons.org).

```tsx
import { SiGithub, SiStripe, SiVercel } from "@icons-pack/react-simple-icons"

<SiGithub size={20} />

// Use the brand color
<SiStripe size={20} color="#635BFF" />
```

Each icon exports its official hex color as `Si<Name>Color`:

```tsx
import { SiStripe, SiStripeColor } from "@icons-pack/react-simple-icons"

<SiStripe color={SiStripeColor} />
```

## Summary

| Need | Library | Package |
|------|---------|---------|
| General UI icons | Lucide | `lucide-react` / `lucide-react-native` |
| Animated UI icons | Lucide Animated | `lucide-animated` |
| Brand / logo icons | Simple Icons | `@icons-pack/react-simple-icons` |
| Custom / tweaked icons | Raw SVG from lucide.dev | — |
