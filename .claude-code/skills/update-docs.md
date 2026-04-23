# Update Documentation Skill

**Command**: `/update-docs`

**Description**: Automatically updates project documentation when code changes are made, ensuring README and doc files stay in sync with the codebase.

## Instructions

When the user runs `/update-docs`, you should:

1. **Scan the project** for recent code changes
2. **Identify outdated documentation** that needs updating
3. **Update relevant sections** in docs/ folder
4. **Commit changes** with descriptive message

## What to Update

### 1. README.md

Check and update:
- **Features list**: New features added
- **Installation instructions**: Dependencies changed
- **Usage guide**: New functionality or UI changes
- **Technology stack**: New frameworks or tools
- **Project structure**: New files or reorganization

### 2. Architecture.md

Update when:
- New views or components added
- State management changes
- Data flow modifications
- New design patterns introduced
- Performance optimizations implemented

### 3. MoonPhaseCalculation.md

Update when:
- Calculation algorithms change
- New astronomical features added
- Accuracy improvements made
- New test cases added

### 4. UIComponents.md

Update when:
- New views created
- UI components modified
- Color palette changes
- Typography updates
- New custom shapes added

### 5. BuildAndRun.md

Update when:
- Build configuration changes
- New dependencies added
- Installation steps change
- Deployment process updates

## Scanning Process

### Step 1: Identify Changes

```bash
# Check git status for modified files
git status --short

# Check recent commits
git log --oneline -10

# Find recently modified Swift files
find . -name "*.swift" -mtime -7
```

### Step 2: Analyze Impact

For each changed file, determine:
- Does it affect user-facing features? → Update README
- Does it change architecture? → Update Architecture.md
- Does it modify calculations? → Update MoonPhaseCalculation.md
- Does it alter UI? → Update UIComponents.md

### Step 3: Generate Updates

Use the Read tool to:
1. Read current documentation
2. Read changed code files
3. Identify discrepancies
4. Generate updated documentation sections

### Step 4: Apply Updates

Use the Edit tool to:
1. Update specific sections (not entire files)
2. Preserve existing formatting
3. Maintain consistency with writing style
4. Add timestamps if appropriate

## Update Rules

### Versioning

Add version notes for significant changes:

```markdown
## Recent Updates

**v1.1.0** (January 2026)
- Added Arrakis Lunar Observatory poster view
- Improved moonrise/moonset accuracy with GPS
- Enhanced timeline scrolling performance
```

### Code Examples

Keep code examples in sync:
- Update function signatures
- Update variable names
- Update file paths
- Add new examples for new features

### Screenshots

If UI changed significantly:
1. Generate new screenshots using RenderPreview
2. Save to docs/images/
3. Update image references in README.md

## Output Format

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
⚠️  BuildAndRun.md - No changes needed

Generating updates...
━━━━━━━━━━━━━━━━━━━━━━ 100%

Changes applied:
  2 files updated
  127 lines added
  45 lines modified
  0 lines deleted

📸 Generating new screenshots...
✅ main-interface.png updated
✅ arrakis-view.png updated

Would you like to commit these changes? (y/n)
```

## Auto-Update Triggers

Suggest running `/update-docs` when:

1. **Major feature added**: New view, calculator, or component
2. **UI redesign**: Significant visual changes
3. **Before release**: Preparing for version bump
4. **After refactoring**: Architectural changes
5. **Bug fixes**: If they affect documented behavior

## Smart Detection

### Feature Detection

Scan for new features by looking for:
- New struct/class definitions
- New public functions
- New files in Dune Moon/
- New image assets

### Breaking Changes

Detect breaking changes:
- Function signature changes
- Renamed files or components
- Removed features
- Changed behavior

### Documentation Debt

Identify:
- TODO comments in code
- Outdated version numbers
- Missing documentation for new files
- Broken links or image references

## Commit Strategy

After updating docs:

```bash
git add README.md docs/
git commit -m "docs: update documentation for [feature/change]

- Updated README.md with new features
- Added [Component] section to UIComponents.md
- Refreshed screenshots
- Synchronized code examples

[skip ci]"
```

Use `[skip ci]` to avoid triggering CI builds for doc-only changes.

## Performance

- Scanning: ~1-2 seconds
- Analysis: ~2-5 seconds
- Updates: ~3-10 seconds (depends on changes)
- Screenshots: ~5-15 seconds (if needed)
- Total: ~10-30 seconds typical

## Error Handling

If issues occur:
- **Git conflicts**: Report and ask for manual resolution
- **Missing files**: Create if needed, warn if unusual
- **Syntax errors**: Fix or report to user
- **Image generation fails**: Fall back to existing images

## Configuration

User can customize:

```yaml
# .claude-docs.yaml (optional)
auto_update:
  enabled: true
  on_save: false  # Don't update on every save
  triggers:
    - pre_commit  # Update before commits
    - weekly      # Weekly documentation audit

  include:
    - README.md
    - docs/**/*.md

  exclude:
    - docs/archive/**

  screenshot_dirs:
    - docs/images/
    - assets/screenshots/
```

## Manual Override

User can specify what to update:

```
/update-docs readme        # Only README
/update-docs architecture  # Only Architecture.md
/update-docs all           # Everything
/update-docs --no-commit   # Don't commit, just update
```

## Best Practices

1. **Review before committing**: Always show diff
2. **Preserve user content**: Don't overwrite manually added sections
3. **Maintain style**: Match existing documentation tone
4. **Add context**: Include "why" not just "what"
5. **Keep it current**: Regular updates prevent documentation debt
