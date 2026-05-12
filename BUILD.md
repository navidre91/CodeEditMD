# Building and installing CodeEditMD

This fork ships as `CodeEditMD.app`. Day-to-day use runs from `/Applications/CodeEditMD.app`, not from Xcode's DerivedData.

## Build

```
xcodebuild -project CodeEdit.xcodeproj \
           -scheme CodeEdit \
           -configuration Debug \
           -destination 'platform=macOS' \
           -skipPackagePluginValidation \
           -skipMacroValidation \
           build
```

The built bundle lands in the scheme's `BUILT_PRODUCTS_DIR`:

```
xcodebuild -project CodeEdit.xcodeproj -scheme CodeEdit -configuration Debug -showBuildSettings \
  | awk -F' = ' '/BUILT_PRODUCTS_DIR/ {print $2; exit}'
```

## Install to `/Applications`

A successful build does **not** update the app launched from Dock/Spotlight. The running app is the one in `/Applications`, so code changes are only observable after replacing it:

```
killall CodeEditMD 2>/dev/null
BUILT="$(xcodebuild -project CodeEdit.xcodeproj -scheme CodeEdit -configuration Debug -showBuildSettings \
          | awk -F' = ' '/BUILT_PRODUCTS_DIR/ {print $2; exit}')/CodeEditMD.app"
ditto "/Applications/CodeEditMD.app" "/Applications/CodeEditMD.app.backup-$(date +%Y%m%d-%H%M%S)"
rm -rf "/Applications/CodeEditMD.app"
ditto "$BUILT" "/Applications/CodeEditMD.app"
open "/Applications/CodeEditMD.app"
```

If a bug fix appears to have no effect at runtime, check the install step before anything else.
