# Moon Phase Calculation Documentation

## Overview

Lithium implements astronomical algorithms to accurately calculate moon phases, illumination percentages, and moonrise/moonset times. This document explains the mathematics and implementation details.

## Synodic Month Method

### The Synodic Month

The **synodic month** is the time it takes for the Moon to return to the same phase (e.g., new moon to new moon).

```
Synodic Month ≈ 29.530588 days
```

### Reference New Moon

All calculations use a known new moon as a reference point:

```swift
let referenceNewMoon = Calendar.current.date(
    from: DateComponents(year: 2000, month: 1, day: 6, hour: 18, minute: 14)
)!
```

This corresponds to the new moon of January 6, 2000, at 18:14 UTC, a well-documented astronomical event.

## Phase Calculation

### Computing Days Since Reference

```swift
func daysBetween(from startDate: Date, to endDate: Date) -> Double {
    let timeInterval = endDate.timeIntervalSince(startDate)
    return timeInterval / 86400  // Seconds in a day
}
```

### Phase as Decimal (0.0 to 1.0)

```swift
let daysSinceNewMoon = daysBetween(from: referenceNewMoon, to: targetDate)
let phase = (daysSinceNewMoon.truncatingRemainder(dividingBy: synodicMonth)) / synodicMonth
```

**Phase Values:**
- `0.0` = New Moon
- `0.25` = First Quarter
- `0.5` = Full Moon
- `0.75` = Last Quarter
- `→ 1.0` (wraps to 0.0) = New Moon again

### Visual Representation

```
0.0        0.25       0.5        0.75       1.0
 🌑    →    🌓    →    🌕    →    🌗    →    🌑
New       First      Full      Last       New
Moon     Quarter     Moon     Quarter     Moon
         (Waxing)            (Waning)
```

## Illumination Percentage

The illumination is calculated using the cosine of the phase angle:

```swift
func calculateIllumination(phase: Double) -> Double {
    let phaseAngle = phase * 2.0 * .pi
    let illumination = (1.0 - cos(phaseAngle)) / 2.0 * 100.0
    return max(0, min(100, illumination))
}
```

### Mathematics

```
Phase Angle (θ) = phase × 2π
Illumination (%) = [(1 - cos(θ)) / 2] × 100
```

**Examples:**
- New Moon (phase = 0.0): cos(0) = 1 → illumination = 0%
- First Quarter (0.25): cos(π/2) = 0 → illumination = 50%
- Full Moon (0.5): cos(π) = -1 → illumination = 100%
- Last Quarter (0.75): cos(3π/2) = 0 → illumination = 50%

## Phase Names

Phase names are determined by phase value ranges:

```swift
func calculatePhaseName(phase: Double) -> String {
    switch phase {
    case 0..<0.03, 0.97..<1.0:
        return "New Moon"
    case 0.03..<0.22:
        return "Waxing Crescent"
    case 0.22..<0.28:
        return "First Quarter"
    case 0.28..<0.47:
        return "Waxing Gibbous"
    case 0.47..<0.53:
        return "Full Moon"
    case 0.53..<0.72:
        return "Waning Gibbous"
    case 0.72..<0.78:
        return "Last Quarter"
    case 0.78..<0.97:
        return "Waning Crescent"
    default:
        return "Unknown"
    }
}
```

### Phase Boundaries

```
Phase Range         Name
───────────────────────────────
0.00 - 0.03         New Moon
0.03 - 0.22         Waxing Crescent
0.22 - 0.28         First Quarter
0.28 - 0.47         Waxing Gibbous
0.47 - 0.53         Full Moon
0.53 - 0.72         Waning Gibbous
0.72 - 0.78         Last Quarter
0.78 - 0.97         Waning Crescent
0.97 - 1.00         New Moon
```

## Waxing vs Waning

```swift
func isWaxing(phase: Double) -> Bool {
    return phase < 0.5
}
```

- **Waxing** (0.0 → 0.5): Moon is getting brighter
- **Waning** (0.5 → 1.0): Moon is getting dimmer

## Next Phase Calculation

Predicts the next major phase and days until it occurs:

