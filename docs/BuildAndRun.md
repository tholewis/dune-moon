# Build & Run Guide

## Prerequisites

### Required Software

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later
- **iOS Deployment Target**: 15.0 or later
- **Swift**: 6.0

### Recommended Setup

- Apple Developer Account (for device testing)
- Physical iOS device for location testing
- Fast internet connection for initial setup

---

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/Lithium.git
cd Lithium
```

### 2. Open in Xcode

```bash
open Lithium.xcodeproj
```

Or double-click `Lithium.xcodeproj` in Finder.

### 3. Select Target Device

In Xcode's toolbar:
- Click the device selector dropdown (next to the Run button)
- Choose your target:
  - **Simulator**: "iPhone 15 Pro" (recommended)
  - **Physical Device**: Your connected iPhone/iPad

### 4. Configure Signing (if using physical device)

1. Select the "Lithium" project in the navigator
2. Select the "Lithium" target
3. Go to "Signing & Capabilities" tab
4. Under "Team", select your Apple Developer account
5. Xcode will automatically generate a provisioning profile

### 5. Build and Run

**Keyboard Shortcut**: `⌘R`

Or click the ▶️ Play button in Xcode's toolbar.

---

## Project Structure

```
Lithium/
├── Lithium.xcodeproj          # Xcode project file
├── Lithium/                   # Source code
│   ├── LithiumApp.swift       # App entry point
│   ├── ContentView.swift
│   ├── MoonPhaseView.swift
│   ├── MoonPhaseCalculator.swift
│   ├── TimelineView.swift
│   ├── PhaseInfoPanel.swift
│   ├── ArrakisMoonView.swift
│   ├── LocationManager.swift
│   ├── SpiceGlowEffect.swift
│   ├── CalendarGridView.swift
│   └── Assets.xcassets/
│       └── ArrakisPoster.imageset/
├── LICENSE
├── README.md
└── docs/                      # Documentation
```

---

## Configuration

### Info.plist Settings

The app requires location permissions. Xcode automatically manages Info.plist, but verify:

**Key**: `NSLocationWhenInUseUsageDescription`
**Value**: "Lithium needs your location to calculate accurate moonrise and moonset times for your area."

To check/edit:
1. Select Lithium target
2. Go to "Info" tab
3. Find "Privacy - Location When In Use Usage Description"

### Build Settings

Default settings should work. Key configurations:

- **Deployment Target**: iOS 15.0
- **Swift Language Version**: Swift 6
- **Optimization Level**:
  - Debug: `-Onone` (no optimization)
  - Release: `-O` (full optimization)

---

## Running on Simulator

### Advantages
- ✅ No developer account needed
- ✅ Fast deployment
- ✅ Easy debugging

### Limitations
- ⚠️ Location services use simulated location
- ⚠️ No real GPS data
- ⚠️ Different performance characteristics

### Simulating Location

1. Run app in simulator
2. In menu: **Features** → **Location** → **Custom Location...**
3. Enter coordinates (e.g., San Francisco: 37.7749, -122.4194)
4. Moonrise/moonset times will update

---

## Running on Physical Device

### Advantages
- ✅ Real GPS location
- ✅ Accurate performance testing
- ✅ True user experience

### Requirements
- Apple Developer account ($99/year for full features)
- OR Free personal team account (limited to 7-day app lifespan)

### Steps

1. Connect iPhone/iPad via USB or WiFi
2. Unlock device and trust computer
3. Select device in Xcode
4. Run (⌘R)
5. On first run, on device:
   - Go to **Settings** → **General** → **VPN & Device Management**
   - Trust your developer certificate
6. Allow location permissions when prompted

---

## Debugging

### Console Logs

View debug output in Xcode's Console (⌘⇧C):

```swift
print("Phase calculated: \(phaseData.phase)")
print("Location: \(locationManager.coordinate)")
```

### Breakpoints

Set breakpoints to pause execution:
1. Click line number in source editor
2. Blue arrow appears
3. Run app in debug mode
4. Execution pauses at breakpoint

### Preview Canvas

Use SwiftUI Previews for rapid iteration:
1. Open any view file (e.g., `ContentView.swift`)
2. Click "Resume" in Preview pane (⌘⌥P)
3. Interact with live preview

---

## Common Build Issues

### Issue: "No such module 'SwiftUI'"

**Solution**: Ensure deployment target is iOS 13.0+

```
Target → Deployment Info → iOS Deployment Target: 15.0
```

### Issue: Location not working in simulator

**Solution**: Set custom location in simulator

```
Features → Location → Custom Location
```

### Issue: "Unable to install..."

**Solution**:
1. Delete app from device
2. Clean build folder (⌘⇧K)
3. Rebuild and run

### Issue: Signing error

**Solution**:
1. Go to Signing & Capabilities
2. Enable "Automatically manage signing"
3. Select your team

---

## Performance Optimization

### Debug vs Release

**Debug Build** (default when running from Xcode):
- No optimization
- Includes debug symbols
- Slower performance
- Easier debugging

**Release Build**:
```
Product → Scheme → Edit Scheme → Run → Info → Build Configuration: Release
```
- Full optimization
- No debug symbols
- Production performance

### Profiling

Use Instruments to analyze performance:

```
Product → Profile (⌘I)
```

Recommended instruments:
- **Time Profiler**: CPU usage
- **Allocations**: Memory usage
- **Core Animation**: FPS and rendering

---

## Testing

### Unit Tests

Run all tests:
```
Product → Test (⌘U)
```

### Manual Testing Checklist

- [ ] Timeline scrolls smoothly
- [ ] Date selection works
- [ ] Moon phase renders correctly
- [ ] Phase information is accurate
- [ ] Moonrise/moonset times are reasonable
- [ ] Arrakis view opens and closes
- [ ] Dynamic moon emoji matches phase
- [ ] Location permission request appears
- [ ] App works offline (except location)

---

## Deployment

### TestFlight (Beta Testing)

1. Archive the app:
   ```
   Product → Archive
   ```

2. In Organizer window:
   - Select archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Follow prompts

3. In App Store Connect:
   - Add beta testers
   - Submit for beta review

### App Store Release

1. Archive as above
2. Submit for App Store review
3. Fill out App Store metadata
4. Wait for approval (~24-48 hours)

---

## Continuous Integration

### GitHub Actions Example

Create `.github/workflows/ios.yml`:

```yaml
name: iOS Build

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Build
      run: |
        xcodebuild clean build \
          -project Lithium.xcodeproj \
          -scheme Lithium \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

    - name: Test
      run: |
        xcodebuild test \
          -project Lithium.xcodeproj \
          -scheme Lithium \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

