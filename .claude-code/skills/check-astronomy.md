# Check Astronomy Skill

**Command**: `/check-astronomy`

**Description**: Validates the astronomical accuracy of moon phase calculations by comparing against verified NASA/USNO data for specific dates.

## Instructions

When the user runs `/check-astronomy`, you should:

1. **Select verification dates** (known astronomical events)
2. **Calculate using Lithium's algorithms**
3. **Compare against reference data**
4. **Report accuracy and discrepancies**

## Reference Data Sources

### Verified Moon Phases (2024-2026)

These dates are verified against NASA JPL Horizons and US Naval Observatory data:

#### 2024
```
New Moons:
- January 11, 2024, 11:57 UTC
- February 9, 2024, 22:59 UTC
- March 10, 2024, 09:00 UTC
- April 8, 2024, 18:21 UTC (Solar Eclipse)
- May 8, 2024, 03:22 UTC
- June 6, 2024, 12:38 UTC

Full Moons:
- January 25, 2024, 17:54 UTC
- February 24, 2024, 12:30 UTC
- March 25, 2024, 07:00 UTC
- April 23, 2024, 23:49 UTC
- May 23, 2024, 13:53 UTC
- June 22, 2024, 01:08 UTC

First Quarter:
- January 18, 2024, 03:52 UTC
- February 16, 2024, 15:01 UTC
- March 17, 2024, 04:11 UTC
- April 15, 2024, 19:13 UTC

Last Quarter:
- January 4, 2024, 03:30 UTC
- February 2, 2024, 23:18 UTC
- March 3, 2024, 15:23 UTC
- April 2, 2024, 03:15 UTC
```

#### 2025
```
New Moons:
- January 29, 2025, 12:36 UTC
- March 29, 2025, 10:58 UTC
- May 27, 2025, 11:02 UTC

Full Moons:
- January 13, 2025, 22:27 UTC
- March 14, 2025, 06:55 UTC
- May 12, 2025, 16:56 UTC
```

#### 2026
```
New Moons:
- January 18, 2026, 19:52 UTC
- March 19, 2026, 10:23 UTC

Full Moons:
- January 2, 2026, 19:03 UTC
- March 3, 2026, 11:38 UTC
```

## Validation Process

### Step 1: Calculate with Lithium

For each reference date:

```swift
let referenceDate = DateComponents(
    year: 2024,
    month: 1,
    day: 25,
    hour: 17,
    minute: 54
)

let calendar = Calendar(identifier: .gregorian)
calendar.timeZone = TimeZone(identifier: "UTC")!
let date = calendar.date(from: referenceDate)!

let phaseData = MoonPhaseCalculator.calculatePhaseData(for: date)
```

### Step 2: Compare Results

Check accuracy:

```
Full Moon - January 25, 2024, 17:54 UTC
Expected: Phase = 0.5, Illumination = 100%

Lithium calculated:
  Phase: 0.498
  Illumination: 99.2%
  Phase Name: Full Moon

Accuracy:
  Phase error: -0.002 (0.4% off) ✅
  Illumination error: -0.8% ✅
  Name: Correct ✅
```

### Step 3: Calculate Error Statistics

```
Mean Absolute Error (Phase): 0.012
Mean Absolute Error (Illumination): 2.3%
Accuracy: 95.8%
```

## Acceptance Criteria

### Phase Value
- ✅ **Excellent**: Within ±0.01 (±1 day)
- ⚠️ **Acceptable**: Within ±0.02 (±2 days)
- ❌ **Poor**: Beyond ±0.02

### Illumination
- ✅ **Excellent**: Within ±2%
- ⚠️ **Acceptable**: Within ±5%
- ❌ **Poor**: Beyond ±5%

### Phase Names
- ✅ Must match exactly for major phases (New, Full, Quarters)
- ⚠️ 1-day tolerance for Crescent/Gibbous transitions

## Output Format

