---
title: "Claude Code Skills Documentation"
description: "Complete guide to custom automation skills for testing, previewing, and maintaining the Dune Moon project"
category: "development-tools"
version: "1.0.0"
last_updated: "2026-04-07"
tags: ["automation", "skills", "testing", "documentation", "claude-code"]
audience: "developers"
---

# Claude Code Skills Documentation

## Overview

Dune Moon includes four custom Claude Code skills designed to streamline development, ensure code quality, and maintain documentation. These skills automate common tasks and provide fast feedback loops for developers.

## What are Claude Code Skills?

Skills are specialized commands that Claude Code can execute to perform specific tasks within your project. They're like custom developer tools tailored specifically to Dune Moon's needs.

### Benefits

- ⚡ **Fast Iteration**: Quickly test changes without manual setup
- 🔍 **Quality Assurance**: Automated validation against known data
- 📝 **Documentation Sync**: Keep docs up-to-date automatically
- 🎨 **Visual Feedback**: Instant UI previews

---

## Available Skills

### 1. `/test-moon-phases` 🧪

#### What It Does

Validates the accuracy of moon phase calculations by running automated tests against known astronomical events and edge cases.

**Tests performed:**
- Known historical moon phases (New, Full, Quarters)
- Edge cases (leap years, end of year, far future/past dates)
- Boundary conditions (phase transitions)
- Illumination percentage accuracy
- Phase name correctness

**Test data includes:**
- Full Moon on January 25, 2024
- New Moon on February 9, 2024
- First Quarter on March 17, 2024
- Last Quarter on April 1, 2024
- Leap year date (February 29, 2024)
- Far future date (January 1, 2050)
- Far past date (January 1, 1990)

#### When to Use

**Use after:**
- Modifying `MoonPhaseCalculator.swift`
- Changing phase calculation algorithms
- Updating synodic month values
- Modifying phase name boundaries
- Refactoring date arithmetic

**Use before:**
- Committing changes to calculation code
- Creating pull requests
- Releasing new versions
- Deploying to production

**Don't use when:**
- Only changing UI code (use `/preview-arrakis` instead)
- Only updating documentation (use `/update-docs` instead)
- Working on unrelated features

#### Best Practices

1. **Run frequently**: Execute after any calculation changes
2. **Review failures**: Investigate why tests fail, don't just fix tests
3. **Add new tests**: When fixing bugs, add test cases to prevent regression
4. **Document anomalies**: If accuracy degrades, document why and what's acceptable

#### Expected Output

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

================================
Results: 7/8 tests passed
Accuracy: 87.5%
```

#### Performance

- **Runtime**: 1-3 seconds
- **Resource usage**: Minimal (CPU: Low, Memory: <10 MB)
- **Dependencies**: None (pure Swift calculations)

---

### 2. `/preview-arrakis` 🏜️

#### What It Does

Renders the Arrakis Lunar Observatory poster view using Xcode's preview system, allowing instant visual feedback on design changes.

**Capabilities:**
- Render current date's moon phase
- Preview specific phases (e.g., "full-moon", "new-moon")
- Generate all 8 moon phases at once
- Custom date previews
- Screenshot generation for documentation

#### When to Use

**Use when:**
- Making changes to `ArrakisMoonView.swift`
- Adjusting layout, spacing, or positioning
- Testing moon emoji display for different phases
- Changing colors, typography, or styling
- Adding new UI elements to the poster
- Verifying fixes for visual bugs
- Generating screenshots for documentation

**Use before:**
- Committing UI changes
- Creating design review requests
- Updating screenshots in README

**Don't use when:**
- Only changing calculation logic (use `/test-moon-phases` instead)
- Working on non-Arrakis views (use Xcode's built-in previews)

#### Command Variations

```bash
/preview-arrakis              # Current date's phase
/preview-arrakis full-moon    # Specific phase
/preview-arrakis new-moon     # New moon phase
/preview-arrakis all          # All 8 phases
/preview-arrakis 2024-12-25   # Custom date
```

**Supported phase names:**
- `new-moon` (🌑)
- `waxing-crescent` (🌒)
- `first-quarter` (🌓)
- `waxing-gibbous` (🌔)
- `full-moon` (🌕)
- `waning-gibbous` (🌖)
- `last-quarter` (🌗)
- `waning-crescent` (🌘)

#### Best Practices

1. **Quick iteration**: Use for rapid design changes
2. **Test all phases**: Run `all` before finalizing designs
3. **Visual checklist**: Verify each item in the design checklist
4. **Screenshot updates**: Regenerate docs screenshots when UI changes
5. **Cross-reference**: Compare with reference poster image

#### Design Validation Checklist

When previewing, verify:
- [ ] Dynamic moon emoji completely covers illustrated moon
- [ ] Moon emoji matches the phase name
- [ ] Info section doesn't overlap poster image
- [ ] Cream background extends to screen bottom
- [ ] Text is readable with proper contrast
- [ ] Typography kerning looks correct
- [ ] Illumination percentage shows "%" symbol
- [ ] Phase name supports multiline (e.g., "WAXING GIBBOUS")
- [ ] "TAP ANYWHERE TO RETURN" is visible
- [ ] Proper spacing around all elements

#### Expected Output

```
🏜️ Rendering Arrakis Lunar Observatory...

