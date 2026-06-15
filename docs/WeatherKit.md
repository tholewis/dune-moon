---
title: "WeatherKit Integration"
description: "How Dune Moon uses Apple WeatherKit for moonrise/moonset times, including the local fallback, requirements, and attribution"
category: "technical-reference"
version: "1.1.0"
last_updated: "2026-06-15"
tags: ["weatherkit", "moonrise", "moonset", "location", "ios", "fallback"]
audience: "developers"
platform: "iOS 17.0+"
---

# WeatherKit Integration

## Overview

Dune Moon uses Apple's **WeatherKit** framework as the primary source for
**moonrise and moonset times**. WeatherKit returns location-accurate lunar event
times computed by Apple's weather service, which are more accurate than the app's
own approximate astronomical calculation.

WeatherKit is used **only** for moonrise/moonset. Everything else — the moon phase
value, illumination percentage, phase name, emoji, waxing/waning status, and the
"days to next phase" countdown — continues to come from the local
[`MoonPhaseCalculator`](MoonPhaseCalculation.md), which is instant, works offline,
and works for any date.

> **Why a hybrid?** WeatherKit's moon data is limited: it exposes only `moonrise`,
> `moonset`, and an 8-value `MoonPhase` enum (no continuous phase fraction and no
> illumination percentage), its daily forecast only covers roughly 10 days from the
> current day, and it requires network access plus an entitlement. The local
> calculator covers any date offline. Combining them keeps the app's strengths while
> upgrading the one metric WeatherKit does better.

## What WeatherKit provides

| Data | Source | Notes |
|------|--------|-------|
| Moonrise time | `MoonEvents.moonrise` | `Date?` — may be `nil` on days with no moonrise |
| Moonset time | `MoonEvents.moonset` | `Date?` — may be `nil` on days with no moonset |
| Moon phase, illumination, phase name, emoji, next phase | `MoonPhaseCalculator` (local) | Not sourced from WeatherKit |

## How it works

### Data layer: `WeatherMoonService`

`WeatherMoonService` is a `@MainActor` `ObservableObject` that wraps the shared
`WeatherService`. It fetches the daily forecast for a coordinate, finds the
`DayWeather` matching the requested day, and returns its moonrise/moonset. Results
are cached by rounded coordinate and day. Any failure (offline, out of forecast
range, or not entitled) returns `nil` so the caller can fall back.

```swift
import WeatherKit
import CoreLocation

@MainActor
final class WeatherMoonService: ObservableObject {
    private let service = WeatherService.shared

    /// Returns moonrise/moonset for `date` at `coordinate`, or `nil` if WeatherKit
    /// can't supply it. Results are cached.
    func moonTimes(
        for date: Date,
        at coordinate: CLLocationCoordinate2D
    ) async -> (rise: Date?, set: Date?)? {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        do {
            // `.daily` returns ~10 contiguous days starting today.
            let forecast = try await service.weather(for: location, including: .daily)
            guard let match = forecast.first(where: {
                calendar.isDate($0.date, inSameDayAs: day)
            }) else {
                return nil // Requested day is outside WeatherKit's forecast window.
            }
            return (rise: match.moon.moonrise, set: match.moon.moonset)
        } catch {
            return nil // Offline or not entitled — caller falls back to the local calc.
        }
    }
}
```

### View layer: `PhaseInfoPanel` with local fallback

`PhaseInfoPanel` seeds the moonrise/moonset cards **immediately** with the local
calculation so they are never blank, then upgrades to WeatherKit values inside a
`.task` when they are available. The task re-runs when the selected date or the
resolved location changes.

```swift
// Seed with the local calculation (instant, offline, any date).
moonTimes = MoonPhaseCalculator.calculateMoonTimes(
    for: date,
    latitude: coordinate.latitude,
    longitude: coordinate.longitude
)

// Upgrade to WeatherKit's location-accurate times when available.
if let weatherTimes = await weatherMoon.moonTimes(for: date, at: coordinate) {
    moonTimes = weatherTimes      // WeatherKit succeeded
    usingWeatherKit = true        // triggers the attribution mark
}
```

The user's location comes from the existing
[`LocationManager`](Architecture.md#locationmanager-observable-object); if location is
unavailable it falls back to a default coordinate.

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
propagated). Success logs `WeatherKit moon times: rise ..., set ...` and the Apple
Weather attribution mark appears.

## Behavior summary

| Situation | Moonrise/Moonset shown | Attribution mark |
|-----------|------------------------|------------------|
| WeatherKit entitled, online, date in range | WeatherKit (location-accurate) | Shown |
| Offline / not entitled / propagation pending | Local `MoonPhaseCalculator` | Hidden |
| Date outside WeatherKit's ~10-day window | Local `MoonPhaseCalculator` | Hidden |

## Related documentation

- [Moon Phase Calculation](MoonPhaseCalculation.md) — the local algorithms, including
  the `calculateMoonTimes` fallback.
- [Architecture Guide](Architecture.md) — data flow and where `WeatherMoonService`
  fits.
- [Apple WeatherKit documentation](https://developer.apple.com/documentation/weatherkit) —
  official framework reference.
- [Apple Weather data source attribution](https://developer.apple.com/weatherkit/data-source-attribution/) —
  attribution requirements.
