---
title: "Lithium Documentation Index"
description: "Complete navigation guide to all Lithium project documentation"
category: "index"
version: "1.0.0"
last_updated: "2026-04-07"
tags: ["index", "navigation", "documentation"]
audience: "all"
---

# Lithium Documentation Index

> Complete guide to understanding, building, and extending the Lithium moon phase tracker

## Quick Navigation

### 🚀 Getting Started

**New to Lithium?** Start here:

1. [README.md](../README.md) - Project overview and features
2. [Build & Run Guide](BuildAndRun.md) - Installation and setup instructions
3. [UI Components](UIComponents.md) - Understanding the user interface

---

## Documentation by Category

### Quickstart
*Get up and running quickly*

| Document | Description | Audience |
|----------|-------------|----------|
| [Build & Run Guide](BuildAndRun.md) | Step-by-step build instructions, Xcode setup, deployment | Developers |
| [README](../README.md) | Project overview, features, installation, usage | All users |

### Architecture & Design
*Understand how Lithium is structured*

| Document | Description | Audience |
|----------|-------------|----------|
| [Architecture Guide](Architecture.md) | MVVM patterns, data flow, state management, component structure | Developers |
| [UI Components](UIComponents.md) | SwiftUI views, layouts, design system, color palette, typography | Developers, Designers |

### Technical Reference
*Deep dive into implementation details*

| Document | Description | Audience |
|----------|-------------|----------|
| [Moon Phase Calculation](MoonPhaseCalculation.md) | Astronomical algorithms, formulas, accuracy, mathematical models | Developers, Scientists |
| [Claude Code Skills](ClaudeCodeSkills.md) | Automation skills, testing tools, documentation maintenance | Developers |

### Development Tools
*Enhance your development workflow*

| Document | Description | Audience |
|----------|-------------|----------|
| [Claude Code Skills](ClaudeCodeSkills.md) | Custom skills for testing, previewing, and automation | Developers |
| [CLAUDE.md](../CLAUDE.md) | AI-friendly documentation standards and guidelines | AI Assistants, Developers |
| [llms.txt](../llms.txt) | AI-optimized project summary and quick reference | AI Assistants |

---

## Documentation by Use Case