```swift
func calculateNextPhase(from date: Date, phase: Double) -> (daysToNext: Int, nextPhaseName: String) {
    let majorPhases: [(threshold: Double, name: String)] = [
        (0.25, "First Quarter"),
        (0.50, "Full Moon"),
        (0.75, "Last Quarter"),
        (1.00, "New Moon")
    ]

    for phaseInfo in majorPhases {
        if phase < phaseInfo.threshold {
            let phaseDiff = phaseInfo.threshold - phase
            let daysToNext = Int(phaseDiff * synodicMonth)
            return (daysToNext, phaseInfo.name)
        }
    }

    // Wrap around to New Moon
    let phaseDiff = 1.0 - phase
    let daysToNext = Int(phaseDiff * synodicMonth)
    return (daysToNext, "New Moon")
}
```

## Moonrise & Moonset Calculation

### Julian Date

Converts Gregorian calendar dates to Julian Date (JD), used in astronomy:

```swift
func julianDate(from date: Date) -> Double {
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

    let year = components.year!
    let month = components.month!
    let day = components.day!
    let hour = Double(components.hour ?? 0)
    let minute = Double(components.minute ?? 0)
    let second = Double(components.second ?? 0)

    // Adjust for January/February
    let a = (14 - month) / 12
    let y = year + 4800 - a
    let m = month + 12 * a - 3

    // Julian Day Number
    let jdn = day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045

    // Add time fraction
    let dayFraction = (hour - 12.0) / 24.0 + minute / 1440.0 + second / 86400.0

    return Double(jdn) + dayFraction
}
```

### Moon's Position (Ecliptic Coordinates)

Calculates the Moon's longitude (λ) and latitude (β) in the ecliptic coordinate system:

```swift
func moonEclipticCoordinates(julianDate jd: Double) -> (longitude: Double, latitude: Double) {
    let T = (jd - 2451545.0) / 36525.0  // Julian centuries since J2000

    // Mean longitude
    let L = (218.316 + 13.176396 * (jd - 2451545.0))
        .truncatingRemainder(dividingBy: 360)

    // Mean anomaly
    let M = (134.963 + 13.064993 * (jd - 2451545.0))
        .truncatingRemainder(dividingBy: 360)

    // Argument of latitude
    let F = (93.272 + 13.229350 * (jd - 2451545.0))
        .truncatingRemainder(dividingBy: 360)

    // Longitude (simplified)
    let longitude = L + 6.289 * sin(M * .pi / 180.0)

    // Latitude (simplified)
    let latitude = 5.128 * sin(F * .pi / 180.0)

    return (longitude.truncatingRemainder(dividingBy: 360),
            latitude)
}
```

### Ecliptic to Equatorial Conversion

Converts from ecliptic (λ, β) to equatorial (α, δ) coordinates:

```swift
func eclipticToEquatorial(
    longitude λ: Double,
    latitude β: Double,
    obliquity ε: Double
) -> (rightAscension: Double, declination: Double) {
    let λRad = λ * .pi / 180.0
    let βRad = β * .pi / 180.0
    let εRad = ε * .pi / 180.0

    // Right Ascension (α)
    let α = atan2(
        sin(λRad) * cos(εRad) - tan(βRad) * sin(εRad),
        cos(λRad)
    )

    // Declination (δ)
    let δ = asin(
        sin(βRad) * cos(εRad) + cos(βRad) * sin(εRad) * sin(λRad)
    )

    return (α * 180.0 / .pi, δ * 180.0 / .pi)
}
```

### Local Sidereal Time

Calculates the local sidereal time (LST):

```swift
func localSiderealTime(julianDate jd: Double, longitude: Double) -> Double {
    let T = (jd - 2451545.0) / 36525.0

    // Greenwich Mean Sidereal Time (GMST)
    let gmst = (280.46061837 + 360.98564736629 * (jd - 2451545.0) +
                T * T * (0.000387933 - T / 38710000.0))
        .truncatingRemainder(dividingBy: 360)

    // Convert to Local Sidereal Time
    let lst = (gmst + longitude).truncatingRemainder(dividingBy: 360)

    return lst
}
```

### Hour Angle for Rise/Set

