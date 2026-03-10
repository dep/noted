### Important Repo Rules:

1. Always kill, rebuild, and restart the app after making changes to the codebase.

```
xcodegen generate && xcodebuild -project "Noted.xcodeproj" -scheme "Noted" -destination "platform=macOS" build && open ~/Library/Developer/Xcode/DerivedData/Noted-*/Build/Products/Debug/Noted.app
```
