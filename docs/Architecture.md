---
title: "Dune Moon Architecture Guide"
description: "Comprehensive guide to Dune Moon's SwiftUI architecture, design patterns, and data flow"
category: "architecture"
version: "1.1.0"
last_updated: "2026-06-15"
tags: ["swiftui", "mvvm", "architecture", "design-patterns"]
audience: "developers"
---

# Dune Moon Architecture Guide

## Overview

Dune Moon follows a clean SwiftUI architecture with reactive state management and separation of concerns. The app is structured around a single-page interface with modal presentations and leverages SwiftUI's declarative syntax for UI composition.

## Design Patterns

### MVVM (Model-View-ViewModel)

While SwiftUI doesn't require traditional MVVM, Dune Moon organizes code following similar principles:

- **Models**: `MoonPhaseData` struct containing phase information
- **Views**: SwiftUI views (`ContentView`, `MoonPhaseView`, etc.)
- **Logic**: Separated into calculators and managers (`MoonPhaseCalculator`, `LocationManager`)

### Separation of Concerns

Each file has a single, well-defined responsibility:

| File | Responsibility |
|------|---------------|
| `DuneMoonApp.swift` | App lifecycle and entry point |
| `ContentView.swift` | Main UI composition and state coordination |
| `MoonPhaseCalculator.swift` | All astronomical calculations (phase data + fallback moonrise/moonset) |
| `WeatherMoonService.swift` | WeatherKit moonrise/moonset fetching, caching, and attribution |
| `LocationManager.swift` | GPS and location services |
| `TimelineView.swift` | Date selection and navigation |
| `PhaseInfoPanel.swift` | Information display |
| `ArrakisMoonView.swift` | Fullscreen poster experience |

## Data Flow

### State Management

```
┌──────────────────┐
│  ContentView     │
│  @State          │
├──────────────────┤
│ selectedDate     │────┐
│ currentDate      │    │
│ dragOffset       │    │
└──────────────────┘    │
                        │ Derives
                        ▼
              ┌──────────────────┐
              │  phaseData       │
              │  (computed)      │
              └──────────────────┘
                        │
                        │ Passed to
                        ▼
         ┌──────────────┬──────────────┐
         │              │              │
    ┌────▼─────┐   ┌───▼────┐   ┌────▼──────┐
    │ MoonPhase│   │ Phase  │   │  Arrakis  │
    │   View   │   │ Info   │   │  MoonView │
    └──────────┘   └────────┘   └───────────┘
```

### Data Model

```swift
struct MoonPhaseData {
    let phase: Double              // 0.0 to 1.0
    let illumination: Double       // Percentage
    let phaseName: String         // "Full Moon", etc.
    let isWaxing: Bool
    let daysToNextPhase: Int
    let nextPhaseName: String
}
```

## View Hierarchy

```
LithiumApp
└── ContentView
    ├── VStack
    │   ├── HStack (Header)
    │   │   ├── Text (Title)
    │   │   ├── Spacer
    │   │   └── Button (Arrakis)
    │   │
    │   ├── MoonPhaseView
    │   │   └── Canvas (Custom drawing)
    │   │
    │   ├── PhaseInfoPanel
    │   │   ├── HStack (Phase info)
    │   │   └── VStack (Times)
    │   │
    │   └── TimelineView
    │       └── ScrollView
    │           └── HStack (Days)
    │
    └── .sheet (ArrakisMoonView)
        ├── GeometryReader
        │   ├── Image (Poster)
        │   ├── Text (Moon emoji)
        │   └── VStack (Info)
```

## Component Communication

### Parent-to-Child (Props Down)

Views receive data through initialization parameters:

```swift
MoonPhaseView(phaseData: phaseData, size: 240)
PhaseInfoPanel(date: selectedDate)
ArrakisMoonView(phaseData: phaseData)
```

### Child-to-Parent (Callbacks Up)

Environment values and bindings flow data upward:

```swift
@Environment(\.dismiss) var dismiss  // ArrakisMoonView → dismiss action
```

### Sibling Communication

Siblings communicate through shared state in the parent (`ContentView`):

```swift
@State private var selectedDate: Date  // Shared between Timeline and PhaseInfo
```

## State Lifecycle

### 1. App Launch
```
LithiumApp.init()
  └── ContentView.init()
      ├── selectedDate = Date()
      ├── currentDate = Date()
      └── Compute phaseData
```

### 2. Date Selection
```
User taps timeline
  └── TimelineView updates selectedDate
      └── ContentView recomputes phaseData
          ├── MoonPhaseView updates
          ├── PhaseInfoPanel updates
          └── UI refreshes
```

### 3. Arrakis View
```
User taps button
  └── showArrakis = true
      └── .sheet presents ArrakisMoonView
          └── Receives phaseData snapshot
```

## Calculation Architecture

### MoonPhaseCalculator (Static Methods)