---

## Development Tips

### Hot Reload

SwiftUI supports live previews:
- Make code changes
- Preview updates automatically
- No need to rebuild

### Quick Actions

- **⌘B**: Build
- **⌘R**: Run
- **⌘.**: Stop
- **⌘⇧K**: Clean build folder
- **⌘⌥⏎**: Show Preview Canvas
- **⌘⌥P**: Resume Preview

### Useful Xcode Features

- **Assistant Editor**: Side-by-side view (⌘⌃⌥⏎)
- **Jump to Definition**: ⌘-click on symbol
- **Find in Project**: ⌘⇧F
- **Quick Open**: ⌘⇧O

---

## Troubleshooting

### App Crashes on Launch

1. Check console for error messages
2. Verify Info.plist is correct
3. Clean build folder (⌘⇧K)
4. Delete derived data:
   ```
   ~/Library/Developer/Xcode/DerivedData
   ```

### Location Not Updating

1. Check location permissions in Settings app
2. Verify `LocationManager` is initialized
3. Test with custom location in simulator

### UI Not Updating

1. Verify `@State` and `@Binding` are used correctly
2. Check `.id()` modifiers for forced updates
3. Ensure calculations are on main thread

---

## Resources

### Official Documentation

- [Apple Developer](https://developer.apple.com)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Xcode Documentation](https://developer.apple.com/documentation/xcode)

### Community

- [Swift Forums](https://forums.swift.org)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/swiftui)
- [r/iOSProgramming](https://reddit.com/r/iOSProgramming)

### Learning Resources

- [Hacking with Swift](https://www.hackingwithswift.com)
- [Ray Wenderlich](https://www.raywenderlich.com)
- [Apple SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

---

## Getting Help

If you encounter issues:

1. Check this documentation
2. Search existing GitHub issues
3. Create a new issue with:
   - Xcode version
   - iOS version
   - Steps to reproduce
   - Error messages/screenshots

---

## Next Steps

After successful build:

1. Explore the code
2. Modify moon phase calculations
3. Customize the Arrakis poster design
4. Add new features
5. Submit pull requests!

Happy coding! 🚀🌙
