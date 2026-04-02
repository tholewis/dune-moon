# Test Moon Phases Skill

**Command**: `/test-moon-phases`

**Description**: Validates the accuracy of moon phase calculations by testing against known astronomical events and edge cases.

## Instructions

When the user runs `/test-moon-phases`, you should:

1. **Test Known Moon Phases**: Verify calculations against well-documented astronomical events
2. **Test Edge Cases**: Check boundary conditions and special dates
3. **Report Results**: Provide clear pass/fail summary

## Test Cases to Run

### Known Historical Events

Test these verified moon phases from NASA data:

```swift
// Full Moon - January 25, 2024
let testDate1 = DateComponents(year: 2024, month: 1, day: 25)
// Expected: Phase ≈ 0.5, Illumination > 98%, Name: "Full Moon"

// New Moon - February 9, 2024
let testDate2 = DateComponents(year: 2024, month: 2, day: 9)
// Expected: Phase ≈ 0.0, Illumination < 2%, Name: "New Moon"

// First Quarter - March 17, 2024
let testDate3 = DateComponents(year: 2024, month: 3, day: 17)
// Expected: Phase ≈ 0.25, Illumination ≈ 50%, Name: "First Quarter"

// Last Quarter - April 1, 2024
let testDate4 = DateComponents(year: 2024, month: 4, day: 1)
// Expected: Phase ≈ 0.75, Illumination ≈ 50%, Name: "Last Quarter"
```

### Edge Cases

```swift
// Leap Year - February 29, 2024
let leapYear = DateComponents(year: 2024, month: 2, day: 29)

// End of Year - December 31, 2025
let endOfYear = DateComponents(year: 2025, month: 12, day: 31)

// Far Future - January 1, 2050
let farFuture = DateComponents(year: 2050, month: 1, day: 1)

// Far Past - January 1, 1990
let farPast = DateComponents(year: 1990, month: 1, day: 1)
```

## Validation Steps

For each test:

1. **Read** `Lithium/MoonPhaseCalculator.swift`
2. **Call** `MoonPhaseCalculator.calculatePhaseData(for: date)`
3. **Verify**:
   - Phase value is between 0.0 and 1.0
   - Illumination is between 0 and 100
   - Phase name matches expected value
   - Waxing/waning status is correct
4. **Report** pass/fail with actual vs expected values

## Output Format

```
🌙 Moon Phase Calculation Tests
================================

✅ Full Moon (Jan 25, 2024)
   Phase: 0.498 (expected ~0.5)
   Illumination: 99.2% (expected >98%)
   Name: Full Moon ✓

✅ New Moon (Feb 9, 2024)
   Phase: 0.003 (expected ~0.0)
   Illumination: 0.6% (expected <2%)
   Name: New Moon ✓

⚠️  First Quarter (Mar 17, 2024)
   Phase: 0.26 (expected ~0.25) - within tolerance
   Illumination: 51.8% (expected ~50%)
   Name: First Quarter ✓

================================
Results: 7/8 tests passed
Accuracy: 87.5%
```

## Performance

- Expected runtime: 1-3 seconds
- Resource usage: Minimal (CPU: Low, Memory: <10 MB)
- No external dependencies required

## Success Criteria

- All major phases within ±0.02 of expected value
- Illumination within ±5% of expected value
- Correct phase names
- No crashes or errors
