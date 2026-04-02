# Preview Arrakis Skill

**Command**: `/preview-arrakis`

**Description**: Quickly renders and displays the Arrakis Lunar Observatory poster view for all moon phases, helping with design iteration and visual testing.

## Instructions

When the user runs `/preview-arrakis`, you should:

1. **Render the Arrakis view** using Xcode's preview system
2. **Display the current result** so the user can see it
3. **Optionally generate multiple phases** if requested

## Default Behavior

Render the Arrakis view with the current date's moon phase:

```swift
// Use RenderPreview tool
RenderPreview(
    sourceFilePath: "Lithium/ArrakisMoonView.swift",
    timeout: 60
)
```

Then display the resulting image to the user.

## Advanced Options

The user can specify:

- **Specific phase**: `/preview-arrakis full-moon`
- **All phases**: `/preview-arrakis all`
- **Custom date**: `/preview-arrakis 2024-12-25`

### Phase Options

```swift
// New Moon
phase: 0.0, illumination: 0, phaseName: "New Moon"

// Waxing Crescent
phase: 0.15, illumination: 25, phaseName: "Waxing Crescent"

// First Quarter
phase: 0.25, illumination: 50, phaseName: "First Quarter"

// Waxing Gibbous
phase: 0.35, illumination: 75, phaseName: "Waxing Gibbous"

// Full Moon
phase: 0.5, illumination: 100, phaseName: "Full Moon"

// Waning Gibbous
phase: 0.65, illumination: 75, phaseName: "Waning Gibbous"

// Last Quarter
phase: 0.75, illumination: 50, phaseName: "Last Quarter"

// Waning Crescent
phase: 0.85, illumination: 25, phaseName: "Waning Crescent"
```

## Steps

1. **Read** `Lithium/ArrakisMoonView.swift`
2. **Verify** the file exists and is syntactically correct
3. **Call RenderPreview** with appropriate parameters
4. **Display** the resulting PNG image
5. **Report** any issues (compilation errors, render failures)

## Output Format

### Single Preview
```
🏜️ Rendering Arrakis Lunar Observatory...

Phase: First Quarter
Illumination: 50%
Moon Emoji: 🌓

✅ Render complete!
[Display image]

Render time: 2.3s
Resolution: 3x (@1179x2556)
```

### All Phases Preview
```
🏜️ Rendering all moon phases on Arrakis...

✅ New Moon 🌑
✅ Waxing Crescent 🌒
✅ First Quarter 🌓
✅ Waxing Gibbous 🌔
✅ Full Moon 🌕
✅ Waning Gibbous 🌖
✅ Last Quarter 🌗
✅ Waning Crescent 🌘

[Display image grid or collage]

Total render time: 18.5s
All previews saved to: docs/images/arrakis-all-phases.png
```

## Design Checklist

When previewing, visually verify:

- [ ] Dynamic moon emoji completely covers illustrated moon
- [ ] Moon emoji matches the phase name
- [ ] Info section doesn't overlap poster image
- [ ] Cream background extends to screen bottom
- [ ] Text is readable with proper contrast
- [ ] Typography kerning looks correct
- [ ] Illumination percentage shows "%" symbol
- [ ] Phase name supports multiline (e.g., "WAXING GIBBOUS")
- [ ] "TAP ANYWHERE TO RETURN" is visible

## Performance

- Single preview: ~2-5 seconds
- All phases: ~15-25 seconds
- Resource usage: Low to Medium (CPU, Memory)
- Requires Xcode tools

## Error Handling

If render fails:
1. Check for compilation errors in ArrakisMoonView.swift
2. Verify Assets/ArrakisPoster image exists
3. Check Xcode is properly installed
4. Report specific error message to user

## Use Cases

- **Quick iteration**: See design changes instantly
- **Phase testing**: Verify all moon emojis display correctly
- **Screenshot generation**: Create images for documentation
- **Design review**: Share visuals with others
- **Regression testing**: Ensure UI changes don't break layout
