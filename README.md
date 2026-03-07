# Noted

Minimal macOS markdown editor with a built-in terminal, wiki links, quick open, and inline image previews.

## Requirements

- macOS 14+
- Xcode 16+
- Homebrew
- `xcodegen`

Install `xcodegen` if needed:

```bash
brew install xcodegen
```

## Build And Run

1. Generate the Xcode project:

```bash
xcodegen generate
```

2. Open the project in Xcode:

```bash
open Noted.xcodeproj
```

3. In Xcode, select the `Noted` scheme and press `Cmd-R` to build and run.

You can also build from the command line:

```bash
xcodebuild -project "Noted.xcodeproj" -scheme "Noted" -destination "platform=macOS" build
```

The built app will be placed in Xcode DerivedData under the Debug products folder.

## Notes

- The project uses `SwiftTerm` via Swift Package Manager.
- If you add new source files, regenerate the project with `xcodegen generate` before building.