Phase: First Quarter
Illumination: 50%
Moon Emoji: 🌓

✅ Render complete!
[Image displayed]

Render time: 2.3s
Resolution: 3x (@1179x2556)
```

#### Performance

- **Single preview**: 2-5 seconds
- **All phases**: 15-25 seconds
- **Resource usage**: Low to Medium (GPU for rendering)
- **Dependencies**: Xcode Command Line Tools

---

### 3. `/update-docs` 📝

#### What It Does

Automatically scans the project for code changes and updates relevant documentation to keep it synchronized with the codebase.

**Updates:**
- `README.md` - Features, installation, usage
- `docs/Architecture.md` - Component structure, data flow
- `docs/UIComponents.md` - View documentation
- `docs/MoonPhaseCalculation.md` - Algorithm explanations
- `docs/BuildAndRun.md` - Build instructions
- Screenshots in `docs/images/` - If UI changed

**Detection capabilities:**
- New features added (new files, classes, functions)
- UI component changes (view modifications)
- Calculation algorithm updates
- Architecture changes (new patterns, state management)
- Breaking changes (renamed components, signature changes)

#### When to Use

**Use when:**
- Adding new features or components
- Making significant code changes
- Refactoring architecture
- Changing UI significantly
- Fixing bugs that affect documented behavior
- Before creating releases

**Use before:**
- Creating pull requests
- Publishing new versions
- Major git commits
- Sharing code with team/public

**Don't use when:**
- Making tiny, trivial changes
- Working on experimental branches
- Documentation is manually curated
- Changes are internal/private

#### Best Practices

1. **Review changes**: Always review doc diffs before committing
2. **Staged updates**: Update docs incrementally, not all at once
3. **Preserve manual content**: Don't overwrite user-added sections
4. **Consistent style**: Match existing documentation tone
5. **Version notes**: Add changelog entries for significant changes
6. **Screenshot refresh**: Regenerate screenshots when UI changes materially

#### What Gets Updated

| Code Change | Documentation Impact |
|-------------|---------------------|
| New view file | UIComponents.md + README features |
| Calculator change | MoonPhaseCalculation.md + README how-it-works |
| Architecture refactor | Architecture.md + README tech-stack |
| Build config change | BuildAndRun.md |
| UI redesign | UIComponents.md + screenshots |
| New dependency | README installation + BuildAndRun.md |

#### Expected Output

```
📝 Scanning project for documentation updates...

Found changes in:
- ArrakisMoonView.swift (modified 2 hours ago)
- MoonPhaseCalculator.swift (modified yesterday)

Documentation impact:
✅ README.md - Updated features list and screenshot
✅ UIComponents.md - Added ArrakisMoonView section
⚠️  MoonPhaseCalculation.md - No changes needed
⚠️  Architecture.md - No changes needed

Generating updates...
━━━━━━━━━━━━━━━━━━━━━━ 100%

Changes applied:
  2 files updated
  127 lines added
  45 lines modified

