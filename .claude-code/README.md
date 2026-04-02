# Claude Code Skills for Lithium

This directory contains custom Claude Code skills specifically designed for the Lithium/Dune Moon project.

## Available Skills

### 🧪 `/test-moon-phases`
Validates the accuracy of moon phase calculations by testing against known astronomical events and edge cases.

**Use when:**
- After modifying `MoonPhaseCalculator.swift`
- Before committing calculation changes
- Verifying accuracy against NASA data

**Runtime:** 1-3 seconds

---

### 🏜️ `/preview-arrakis`
Quickly renders and displays the Arrakis Lunar Observatory poster view for design iteration.

**Use when:**
- Making UI changes to ArrakisMoonView
- Testing all moon phase emojis
- Generating screenshots for documentation
- Verifying visual design

**Runtime:** 2-5 seconds (single), 15-25 seconds (all phases)

**Options:**
- `/preview-arrakis` - Current date's phase
- `/preview-arrakis full-moon` - Specific phase
- `/preview-arrakis all` - All 8 phases

---

### 📝 `/update-docs`
Automatically updates project documentation when code changes are made, ensuring README and doc files stay in sync.

**Use when:**
- Adding new features
- Making significant code changes
- Before releases
- After refactoring

**Runtime:** 10-30 seconds

**Updates:**
- README.md
- docs/Architecture.md
- docs/UIComponents.md
- docs/MoonPhaseCalculation.md
- docs/BuildAndRun.md
- Screenshots (if UI changed)

---

### 🔭 `/check-astronomy`
Validates astronomical accuracy by comparing calculations against verified NASA/USNO data.

**Use when:**
- Verifying calculation accuracy
- Testing against known moon phases
- Validating moonrise/moonset times
- Checking historical date accuracy

**Runtime:** 2-5 seconds

**Tests:**
- 20+ verified dates (2024-2026)
- Phase accuracy (within ±0.02)
- Illumination accuracy (within ±5%)
- Phase name correctness

---

## Installation

These skills are already available in this project. Claude Code will automatically detect and load them.

## Performance & Security

All skills:
- ✅ Run locally (no external API calls)
- ✅ Low to minimal resource usage
- ✅ Read-only by default (except /update-docs)
- ✅ No sudo/admin privileges required
- ✅ Scoped to project directory

## Contributing

To add new skills:

1. Create a new `.md` file in `.claude-code/skills/`
2. Follow the existing skill format
3. Test the skill thoroughly
4. Update this README

## Support

For issues or questions about these skills, please open an issue on the repository.
