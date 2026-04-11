# Expo Minimal Screens

Every Expo app needs exactly two screens to be useful. Everything else is optional and added on demand.

## The two screens

### Home screen

Where the user gets the core value of the app. This is the first screen after onboarding (or after launch if there's no onboarding).

Keep it focused — one primary action or flow. Don't turn the home screen into a dashboard with many features. A user who opens the app should immediately understand what to do.

```
App launch
  ├── First time → Onboarding → Home
  └── Returning  → Home
```

Onboarding is optional and shown only once. After onboarding completes, always land on Home. Store a flag in persistent storage (`AsyncStorage` or `expo-secure-store`) so onboarding doesn't repeat.

### Settings screen

Everything that configures the app. Accessible from Home (usually a gear icon in the header). Contains:

- App-level toggles and preferences
- Account / profile section (if the app has auth)
- **Feedback trigger** — opens the in-app feedback widget so users can send questions or reports without leaving the app
- **"Show Onboarding"** button — lets users replay the onboarding any time. Useful for new features and for users who want a refresher
- App version number at the bottom (helpful for bug reports)

## Composable settings UI

Settings screens are inherently repetitive — many rows with the same structure but different content. Build a small set of composable components once and compose everything from them.

### SettingRow

The atomic unit. Renders one setting item. Supports different right-side controls via props.

```tsx
// src/components/settings/SettingRow.tsx
import { View, Text, Switch, Pressable } from "react-native"
import { ChevronRight } from "lucide-react-native"

type SettingRowProps =
  | { label: string; description?: string; type: "toggle"; value: boolean; onChange: (v: boolean) => void }
  | { label: string; description?: string; type: "link"; onPress: () => void }
  | { label: string; description?: string; type: "destructive"; onPress: () => void }
  | { label: string; description?: string; type: "info"; value: string }

export function SettingRow(props: SettingRowProps) {
  return (
    <Pressable
      onPress={props.type === "link" || props.type === "destructive" ? props.onPress : undefined}
      className="flex-row items-center justify-between px-4 py-3 bg-white"
    >
      <View className="flex-1 mr-4">
        <Text className={props.type === "destructive" ? "text-red-500" : "text-gray-900"}>
          {props.label}
        </Text>
        {props.description && (
          <Text className="text-sm text-gray-500 mt-0.5">{props.description}</Text>
        )}
      </View>

      {props.type === "toggle" && (
        <Switch value={props.value} onValueChange={props.onChange} />
      )}
      {props.type === "link" && (
        <ChevronRight size={16} className="text-gray-400" />
      )}
      {props.type === "info" && (
        <Text className="text-gray-400">{props.value}</Text>
      )}
    </Pressable>
  )
}
```

### SettingRowsGroup

Groups multiple `SettingRow` components with dividers between them and a card-style container. Mirrors the grouped table view style familiar to iOS users.

```tsx
// src/components/settings/SettingRowsGroup.tsx
import { View } from "react-native"

export function SettingRowsGroup({ children }: { children: React.ReactNode }) {
  return (
    <View className="rounded-xl overflow-hidden border border-gray-200 bg-white">
      {children}
    </View>
  )
}
```

### SettingSectionLabel

A section heading above a group. Describes what the group is about.

```tsx
// src/components/settings/SettingSectionLabel.tsx
import { Text, View } from "react-native"

export function SettingSectionLabel({ label }: { label: string }) {
  return (
    <View className="px-1 pb-1.5 pt-4">
      <Text className="text-xs font-medium uppercase tracking-wide text-gray-500">
        {label}
      </Text>
    </View>
  )
}
```

### Composing the settings screen

```tsx
// src/screens/SettingsScreen.tsx
export function SettingsScreen() {
  const [notifications, setNotifications] = useState(true)
  const { showOnboarding } = useOnboarding()
  const { showFeedback } = useFeedbackWidget()
  const appVersion = Application.nativeApplicationVersion

  return (
    <ScrollView className="flex-1 bg-gray-100 px-4">

      <SettingSectionLabel label="Preferences" />
      <SettingRowsGroup>
        <SettingRow
          type="toggle"
          label="Push notifications"
          value={notifications}
          onChange={setNotifications}
        />
        <SettingRow
          type="toggle"
          label="Dark mode"
          description="Follows system setting by default"
          value={darkMode}
          onChange={setDarkMode}
        />
      </SettingRowsGroup>

      <SettingSectionLabel label="Support" />
      <SettingRowsGroup>
        <SettingRow
          type="link"
          label="Send feedback"
          onPress={showFeedback}
        />
        <SettingRow
          type="link"
          label="Show onboarding"
          onPress={showOnboarding}
        />
      </SettingRowsGroup>

      <SettingSectionLabel label="Account" />
      <SettingRowsGroup>
        <SettingRow
          type="destructive"
          label="Log out"
          onPress={handleLogout}
        />
      </SettingRowsGroup>

      <Text className="text-center text-xs text-gray-400 mt-6 mb-8">
        Version {appVersion}
      </Text>

    </ScrollView>
  )
}
```

## File structure

```
src/
  screens/
    HomeScreen.tsx
    SettingsScreen.tsx
    onboarding/
      OnboardingScreen.tsx   # or split into steps: Step1.tsx, Step2.tsx
  components/
    settings/
      SettingRow.tsx
      SettingRowsGroup.tsx
      SettingSectionLabel.tsx
```

## Notes

- Export `SettingRow`, `SettingRowsGroup`, and `SettingSectionLabel` from a single `src/components/settings/index.ts` barrel — settings screen imports are cleaner
- The `type` discriminated union on `SettingRow` means TypeScript enforces the right props for each variant — no runtime surprises
- Keep the settings components pure and presentational; all logic (toggling state, triggering feedback, replaying onboarding) lives in the screen
