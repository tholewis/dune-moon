---
title: "UI Components Documentation"
description: "Complete reference for all SwiftUI views, layouts, and design system elements in Lithium"
category: "ui-reference"
version: "1.0.0"
last_updated: "2026-04-07"
tags: ["swiftui", "ui", "components", "views", "design-system"]
audience: "developers"
---

# UI Components Documentation

## Overview

Lithium's user interface is built entirely with SwiftUI, featuring custom components for moon visualization, timeline navigation, and an immersive poster view.

## Main Views

### ContentView.swift

**Purpose**: Primary container view that orchestrates the entire UI

**Key State:**
```swift
@State private var selectedDate: Date
@State private var currentDate: Date
@State private var showArrakis: Bool
@State private var dragOffset: CGFloat
```

**Layout Structure:**
```
VStack
├── Header (Title + Arrakis Button)
├── MoonPhaseView
├── PhaseInfoPanel
└── TimelineView
```

**Features:**
- Manages global app state
- Coordinates data flow between child views
- Presents Arrakis view as modal sheet

---

### MoonPhaseView.swift

**Purpose**: Renders the visual moon with accurate phase shading

**Parameters:**
```swift
let phaseData: MoonPhaseData
let size: CGFloat
```

**Implementation:**
Uses SwiftUI `Canvas` to draw:
1. Base circle (moon body)
2. MoonShadowShape (phase shadow overlay)

**Drawing Logic:**
```swift
Canvas { context, size in
    // Draw full moon circle
    context.fill(circlePath, with: .color(.moonLight))

    // Draw phase shadow
    context.fill(shadowPath, with: .color(.moonShadow))
}
```

**MoonShadowShape:**
Custom `Shape` protocol implementation that calculates shadow path based on phase value (0.0-1.0):
- Phase < 0.5: Waxing (shadow on right)
- Phase > 0.5: Waning (shadow on left)
- Phase ≈ 0.0 or 1.0: Full shadow (new moon)

---

### TimelineView.swift

**Purpose**: Horizontal scrollable timeline for date selection

**Binding:**
```swift
@Binding var selectedDate: Date
@Binding var dragOffset: CGFloat
```

**Layout:**
```
ScrollView(.horizontal)
└── HStack
    └── ForEach(-15...15) { offset in
        DateButton(date, isSelected, isToday)
    }
```

**Gestures:**
- DragGesture for smooth scrolling
- TapGesture for date selection
- Automatic centering animation

**Day Button Components:**
- Day of week label (Mon, Tue, etc.)
- Date number
- Selection indicator (circle)
- Today indicator (colored background)

---

### PhaseInfoPanel.swift

**Purpose**: Displays detailed moon phase information

**Data Sources:**
- `MoonPhaseCalculator.calculatePhaseData(for:)`
- `LocationManager` for GPS coordinates
- `MoonPhaseCalculator.calculateMoonTimes(for:latitude:longitude:)`

**Layout:**
```
VStack
├── HStack (Phase name + Illumination badges)
├── Text (Next phase info)
└── HStack (Moonrise + Moonset times)
```

**StatBadge Component:**
Reusable badge displaying:
- Label (e.g., "Phase")
- Value (e.g., "Full Moon")
- Icon (optional)

**Location Integration:**
```swift
@StateObject private var locationManager = LocationManager()

private var moonTimes: (rise: Date?, set: Date?) {
    let coord = locationManager.coordinate
    return MoonPhaseCalculator.calculateMoonTimes(
        for: date,
        latitude: coord.latitude,
        longitude: coord.longitude
    )
}
```

---

### ArrakisMoonView.swift

**Purpose**: Fullscreen immersive poster experience

**Key Features:**
1. **Background Image**: Vintage Dune poster artwork
2. **Dynamic Moon Emoji**: Updates based on phase
3. **Info Section**: Phase details on cream background

**Moon Emoji Selection:**
```swift
private var moonEmoji: String {
    let phase = phaseData.phase

    if phase < 0.05 || phase > 0.95 {
        return "🌑"  // New Moon
    } else if phase < 0.20 {
        return "🌒"  // Waxing Crescent
    } else if phase < 0.30 {
        return "🌓"  // First Quarter
    } // ... etc
}
```

**Layout Layers:**
```
GeometryReader
└── ZStack
    ├── Image("ArrakisPoster")         // Background
    ├── Text(moonEmoji)                 // Dynamic moon (size 200)
    └── VStack                          // Info section
        ├── Text("ARRAKIS")
        ├── Text(phaseName)
        ├── HStack (Illumination % + Phase)
        └── Text("TAP ANYWHERE TO RETURN")
```

