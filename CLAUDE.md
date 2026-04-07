# CLAUDE.md

This file provides guidance to Claude Code when working with documentation in this project.

## Documentation Standards

All technical documentation in this project should follow the AI-friendly guidelines below. When creating, editing, or reviewing documentation, apply these principles.

---

## Structure and Semantics

- Use consistent, descriptive headings that clearly label what each section covers.
- Prefer flat, modular sections over deeply nested structures. Each section should ideally stand alone and answer one question.
- Use semantic markup (proper HTML tags, MDX frontmatter, OpenAPI schemas) rather than relying on visual formatting to convey meaning.

## Content Clarity

- Define acronyms and terms inline or in a glossary.
- Write in plain, consistent language. Avoid idioms, marketing language, or ambiguous phrasing.
- Be explicit about preconditions and postconditions — what the user needs before a step, and what state they'll be in after.
- Avoid implicit knowledge. State version numbers, OS assumptions, and environment requirements clearly.

## Code Examples

- Always include working, copy-pasteable code samples.
- Label every code block with a language tag (e.g., ` ```swift `) for proper syntax recognition.
- Annotate code with inline comments explaining the non-obvious parts.
- Show both the call and the expected response, especially for APIs.

## Machine-Readable Formats

- Provide structured data formats (JSON, YAML frontmatter) for metadata like parameters, return types, and error codes.
- Maintain an `llms.txt` file at the project root with a concise, AI-optimized summary of the documentation structure.

## Navigation and Discoverability

- Include a documentation index with a one-line description of each page.
- Cross-link consistently. When a concept is mentioned, link to where it's defined.
- Use canonical URLs so that AI-generated answers point to the right, stable location.

## Metadata and Context

- Add frontmatter to every documentation page with at minimum: `title`, `description`, `category`, `version`, and `last_updated`.
- Include changelog or versioning notes so the correct version context is always clear.
- Tag pages by use case or audience (e.g., `quickstart`, `reference`, `troubleshooting`).

## Things to Avoid

- Do not put critical information only in images or diagrams.
- Avoid deeply nested tables for structured data; use lists or dedicated data formats instead.
- Do not scatter prerequisites across multiple pages without a summary in one place.
- Avoid version-ambiguous content — always specify which version of the product a section applies to.

---

## Project-Specific Context

### Technology Stack
- **Language:** Swift 5.9+
- **Framework:** SwiftUI (iOS 17.0+)
- **Platform:** iOS
- **Xcode Version:** 15.0+
- **Dependencies:** None (pure Swift/SwiftUI)

### Key Architectural Patterns
- **MVVM:** Model-View-ViewModel pattern for separation of concerns
- **Observable Objects:** SwiftUI's `@StateObject` and `@Published` for reactive state management
- **Pure Functions:** Astronomical calculations are stateless and testable

### Development Environment Requirements
- macOS Ventura (13.0) or later
- Xcode 15.0 or later
- iOS 17.0+ device or simulator
- No external dependencies or API keys required

### Code Style Conventions
- **Naming:** PascalCase for types, camelCase for properties/methods
- **Indentation:** 4 spaces (no tabs)
- **Comments:** Use `//` for single-line, `/* */` for multi-line
- **SwiftUI:** Prefer declarative syntax, minimize imperative code
- **Properties:** Use `private` for internal state, `@State` for view-local state

### Testing Strategy
- Unit tests for `MoonPhaseCalculator` (astronomical algorithms)
- Preview tests for SwiftUI views using `#Preview` macro
- Manual validation against NASA/USNO reference data

---

> **Core principle:** Write for humans first, but be explicit enough that a machine can reconstruct the answer without needing background knowledge or visual context.
