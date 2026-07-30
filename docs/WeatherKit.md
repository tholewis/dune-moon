---
title: "WeatherKit Integration"
description: "How Dune Moon uses Apple WeatherKit for the moon phase and moonrise/moonset, including the New/Full refinement, local fallback, requirements, and attribution"
category: "technical-reference"
version: "1.2.0"
last_updated: "2026-06-15"
tags: ["weatherkit", "moonrise", "moonset", "location", "ios", "fallback"]
audience: "developers"
platform: "iOS 17.0+"
---

# WeatherKit Integration

## Overview

Dune Moon uses Apple's **WeatherKit** framework as the primary source for the
**moon phase and moonrise/moonset times of the selected date**. WeatherKit returns
location-accurate lunar data computed by Apple's weather service — the same data the
Apple Weather app shows — which is more accurate than the app's own approximate
astronomical calculation.

For the **selected date**, WeatherKit provides the phase name and emoji (so they match
Apple Weather) plus moonrise/moonset. The local
[`MoonPhaseCalculator`](MoonPhaseCalculation.md) supplies everything WeatherKit does
not — the illumination percentage and the "days to next phase" countdown — and serves
as the **fallback** for the phase and rise/set whenever WeatherKit is unavailable
(offline, not entitled, or for dates outside its forecast window). The calendar grid
and timeline (which show many dates, mostly outside WeatherKit's ~10-day window) always
use the local calculation.

> **Why a hybrid?** WeatherKit's moon data is limited: it exposes only `moonrise`,
> `moonset`, and an 8-value `MoonPhase` enum (no continuous phase fraction and no
> illumination percentage), its daily forecast only covers roughly 10 days from the
> current day, and it requires network access plus an entitlement. The local
> calculator covers any date offline and supplies illumination. Combining them keeps
> the app's strengths while matching Apple Weather for the selected date.

## What WeatherKit provides

| Data | Source | Notes |
|------|--------|-------|
| Phase name + emoji (selected date) | `MoonEvents.phase` (`MoonPhase` enum) | Matches Apple Weather; falls back to local |
| Moonrise time | `MoonEvents.moonrise` | `Date?` — may be `nil` on days with no moonrise |
| Moonset time | `MoonEvents.moonset` | `Date?` — may be `nil` on days with no moonset |
| Illumination %, days-to-next-phase | `MoonPhaseCalculator` (local) | Not provided by WeatherKit |
| Phase for calendar/timeline dates | `MoonPhaseCalculator` (local) | Mostly outside WeatherKit's window |

## How it works

### Data layer: `WeatherMoonService`

`WeatherMoonService` is a `@MainActor` `ObservableObject` that wraps the shared
`WeatherService`. It fetches the daily forecast for a coordinate, finds the
`DayWeather` matching the requested day, and returns a `WeatherMoon` snapshot (phase
name/emoji, waxing flag, moonrise/moonset). Results are cached by rounded coordinate
and day. Any failure (offline, out of forecast range, or not entitled) returns `nil`
so the caller can fall back to the local calculation.

```swift
let forecast = try await service.weather(for: location, including: .daily) // ~10 days
guard let match = forecast.first(where: {
    calendar.isDate($0.date, inSameDayAs: day)
}) else { return nil } // Requested day is outside WeatherKit's forecast window.

return WeatherMoon(
    rise: match.moon.moonrise,
    set: match.moon.moonset,
    phaseName: match.moon.phase.displayName,   // e.g. "Waxing Crescent"
    phaseEmoji: match.moon.phase.emoji,        // e.g. "🌒"
    isWaxing: match.moon.phase.isWaxing,
    // New/Full are whole-day labels; flagged so callers can refine them (see below).
    isNewOrFull: match.moon.phase == .new || match.moon.phase == .full
)
```

### Daily vs. instantaneous phase (the New/Full refinement)

WeatherKit's `MoonPhase` is a **per-day** label: it calls the *entire* new-moon day
"New Moon", even though the instantaneous phase is already a thin **waxing crescent**
a few hours after the exact instant — which is what Apple Weather's *headline* shows.
To match that headline, `applyingWeatherKit(_:)` uses WeatherKit's label for every
phase **except** New/Full, where it keeps the time-accurate local classification:

```swift
extension MoonPhaseData {
    func applyingWeatherKit(_ wk: WeatherMoon) -> MoonPhaseData {
        guard !wk.isNewOrFull else {
            return self // Keep the instantaneous local phase for the New/Full instant.
        }
        var copy = self
        copy.phaseNameOverride = wk.phaseName
        copy.emojiOverride = wk.phaseEmoji
        copy.isWaxingOverride = wk.isWaxing
        return copy
    }
}
```

So a new-moon day reads as "Waxing Crescent" once past the instant (matching Apple
Weather), while crescent/gibbous/quarter days use WeatherKit's authoritative label.

### View layer

`ContentView` (main display + Arrakis view) and `PhaseInfoPanel` each compute the
local phase, then apply the WeatherKit override for the selected date inside a `.task`:

```swift
private var phaseData: MoonPhaseData {
    let data = MoonPhaseCalculator.calculatePhase(for: selectedDate)
    if let wk = wkMoon { return data.applyingWeatherKit(wk) }
    return data // local fallback (offline / out of range / not entitled)
}

// Fetched in a .task keyed on the date + resolved location:
wkMoon = await weatherMoon.moon(for: selectedDate, at: locationManager.coordinate)
```

Illumination and the next-phase countdown always come from the local calculation
(WeatherKit provides neither). Moonrise/moonset use `wkMoon` when present, otherwise
`MoonPhaseCalculator.calculateMoonTimes`. The location comes from the existing
[`LocationManager`](Architecture.md#locationmanager-observable-object); if location is
unavailable it falls back to a default coordinate. The calendar grid and timeline are
not overridden — they always use the local calculation.

## Attribution (required)

WeatherKit **requires** that the Apple Weather trademark and a link to Apple's legal
attribution page be displayed wherever its data is shown. `WeatherMoonService`
fetches `WeatherService.shared.attribution` the first time WeatherKit data is used,
and `WeatherAttributionView` renders the combined Apple Weather mark (linking to
`legalPageURL`) beneath the moonrise/moonset cards. The mark is shown **only** when
WeatherKit times are actually displayed — a purely-offline run that shows only local
times displays no Apple mark.

## Requirements

WeatherKit needs two separate switches enabled, both of which require a **paid Apple
Developer Program membership**:

1. **WeatherKit service on the App ID** — in the Apple Developer portal, enable the
   WeatherKit service/capability for the explicit App ID (`AlienArchitecture.DuneMoon`).
   WeatherKit cannot run on a wildcard App ID.
2. **WeatherKit entitlement in Xcode** — add the **WeatherKit** capability under the
   target's *Signing & Capabilities*. This writes `com.apple.developer.weatherkit`
   (`true`) to `DuneMoon/DuneMoon.entitlements`. No API key or token is stored in the
   app; native WeatherKit authenticates via this entitlement.

Additional requirements:

- **iOS 16.0+** for WeatherKit (the app targets iOS 17.0+).
- **Network connectivity** at runtime.
- Service activation is asynchronous and can take up to ~30 minutes to propagate
  after enabling it on the App ID. Until then, calls fail and the app uses the local
  fallback.

### Diagnosing failures

`WeatherMoonService` logs to the unified log (subsystem `AlienArchitecture.DuneMoon`,
category `WeatherKit`). A repeated JWT error such as:

```
[AuthService] Failed to generate jwt token for: com.apple.weatherkit.authservice ... Code=2
```

means the App ID is not yet authorized for WeatherKit (service not enabled or not yet
propagated). Success logs `WeatherKit moon: phase ..., rise ..., set ...` and the Apple
Weather attribution mark appears.

## Behavior summary

| Situation | Phase shown | Moonrise/Moonset shown | Attribution mark |
|-----------|-------------|------------------------|------------------|
| WeatherKit available, crescent/gibbous/quarter day | WeatherKit label | WeatherKit (location-accurate) | Shown |
| WeatherKit available, New/Full day | Instantaneous local (refined) | WeatherKit (location-accurate) | Shown |
| Offline / not entitled / propagation pending | Local `MoonPhaseCalculator` | Local `MoonPhaseCalculator` | Hidden |
| Date outside WeatherKit's ~10-day window | Local `MoonPhaseCalculator` | Local `MoonPhaseCalculator` | Hidden |

## Related documentation

- [Moon Phase Calculation](MoonPhaseCalculation.md) — the local algorithms, including
  the `calculateMoonTimes` fallback.
- [Architecture Guide](Architecture.md) — data flow and where `WeatherMoonService`
  fits.
- [Apple WeatherKit documentation](https://developer.apple.com/documentation/weatherkit) —
  official framework reference.
- [Apple Weather data source attribution](https://developer.apple.com/weatherkit/data-source-attribution/) —
  attribution requirements.
