# Expo Rapid Iteration

The fastest path from code to testers without waiting for App Store or Play Store review. Internal distribution builds skip review entirely — testers install directly and get updates instantly via OTA.

## The loop

```
eas build (once)  →  invite testers  →  eas update (every iteration)
```

The native build only needs to happen when native code changes (new native dependencies, permissions, app config). Everything else — UI, logic, screens — ships as an OTA update in seconds.

## Step 1: Configure EAS

```bash
bun add -g eas-cli
eas login
eas build:configure
```

Add an `internal` profile to `eas.json`:

```json
{
  "build": {
    "internal": {
      "distribution": "internal",
      "ios": {
        "simulator": false
      },
      "android": {
        "buildType": "apk"
      }
    },
    "production": {
      "distribution": "store"
    }
  },
  "update": {
    "channel": "production"
  }
}
```

## Step 2: Build for internal distribution

```bash
# iOS (goes to TestFlight internal testing)
eas build --platform ios --profile internal

# Android (generates APK for direct install)
eas build --platform android --profile internal

# Both at once
eas build --platform all --profile internal
```

Build takes ~10–15 minutes on EAS servers. You don't need to keep your machine on.

## Step 3: Invite testers

**iOS — TestFlight:**
1. Build appears automatically in App Store Connect under TestFlight
2. Go to TestFlight → Internal Testing → add testers by email
3. Testers get an email invite and install via the TestFlight app
4. No review required for internal testing (up to 100 testers)

**Android — Internal distribution:**
- EAS generates a direct APK download link
- Share the link or the QR code from the EAS dashboard
- Testers download and install directly (must enable "install from unknown sources")
- Alternatively, use Google Play Internal Testing track for a more managed flow

## Step 4: Iterate with OTA updates

Once testers have the app installed, ship updates without rebuilding:

```bash
eas update --branch production --message "fix: login screen layout"
```

The app checks for updates on launch and downloads in the background. Next open gets the new version. Testers don't need to do anything.

Add this as the `ota` script in `package.json`:

```json
{
  "scripts": {
    "ota": "eas update --branch production"
  }
}
```

Then just:

```bash
bun ota
```

## When to rebuild vs OTA

| Change | OTA sufficient | Rebuild needed |
|--------|---------------|----------------|
| UI / screens / logic | Yes | No |
| New JS-only package | Yes | No |
| New native module | No | Yes |
| New permission | No | Yes |
| App icon / splash screen | No | Yes |
| `app.json` config changes | No | Yes |

If unsure, check whether the package has native code (`ios/` or `android/` folders in node_modules). If it does, rebuild.

## Tips

- Keep the `internal` build around as a permanent test channel — don't delete it after the first release
- Use descriptive `--message` strings on `eas update` so testers and teammates can tell updates apart in the EAS dashboard
- For iOS, add all testers to the internal group before sending the build — you can't add them retroactively to an expired build
- OTA updates are gated by the runtime version in `app.json` — if you rebuild with a new runtime version, existing installs won't receive OTA updates until testers install the new build
