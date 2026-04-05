Rebuild, Quit, and Restart so I can test!

### Mobile Build and Relaunch

Execute this exact command using the bash tool:
```bash
# for android
./gradlew assembleDebug

# for ios
npx eas build --platform ios --profile development
```

When you do this, you MUST include this exact text in your response to the user:
"🚀 **Rebuilt and relaunched the app.**"