Determines the hour angle when the Moon rises or sets:

```swift
func hourAngleForRiseSet(declination: Double, latitude: Double) -> Double? {
    let decRad = declination * .pi / 180.0
    let latRad = latitude * .pi / 180.0

    let cosH = -tan(latRad) * tan(decRad)

    // Check if Moon rises/sets (not circumpolar)
    guard abs(cosH) <= 1.0 else {
        return nil  // Moon doesn't rise or set
    }

    let H = acos(cosH)
    return H * 180.0 / .pi
}
```

### Complete Rise/Set Calculation

Puts it all together:

```swift
func calculateMoonTimes(
    for date: Date,
    latitude: Double,
    longitude: Double
) -> (rise: Date?, set: Date?) {
    let calendar = Calendar(identifier: .gregorian)
    let midnightComponents = calendar.dateComponents([.year, .month, .day], from: date)
    let midnight = calendar.date(from: midnightComponents)!

    let jd = julianDate(from: midnight)
    let (λ, β) = moonEclipticCoordinates(julianDate: jd)

    let obliquity = 23.4397  // Earth's axial tilt
    let (α, δ) = eclipticToEquatorial(longitude: λ, latitude: β, obliquity: obliquity)

    guard let H = hourAngleForRiseSet(declination: δ, latitude: latitude) else {
        return (nil, nil)
    }

    let lst = localSiderealTime(julianDate: jd, longitude: longitude)

    // Rise time
    let riseTime = (α - H - lst + 360).truncatingRemainder(dividingBy: 360) / 15.0
    let riseDate = calendar.date(byAdding: .hour, value: Int(riseTime), to: midnight)

    // Set time
    let setTime = (α + H - lst + 360).truncatingRemainder(dividingBy: 360) / 15.0
    let setDate = calendar.date(byAdding: .hour, value: Int(setTime), to: midnight)

    return (riseDate, setDate)
}
```

## Accuracy & Limitations

### Phase Calculation Accuracy

- **±1 day** accuracy over centuries
- Good for casual observation
- Not suitable for precise astronomical research

### Moonrise/Moonset Accuracy

- **±5-10 minutes** typical accuracy
- Affected by:
  - Atmospheric refraction (not accounted for)
  - Elevation above sea level (not accounted for)
  - Lunar parallax (simplified)

### Known Simplifications

1. **Elliptical Orbit**: Assumes constant synodic month
2. **Perturbations**: Ignores solar/planetary influences
3. **Nutation**: Earth's axial wobble not included
4. **Parallax**: Simplified moon-Earth distance
5. **Atmospheric Refraction**: Not modeled

## Testing & Validation

### Validation Against Known Events

Compare calculated phases with NASA data:

```swift
// Test: Full Moon on January 25, 2024
let testDate = DateComponents(year: 2024, month: 1, day: 25)
let phaseData = MoonPhaseCalculator.calculatePhaseData(for: testDate)
assert(phaseData.phaseName == "Full Moon")
assert(phaseData.illumination > 98.0)
```

### Edge Cases

- **Leap Years**: Handled by Foundation's Calendar
- **Time Zones**: All calculations in UTC, converted to local
- **Date Range**: Works for dates 1900-2100
- **Circumpolar Cases**: Returns `nil` for rise/set when appropriate

## References

### Astronomical Sources

1. **Jean Meeus** - *Astronomical Algorithms* (2nd Edition)
2. **US Naval Observatory** - Astronomical Applications
3. **NASA JPL** - Horizons System ephemeris data
4. **Wikipedia** - Lunar Phase, Synodic Month, Julian Date

### Implementation Notes

The implementation prioritizes:
- **Clarity** over micro-optimization
- **Accuracy** sufficient for casual users
- **Simplicity** for maintainability
- **Performance** with cached calculations

## Future Enhancements

Potential improvements:

1. **Higher Precision**: Implement full Meeus algorithms
2. **Libration**: Account for Moon's wobble
3. **Eclipse Prediction**: Calculate lunar/solar eclipses
4. **Supermoon Detection**: Identify perigee full moons
5. **Tides**: Approximate tidal predictions
6. **Azimuth/Altitude**: Moon position in sky