```
🔭 Astronomical Accuracy Check
=================================

Testing against NASA/USNO reference data...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 2024 Verification

✅ New Moon - January 11, 2024
   Reference: 11:57 UTC
   Lithium Phase: 0.003 (within 0.01) ✅
   Illumination: 0.8% (within 2%) ✅
   Accuracy: Excellent

✅ Full Moon - January 25, 2024
   Reference: 17:54 UTC
   Lithium Phase: 0.498 (within 0.01) ✅
   Illumination: 99.2% (within 2%) ✅
   Accuracy: Excellent

⚠️  First Quarter - March 17, 2024
   Reference: 04:11 UTC
   Lithium Phase: 0.268 (within 0.02) ⚠️
   Illumination: 53.6% (within 5%) ⚠️
   Accuracy: Acceptable (±18 hours)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Statistics (20 dates tested)

Phase Accuracy:
  Mean Absolute Error: 0.012 (±1.4 days)
  Max Error: 0.023 (±2.7 days)
  Min Error: 0.001 (±0.1 days)

Illumination Accuracy:
  Mean Absolute Error: 2.3%
  Max Error: 5.8%
  Min Error: 0.2%

Overall Grade: A- (92%)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 Recommendations:

✅ Accuracy is suitable for:
   - Casual moon observation
   - Photography planning
   - Educational purposes
   - Tide awareness

⚠️  May not be sufficient for:
   - Scientific research
   - Precise astronomical calculations
   - Navigation

💡 To improve accuracy, consider:
   - Implementing full Meeus algorithms
   - Accounting for lunar perturbations
   - Adding nutation corrections
```

## Extended Validation

### Moonrise/Moonset Times

For selected dates with known moonrise/moonset times:

```
📍 Location: San Francisco (37.7749°N, 122.4194°W)
📅 Date: January 25, 2024

Reference (USNO):
  Moonrise: 17:23 PST
  Moonset: 06:15 PST (next day)

Lithium Calculated:
  Moonrise: 17:31 PST (+8 min)
  Moonset: 06:22 PST (+7 min)

Accuracy: Within ±10 minutes ✅
```

### Acceptance Criteria for Rise/Set:
- ✅ **Excellent**: Within ±5 minutes
- ⚠️ **Acceptable**: Within ±15 minutes
- ❌ **Poor**: Beyond ±15 minutes

## Historical Accuracy Test

Test calculations for dates far from reference:

```
🕰️  Historical Date Test

Testing: January 1, 1990 (32 years before reference)
Expected accumulated error: ~0.5-1.0 days

Lithium Phase: 0.46
Expected: ~0.47 (Full Moon region)
Error: 0.01 ✅

Testing: January 1, 2050 (24 years after reference)
Expected accumulated error: ~0.3-0.6 days

Lithium Phase: 0.23
Expected: ~0.25 (First Quarter region)
Error: 0.02 ⚠️
```

## Special Events

Test these special astronomical events:

### Supermoons (Perigee Full Moons)
```
August 30, 2023 - Blue Supermoon
Expected: Full Moon (0.5) + closest approach
```

### Eclipses
```
April 8, 2024 - Total Solar Eclipse (New Moon)
Expected: Phase 0.0 at eclipse time
```

### Blue Moons (Second Full Moon in Month)
```
Verify phase calculation handles calendar months correctly
```

## Performance

- Test execution: 2-5 seconds
- Resource usage: Minimal
- No network required (uses hardcoded reference data)

## Error Diagnosis

If accuracy is poor:

1. **Check reference new moon date** in MoonPhaseCalculator.swift
2. **Verify synodic month value** (should be 29.530588)
3. **Check timezone handling** (calculations should use UTC)
4. **Inspect leap year logic** in date arithmetic
5. **Review phase boundary definitions**

## Future Enhancements

Potential improvements:
- Fetch live data from NASA API for comparison
- Test more historical dates (100+ year range)
- Add lunar libration calculations
- Include supermoon detection
- Test eclipse predictions
- Validate tidal calculations (if added)

## References

Data sources:
- NASA JPL Horizons System: https://ssd.jpl.nasa.gov/horizons.cgi
- US Naval Observatory: https://aa.usno.navy.mil/data/MoonPhases
- Fred Espenak's Eclipse Data: https://eclipse.gsfc.nasa.gov/