📸 Generating new screenshots...
✅ main-interface.png updated
✅ arrakis-view.png updated
```

#### Performance

- **Scanning**: 1-2 seconds
- **Analysis**: 2-5 seconds
- **Updates**: 3-10 seconds
- **Screenshots**: 5-15 seconds (if needed)
- **Total**: 10-30 seconds typical

#### Configuration

Can specify what to update:

```bash
/update-docs              # Smart detection
/update-docs readme       # Only README.md
/update-docs architecture # Only Architecture.md
/update-docs all          # Everything
/update-docs --no-commit  # Don't commit, just update
```

---

### 4. `/check-astronomy` 🔭

#### What It Does

Validates the astronomical accuracy of Dune Moon's calculations by comparing results against verified NASA JPL Horizons and US Naval Observatory data.

**Verification data:**
- 20+ verified moon phase dates (2024-2026)
- New Moon times (to the minute)
- Full Moon times (to the minute)
- First/Last Quarter times
- Moonrise/moonset times for specific locations

**Metrics calculated:**
- Phase value accuracy (within ±0.01 = ±1 day)
- Illumination percentage accuracy (within ±2%)
- Phase name correctness
- Mean absolute error
- Maximum error
- Overall accuracy grade

#### When to Use

**Use when:**
- Validating calculation accuracy
- Verifying changes to moon phase algorithms
- Testing against known astronomical events
- Checking moonrise/moonset accuracy
- Investigating user-reported inaccuracies
- Before releasing major updates

**Use before:**
- Publishing to App Store
- Claiming accuracy in marketing
- Scientific validation requirements
- Educational use certification

**Don't use when:**
- Only UI changes made
- Documentation updates only
- Working on unrelated features

#### Best Practices

1. **Regular validation**: Run periodically to ensure accuracy
2. **After algorithm changes**: Always run after modifying calculations
3. **Reference updates**: Keep reference data current with NASA updates
4. **Error investigation**: If accuracy degrades, investigate root cause
5. **Document limitations**: Be transparent about accuracy limits
6. **Historical testing**: Verify accuracy across time ranges

#### Acceptance Criteria

**Phase Value:**
- ✅ **Excellent**: Within ±0.01 (±1 day)
- ⚠️ **Acceptable**: Within ±0.02 (±2 days)
- ❌ **Poor**: Beyond ±0.02

**Illumination:**
- ✅ **Excellent**: Within ±2%
- ⚠️ **Acceptable**: Within ±5%
- ❌ **Poor**: Beyond ±5%

**Moonrise/Moonset:**
- ✅ **Excellent**: Within ±5 minutes
- ⚠️ **Acceptable**: Within ±15 minutes
- ❌ **Poor**: Beyond ±15 minutes

#### Expected Output

```
🔭 Astronomical Accuracy Check
=================================

Testing against NASA/USNO reference data...

✅ New Moon - January 11, 2024
   Reference: 11:57 UTC
   Dune Moon Phase: 0.003 (within 0.01) ✅
   Illumination: 0.8% (within 2%) ✅
   Accuracy: Excellent

✅ Full Moon - January 25, 2024
   Reference: 17:54 UTC
   Dune Moon Phase: 0.498 (within 0.01) ✅
   Illumination: 99.2% (within 2%) ✅
   Accuracy: Excellent

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Statistics (20 dates tested)

Phase Accuracy:
  Mean Absolute Error: 0.012 (±1.4 days)
  Max Error: 0.023 (±2.7 days)

Illumination Accuracy:
  Mean Absolute Error: 2.3%
  Max Error: 5.8%

Overall Grade: A- (92%)

🎯 Recommendations:
✅ Suitable for casual observation, photography, education
⚠️  May not be sufficient for scientific research
```

#### Performance

- **Runtime**: 2-5 seconds
- **Resource usage**: Minimal
- **Dependencies**: None (uses hardcoded reference data)
- **Network**: Not required

#### Reference Data Sources

- **NASA JPL Horizons**: https://ssd.jpl.nasa.gov/horizons.cgi
- **US Naval Observatory**: https://aa.usno.navy.mil/data/MoonPhases
- **Fred Espenak's Eclipse Data**: https://eclipse.gsfc.nasa.gov/

---

## Workflow Integration

### Development Workflow

```
1. Make code changes
2. Run appropriate skill(s):
   - UI changes → /preview-arrakis
   - Calculation changes → /test-moon-phases
   - Major changes → /check-astronomy