```
calculatePhaseData(for: Date) → MoonPhaseData
├── daysBetween(from:to:) → Double
├── calculateIllumination(phase:) → Double
├── calculatePhaseName(phase:) → String
├── isWaxing(phase:) → Bool
└── calculateNextPhase(from:phase:) → (Int, String)

calculateMoonTimes(for:latitude:longitude:) → (rise: Date?, set: Date?)
├── julianDate(from:) → Double
├── moonEclipticCoordinates(jd:) → (λ, β)
├── eclipticToEquatorial(λ:β:ε:) → (α, δ)
├── localSiderealTime(jd:longitude:) → Double
└── hourAngleForRiseSet(dec:lat:) → Double?
```

### LocationManager (Observable Object)

```
LocationManager
├── @Published location: CLLocationCoordinate2D?
├── coordinate (computed) → CLLocationCoordinate2D
├── requestLocation()
└── locationManager(_:didUpdateLocations:)
```

### WeatherMoonService (Observable Object, @MainActor)

Primary source for moonrise/moonset via Apple WeatherKit, with the local
`MoonPhaseCalculator.calculateMoonTimes` used as a fallback in `PhaseInfoPanel`.

```
WeatherMoonService
├── moonTimes(for:at:) async → (rise: Date?, set: Date?)?   // nil ⇒ caller falls back
├── @Published attribution: WeatherAttribution?              // required Apple Weather mark
└── cache: [coordinate+day → times]
```

`PhaseInfoPanel` seeds the cards with the local calculation, then upgrades to
WeatherKit values inside a `.task` when available. See
[WeatherKit Integration](WeatherKit.md) for the full data flow and requirements.

## Memory Management

### Efficient State Updates

- **Computed properties** recalculate only when dependencies change
- **@State** triggers minimal view updates
- **Lazy evaluation** in timeline day generation

### Resource Cleanup

- Canvas drawings are GPU-accelerated
- Image assets loaded on-demand
- Location manager stops updates when not needed

## Performance Optimizations

### 1. View Rendering

```swift
.id(selectedDate)  // Forces view refresh when date changes
```

### 2. Lazy Timeline Loading

Timeline generates only visible days plus buffer:

```swift
ForEach(-15...15, id: \.self) { offset in
    // Only 31 days rendered at a time
}
```

### 3. Calculation Caching

Phase data computed once per date change, not per frame.

## Testing Architecture

### Unit Test Targets

- **MoonPhaseCalculator Tests**: Verify astronomical accuracy
- **Date Utilities Tests**: Edge cases (leap years, etc.)
- **Phase Boundary Tests**: Ensure correct phase transitions

### Preview Providers

Each view includes `#Preview` with sample data:

```swift
#Preview {
    ContentView()
}

#Preview {
    ArrakisMoonView(phaseData: MoonPhaseData(...))
}
```

## Error Handling

### Location Services

```swift
func locationManager(_ manager: CLLocationManager,
                    didFailWithError error: Error) {
    // Falls back to San Francisco coordinates
    print("Location error: \(error.localizedDescription)")
}
```

### Date Calculations

- Defensive programming with fallback values
- Optional returns for moonrise/moonset (may not occur on certain days)

## Scalability Considerations

### Adding New Features

1. **New Phase Info**: Extend `MoonPhaseData` struct
2. **New Calculations**: Add static methods to `MoonPhaseCalculator`
3. **New UI Elements**: Create separate view files
4. **New Screens**: Add sheet/fullScreenCover in `ContentView`

### Internationalization

Ready for localization:
- All strings are extractable
- Date formatters respect locale
- Numbers use proper locale formatting

## Security & Privacy

### Location Privacy

- Uses `NSLocationWhenInUseUsageDescription`
- Requests location only when needed
- Falls back gracefully without location

### Data Storage

- No persistent storage (stateless app)
- No user data collected or stored

### Network

- The only network use is **Apple WeatherKit**, queried for moonrise/moonset times
  using the device's location. No user data is sent to any other service.
- WeatherKit authenticates via the `com.apple.developer.weatherkit` entitlement —
  no API keys or tokens are stored in the app.
- All other features (phase, illumination, emoji, calendar, timeline) work fully
  offline; WeatherKit failures fall back to local calculation.

## Build Configuration

### Debug vs Release

```swift
#if DEBUG
// Preview-only code
#endif
```

### Deployment Targets

- Minimum: iOS 15.0
- Recommended: iOS 17.0+
- Architecture: arm64 (Apple Silicon optimized)

## Future Architecture Improvements

### Potential Enhancements

1. **Data Persistence**: Add UserDefaults for favorite dates
2. **Notifications**: Alert for specific moon phases
3. **Widgets**: Home screen moon phase widget
4. **Watch App**: Complications for watch faces
5. **Analytics**: Track feature usage
6. **Accessibility**: VoiceOver improvements

## Conclusion

Lithium's architecture emphasizes:
- **Simplicity**: Clear responsibilities
- **Reactivity**: SwiftUI state-driven updates
- **Performance**: Efficient calculations and rendering
- **Maintainability**: Well-organized, documented code