**Design Details:**
- Cream background extends to screen bottom
- Info section has proper top padding
- Phase name supports multiline (e.g., "WAXING GIBBOUS")
- Illumination shows percentage symbol ("50%")

---

## Supporting Components

### SpiceGlowEffect.swift

**Purpose**: Custom visual effect modifier for glowing elements

**Usage:**
```swift
Text("ARRAKIS")
    .modifier(SpiceGlowEffect())
```

**Implementation:**
Adds subtle shadow and glow to create depth and emphasis on key UI elements.

---

### CalendarGridView.swift

**Purpose**: Calendar utility functions (currently minimal)

**Functions:**
- Date arithmetic helpers
- Calendar grid layout calculations (if needed for future calendar view)

---

## Custom Shapes

### MoonShadowShape

Draws the moon's phase shadow:

```swift
struct MoonShadowShape: Shape {
    let phase: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        // Calculate shadow based on phase
        // ... geometric calculations ...

        return path
    }
}
```

---

## Color Palette

### Main Interface

```swift
Color(red: 0.10, green: 0.08, blue: 0.15)  // Background
Color(red: 0.95, green: 0.93, blue: 0.88)  // Moon light
Color(red: 0.15, green: 0.12, blue: 0.18)  // Moon shadow
Color(red: 0.92, green: 0.65, blue: 0.38)  // Accent (spice)
```

### Arrakis View

```swift
Color(red: 0.96, green: 0.94, blue: 0.90)  // Cream background
Color(red: 0.25, green: 0.20, blue: 0.15)  // Text (dark brown)
Color(red: 0.40, green: 0.32, blue: 0.25)  // Subtitle brown
Color(red: 0.45, green: 0.35, blue: 0.28)  // Divider/borders
```

---

## Typography

### Main Interface
- **Title**: System, size 34, weight .bold
- **Phase Name**: System, size 20, weight .semibold
- **Body Text**: System, size 16, weight .regular

### Arrakis View (Serif)
- **ARRAKIS**: size 44, weight .black, design .serif, kerning 6
- **Phase Name**: size 14, weight .bold, design .serif, kerning 3
- **Info Values**: size 28, weight .black, design .serif
- **Labels**: size 9, weight .black, design .serif, kerning 1

---

## Animations

### Timeline Scrolling
```swift
.animation(.spring(response: 0.3, dampingFraction: 0.7),
           value: selectedDate)
```

### Sheet Presentation
```swift
.sheet(isPresented: $showArrakis) {
    ArrakisMoonView(phaseData: phaseData)
        .transition(.move(edge: .bottom))
}
```

### View Updates
```swift
.id(selectedDate)  // Forces view refresh when date changes
```

---

## Accessibility

### VoiceOver Support

All interactive elements have accessibility labels:

```swift
Button("View Arrakis Lunar Observatory") {
    showArrakis = true
}
.accessibilityLabel("Show Arrakis poster view")

Text(moonEmoji)
    .accessibilityLabel("\(phaseData.phaseName) moon")
```

### Dynamic Type

All text respects user's preferred text size settings.

### Color Contrast

All text maintains WCAG AA contrast ratios:
- Light text on dark background: 7:1
- Dark text on light background: 8:1

---

## Layout Responsiveness

### Adaptive Sizing

- MoonPhaseView size: 240pt (scales with screen)
- Timeline item width: 60pt fixed
- Arrakis moon emoji: 200pt font size
- Info section: fluid width with fixed padding

### Safe Areas

```swift
.ignoresSafeArea()  // For fullscreen poster
.safeAreaInset(edge: .bottom) { ... }  // For proper insets
```

### Device Support

Tested on:
- iPhone SE (small screen)
- iPhone 15 Pro (standard)
- iPhone 15 Plus (large screen)
- iPad (adaptive layout)

---

## Preview Providers

Every view includes SwiftUI previews:

```swift
#Preview {
    ContentView()
}

#Preview {
    ArrakisMoonView(
        phaseData: MoonPhaseData(
            phase: 0.25,
            illumination: 50,
            phaseName: "First Quarter",
            isWaxing: true,
            daysToNextPhase: 7,
            nextPhaseName: "Full Moon"
        )
    )
}
```

---

## Future UI Enhancements

Potential improvements:

1. **Haptic Feedback**: Subtle vibrations on date selection
2. **3D Moon Model**: SceneKit or RealityKit rendering
3. **Dark Mode**: Full dark/light mode support
4. **Widgets**: Home screen and lock screen widgets
5. **Complications**: Apple Watch complications
6. **Animations**: Moon phase transition animations
7. **Share Sheet**: Share moon phase as image