3. Fix any issues
4. Run /update-docs
5. Review changes
6. Commit and push
```

### Pre-Commit Checklist

Before committing significant changes:

```bash
/test-moon-phases      # Ensure calculations work
/preview-arrakis all   # Verify UI across all phases
/check-astronomy       # Validate accuracy
/update-docs           # Sync documentation
```

### Release Workflow

Before each release:

```bash
/test-moon-phases      # Full test suite
/check-astronomy       # Accuracy validation
/preview-arrakis all   # Visual regression test
/update-docs all       # Complete doc refresh
```

---

## Troubleshooting

### Skills Not Working

**Problem**: Skill doesn't execute
**Solutions:**
1. Ensure you're in the correct directory
2. Check skill files exist in `.claude-code/skills/`
3. Verify skill markdown syntax is correct
4. Restart Claude Code

### Preview Failures

**Problem**: `/preview-arrakis` fails to render
**Solutions:**
1. Check Xcode Command Line Tools are installed
2. Verify `ArrakisMoonView.swift` compiles without errors
3. Check `ArrakisPoster` image asset exists
4. Run `xcodebuild` manually to see detailed errors

### Test Failures

**Problem**: `/test-moon-phases` shows failures
**Solutions:**
1. Review calculation logic in `MoonPhaseCalculator.swift`
2. Verify reference new moon date is correct
3. Check synodic month value (29.530588)
4. Ensure timezone handling is UTC-based
5. Investigate leap year logic

### Documentation Out of Sync

**Problem**: `/update-docs` doesn't detect changes
**Solutions:**
1. Manually specify which docs to update
2. Check git status for uncommitted changes
3. Verify documentation files are readable/writable
4. Review skill logic in `.claude-code/skills/update-docs.md`

---

## Performance Considerations

### Resource Usage

| Skill | CPU | Memory | Disk | Network |
|-------|-----|--------|------|---------|
| `/test-moon-phases` | Low | <10 MB | None | None |
| `/preview-arrakis` | Medium | ~100 MB | Temp files | None |
| `/update-docs` | Low | <50 MB | Minimal | None |
| `/check-astronomy` | Low | <10 MB | None | None |

### Optimization Tips

1. **Parallel execution**: Don't run multiple skills simultaneously
2. **Preview caching**: Xcode caches previews for faster reruns
3. **Selective docs**: Use targeted `/update-docs` for faster updates
4. **Background tasks**: Skills run synchronously, plan accordingly

---

## Security & Privacy

### Data Privacy

- ✅ All skills run locally
- ✅ No data sent to external servers
- ✅ No credentials accessed
- ✅ No telemetry or tracking
- ✅ Code stays on your machine

### File System Access

- ✅ Scoped to project directory
- ✅ Read-only by default (except `/update-docs`)
- ✅ No sudo/admin privileges required
- ✅ Git provides version control safety

### Best Practices

1. **Review changes**: Always review before committing
2. **Use git**: Keep changes under version control
3. **Test on branches**: Try skills on feature branches first
4. **Backup regularly**: Maintain backups of important work

---

## Extending Skills

### Creating New Skills

To add a new skill:

1. Create `.claude-code/skills/your-skill-name.md`
2. Follow this structure:

```markdown
# Your Skill Name

**Command**: `/your-skill`

**Description**: What the skill does

## Instructions

When user runs `/your-skill`:
1. Step one
2. Step two
3. Step three

## Expected Output

```
Output format here
```

## Performance

- Runtime: X seconds
- Resource usage: Low/Medium/High
```

3. Test thoroughly
4. Document in `.claude-code/README.md`
5. Commit to repository

### Ideas for New Skills

- `/generate-icon` - Create app icon from design
- `/run-tests` - Execute XCTest suite
- `/profile-performance` - Run Instruments profiling
- `/export-ipa` - Build and export IPA file
- `/validate-accessibility` - Check VoiceOver labels
- `/analyze-code` - SwiftLint code analysis

---

## FAQ

**Q: Do skills require internet?**
A: No, all skills run locally without network access.

**Q: Can skills modify my code?**
A: Only `/update-docs` modifies files (documentation only). Use git to review changes.

**Q: How are skills different from Xcode shortcuts?**
A: Skills are Claude-powered automation that understands your codebase context.

**Q: Can I share skills with my team?**
A: Yes! Skills in `.claude-code/skills/` are version controlled and shared via git.

**Q: Do skills work in CI/CD?**
A: Currently designed for local development. CI/CD integration requires additional setup.

**Q: Can I disable specific skills?**
A: Yes, remove or rename the skill's `.md` file to disable it.

**Q: How do I update a skill?**
A: Edit the skill's markdown file in `.claude-code/skills/` and test.

---

## Additional Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Project README](../README.md)
- [Architecture Guide](Architecture.md)
- [Build & Run Guide](BuildAndRun.md)

---

## Support

For issues or questions about skills:
1. Check this documentation
2. Review skill markdown files
3. Open an issue on GitHub
4. Contact the development team
