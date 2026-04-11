- use react ignite boilerplate
- use bun
- use biome
- use zed for editor
- use eas for deployment
- use lefthook instead of husky

Add these packages (use `bun add <packages>`):

- @mgcrea/react-native-tailwind for styling with tailwind (compile time transformation)
- ky for HTTP requests
- react-hook-form for form
- type-fest for type utils
- tsgo
- lucide-react-native for icons
- date-fns for date formatting
- @tanstack/react-query for data state
- @reactuses/core for hook utilities
- @gorhom/bottom-sheet for bottom sheet
- es-toolkit for utilities (lodash replacement)
- react-native-enriched-markdown for markdown
- zod
- expo-crypto or react-native-get-random-values
- react-native-sonner for toast notifications (https://github.com/idrissgarfa/react-native-sonner)
- @icons-pack/react-simple-icons for brand SVG icons
- @legendapp/state for global/shared state management


## Tips

- it's possible to not require user for authentication. instead, generate uuid client side and use hmac for short lived token. it's not fool proof since the hmac secret is still stored locally, but increases the difficulty to spoof. it protects from MITM.
