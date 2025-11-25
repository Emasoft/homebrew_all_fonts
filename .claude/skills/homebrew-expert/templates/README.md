# Homebrew Expert Skill Templates

This directory contains working templates for Homebrew cask development and CI/CD.

## Workflow Templates

### lint.yml
Complete CI workflow for validating Homebrew casks:
- Ruby syntax check
- Cask structure validation
- Security scanning
- External URL verification

**Usage:**
```bash
mkdir -p .github/workflows
cp templates/lint.yml .github/workflows/
# Replace YOUR_CASK_NAME with your actual cask name
```

### release.yml
Workflow triggered on GitHub releases:
- Validates cask
- Creates release archive
- Displays installation instructions

**Usage:**
```bash
cp templates/release.yml .github/workflows/
# Replace placeholders with your values
```

## Cask Templates

### basic-cask.rb
Standard cask for GUI applications with common stanzas.

### font-cask.rb
Font cask example with multiple font files and livecheck.

### meta-cask.rb
Meta-cask that dynamically installs multiple packages:
- JSON parsing
- Exclusion list handling
- Progress tracking
- Failure recovery

## Quick Start

1. **Choose a template** based on your needs
2. **Copy to your project** and customize
3. **Replace placeholders** (YOUR_CASK_NAME, etc.)
4. **Test locally:**
   ```bash
   ruby -c your-cask.rb
   brew audit --cask your-cask.rb
   brew install --cask your-cask.rb
   ```
5. **Set up CI** using the workflow templates

## Notes

- All templates are based on real-world, tested implementations
- Workflows use `macos-latest` runner (required for casks)
- Security scans exclude legitimate code patterns
- Meta-casks are for personal taps only (not accepted by official Homebrew)