### "I want to build and run Lithium"
1. Read [Build & Run Guide](BuildAndRun.md) - Prerequisites and installation
2. Follow step-by-step instructions to build in Xcode
3. Reference [Troubleshooting section](BuildAndRun.md#common-issues) if needed

### "I want to understand the moon calculations"
1. Start with [Moon Phase Calculation](MoonPhaseCalculation.md) - Overview
2. Read about the synodic month method
3. Explore the mathematical formulas and implementation
4. Review accuracy limitations and validation approaches

### "I want to modify the UI"
1. Review [UI Components](UIComponents.md) - Component overview
2. Understand the design system (colors, typography, spacing)
3. Reference specific view documentation for the component you're modifying
4. Use `/preview-arrakis` skill to preview changes instantly

### "I want to add a new feature"
1. Read [Architecture Guide](Architecture.md) - Design patterns and data flow
2. Understand state management and component communication
3. Review [UI Components](UIComponents.md) for styling consistency
4. Use `/test-moon-phases` to validate calculations after changes

### "I want to contribute or maintain documentation"
1. Read [CLAUDE.md](../CLAUDE.md) - Documentation standards
2. Use `/update-docs` skill to auto-sync documentation
3. Follow frontmatter metadata conventions
4. Ensure all code examples are copy-pasteable

---

## Key Concepts & Definitions

### Astronomical Terms

| Term | Definition | Reference |
|------|------------|-----------|
| **Synodic Month** | Time for Moon to return to same phase (~29.53 days) | [Moon Phase Calculation](MoonPhaseCalculation.md#synodic-month-method) |
| **Phase Value** | Decimal 0.0-1.0 representing moon cycle position | [Moon Phase Calculation](MoonPhaseCalculation.md#phase-calculation) |
| **Illumination** | Percentage of moon's visible surface lit by sun | [Moon Phase Calculation](MoonPhaseCalculation.md#illumination-percentage) |
| **Moonrise/Moonset** | Times when moon crosses local horizon | [Moon Phase Calculation](MoonPhaseCalculation.md#moonrise-and-moonset) |

### Architecture Terms

| Term | Definition | Reference |
|------|------------|-----------|
| **MVVM** | Model-View-ViewModel design pattern | [Architecture Guide](Architecture.md#mvvm) |
| **State Management** | SwiftUI's reactive state handling with @State, @Published | [Architecture Guide](Architecture.md#state-management) |
| **GeometryReader** | SwiftUI container for dynamic sizing and layout | [UI Components](UIComponents.md#layout-strategies) |
| **Canvas** | SwiftUI drawing API for custom graphics | [UI Components](UIComponents.md#moonphaseviewswift) |

### Development Terms

| Term | Definition | Reference |
|------|------------|-----------|
| **Claude Code Skill** | Custom automation command for development tasks | [Claude Code Skills](ClaudeCodeSkills.md#what-are-claude-code-skills) |
| **Preview** | SwiftUI's live UI preview feature in Xcode | [Build & Run Guide](BuildAndRun.md#using-previews) |
| **llms.txt** | AI-optimized project summary file | [llms.txt](../llms.txt) |

---

## File Locations Quick Reference

### Source Code
```
Lithium/Lithium/
├── LithiumApp.swift           # App entry point
├── ContentView.swift          # Main view container
├── MoonPhaseCalculator.swift  # Astronomical calculations
├── LocationManager.swift      # GPS and location services
├── MoonPhaseView.swift        # Moon visualization
├── TimelineView.swift         # 7-day forecast timeline
├── ArrakisMoonView.swift      # Fullscreen poster view
├── PhaseInfoPanel.swift       # Information panel
├── CalendarGridView.swift     # Calendar grid view
└── Assets.xcassets/           # Images and assets
```

### Documentation
```
docs/
├── index.md                  # This file - Documentation index
├── Architecture.md           # Architecture and design patterns
├── MoonPhaseCalculation.md   # Astronomical algorithms
├── UIComponents.md           # SwiftUI views and design system
├── BuildAndRun.md            # Build and deployment guide
└── ClaudeCodeSkills.md       # Development automation skills
```

### Configuration
```
.
├── CLAUDE.md                 # AI-friendly documentation standards
├── llms.txt                  # AI-optimized project summary
├── README.md                 # Project overview
├── LICENSE                   # MIT License
└── .claude-code/
    └── skills/               # Custom Claude Code skills
```

---

## Version Information

| Component | Version | Last Updated |
|-----------|---------|--------------|
| Project | 1.0.0 | 2026-04-07 |
| Documentation | 1.0.0 | 2026-04-07 |
| iOS Target | 17.0+ | 2026-04-07 |
| Swift | 5.9+ | 2026-04-07 |

---

## External Resources

### Official Documentation
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/) - Official Apple SwiftUI reference
- [Swift Language Guide](https://docs.swift.org/swift-book/) - Swift programming language guide
- [Xcode Documentation](https://developer.apple.com/documentation/xcode/) - Xcode IDE reference

### Astronomical References
- [NASA Moon Phase Data](https://svs.gsfc.nasa.gov/cgi-bin/details.cgi?aid=4442) - Visualization and reference data
- [USNO Astronomical Data](https://aa.usno.navy.mil/data/MoonPhases) - U.S. Naval Observatory moon phase data
- Astronomical Algorithms by Jean Meeus - Mathematical reference for calculations

### Project Resources
- [GitHub Repository](https://github.com/tholewis/dune-moon) - Source code and issues
- [MIT License](../LICENSE) - Open source license terms

---

## Getting Help

### Common Questions
- **Build errors?** → See [Build & Run Guide - Troubleshooting](BuildAndRun.md#common-issues)
- **Calculation accuracy?** → See [Moon Phase Calculation - Accuracy](MoonPhaseCalculation.md#accuracy-and-limitations)
- **UI customization?** → See [UI Components - Design System](UIComponents.md#design-system)
- **Adding features?** → See [Architecture Guide - Component Communication](Architecture.md#component-communication)

### Support Channels
- **Report Issues:** [GitHub Issues](https://github.com/tholewis/dune-moon/issues)
- **License Questions:** See [LICENSE](../LICENSE) file
- **Documentation Improvements:** Submit pull requests with updates

---

## Contributing to Documentation

When creating or updating documentation:

1. **Follow Standards:** Read [CLAUDE.md](../CLAUDE.md) for guidelines
2. **Add Frontmatter:** Include title, description, category, version, tags, audience
3. **Use Examples:** Provide working code samples with language tags
4. **Cross-Link:** Link to related documentation sections
5. **Update Index:** Add new pages to this index
6. **Run Skills:** Use `/update-docs` to auto-sync changes

---

**Last updated:** 2026-04-07
**Documentation version:** 1.0.0
**Project version:** 1.0.0
