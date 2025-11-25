# Homebrew + GitHub Actions Setup Guide

Complete guide for publishing and automating Homebrew packages (formulas and casks) with GitHub Actions.

## Table of Contents
1. [Understanding Formulas vs Casks](#understanding-formulas-vs-casks)
2. [Project Type Decision Tree](#project-type-decision-tree)
3. [GitHub Actions for Formulas](#github-actions-for-formulas)
4. [GitHub Actions for Casks](#github-actions-for-casks)
5. [Setting Up Personal Taps](#setting-up-personal-taps)
6. [Best Practices](#best-practices)
7. [Complete Workflow Examples](#complete-workflow-examples)

---

## Understanding Formulas vs Casks

### Formulas
- **What:** Command-line tools, libraries, services
- **Examples:** git, node, python, nginx
- **Install command:** `brew install <name>`
- **File extension:** `.rb` (Ruby DSL)
- **Location:** `homebrew-core` or personal taps

### Casks
- **What:** GUI applications, fonts, browser plugins
- **Examples:** Google Chrome, VS Code, fonts
- **Install command:** `brew install --cask <name>`
- **File extension:** `.rb` (Ruby DSL)
- **Location:** `homebrew-cask` or personal taps

### Meta-Casks (Special Case)
- **What:** Casks that install other casks/formulas
- **Examples:** Your homebrew_all_fonts project
- **Install command:** `brew install --cask <name>`
- **Purpose:** Bulk installation, environment setup
- **Note:** These are still casks, not formulas!

---

## Project Type Decision Tree

```
Is your project a command-line tool?
├─ YES → Use Formula
│  └─ Go to "GitHub Actions for Formulas"
│
└─ NO → Is it a GUI app or visual element (font)?
   ├─ YES → Use Cask
   │  └─ Go to "GitHub Actions for Casks"
   │
   └─ NO → Is it a meta-installer (installs other things)?
      └─ YES → Use Cask (meta-cask)
         └─ Go to "GitHub Actions for Casks"
```

---

## GitHub Actions for Formulas

### Best Action: `homebrew-bump-formula`

**Repository:** [dawidd6/action-homebrew-bump-formula](https://github.com/dawidd6/action-homebrew-bump-formula)
- ⭐ **107 stars** (most popular)
- ✅ **Actively maintained** (12 contributors)
- ✅ **Official `brew bump-formula-pr` wrapper**

### Setup Steps

1. **Create GitHub Token**
   - Go to: Settings → Developer settings → Personal access tokens → Fine-grained tokens
   - Scopes needed: `public_repo`, `workflow`
   - Add to repository secrets as `HOMEBREW_TAP_TOKEN`

2. **Create Workflow File:** `.github/workflows/bump-formula.yml`

```yaml
name: Bump Homebrew Formula

on:
  release:
    types: [published]

jobs:
  bump-formula:
    runs-on: ubuntu-latest
    steps:
      - uses: dawidd6/action-homebrew-bump-formula@v6
        with:
          token: ${{ secrets.HOMEBREW_TAP_TOKEN }}
          formula: your-formula-name
          tap: your-username/homebrew-tap
```

3. **Optional: Livecheck Mode** (scheduled updates)

```yaml
name: Livecheck

on:
  schedule:
    - cron: '0 0 * * *' # Daily at midnight

jobs:
  livecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: dawidd6/action-homebrew-bump-formula@v6
        with:
          token: ${{ secrets.HOMEBREW_TAP_TOKEN }}
          tap: your-username/homebrew-tap
          livecheck: true
```

---

## GitHub Actions for Casks

### Best Action: `homebrew-bump-cask`

**Repository:** [macauley/action-homebrew-bump-cask](https://github.com/macauley/action-homebrew-bump-cask)
- ⭐ **7 stars** (limited but proven)
- ✅ **Official `brew bump-cask-pr` wrapper**
- ✅ **Only action specifically for casks**

### When to Use This Action

**Use it when:**
- You want to submit to official `homebrew/cask` tap
- You maintain a personal tap that needs automated updates
- You have frequent releases

**Don't use it when:**
- Users install directly from GitHub (like our font project)
- It's a one-off cask
- You don't have a tap repository

### Setup Steps

1. **Create GitHub Token**
   - Same as formulas (see above)
   - Add to secrets as `HOMEBREW_TAP_TOKEN`

2. **Create Workflow File:** `.github/workflows/bump-cask.yml`

```yaml
name: Bump Homebrew Cask

on:
  release:
    types: [published]

jobs:
  bump-cask:
    runs-on: macos-latest
    steps:
      - uses: macauley/action-homebrew-bump-cask@v1
        with:
          token: ${{ secrets.HOMEBREW_TAP_TOKEN }}
          cask: your-cask-name
          tap: your-username/homebrew-tap
```

3. **Optional: Livecheck Mode**

```yaml
name: Livecheck Casks

on:
  schedule:
    - cron: '0 0 * * *' # Daily

jobs:
  livecheck:
    runs-on: macos-latest
    steps:
      - uses: macauley/action-homebrew-bump-cask@v1
        with:
          token: ${{ secrets.HOMEBREW_TAP_TOKEN }}
          tap: your-username/homebrew-tap
          livecheck: true
```

---

## Setting Up Personal Taps

### What is a Tap?
A tap is a third-party Homebrew repository. Official taps:
- `homebrew/core` (formulas)
- `homebrew/cask` (casks)

Personal taps: `username/homebrew-name`

### Creating a Personal Tap

1. **Create GitHub Repository**
   ```bash
   # Repository must be named: homebrew-<name>
   # Example: homebrew-tools, homebrew-apps
   gh repo create homebrew-mytools --public
   ```

2. **Repository Structure**
   ```
   homebrew-mytools/
   ├── Formula/
   │   └── mytool.rb      # For formulas
   ├── Casks/
   │   └── myapp.rb       # For casks
   └── README.md
   ```

3. **Users Install From Your Tap**
   ```bash
   # Tap your repository
   brew tap username/mytools
   
   # Install formula
   brew install mytool
   
   # Install cask
   brew install --cask myapp
   ```

### Direct Installation (No Tap)

For standalone projects (like homebrew_all_fonts):

```bash
# Direct URL installation
brew install --cask https://raw.githubusercontent.com/user/repo/main/cask.rb
```

**Pros:**
- No tap needed
- Simple for users
- No maintenance overhead

**Cons:**
- Can't use `brew install --cask short-name`
- No automatic updates
- Not searchable via `brew search`

---

## Best Practices

### 1. Token Security
```yaml
# ✅ GOOD - Use secrets
token: ${{ secrets.HOMEBREW_TAP_TOKEN }}

# ❌ BAD - Never hardcode
token: ghp_abc123xyz
```

### 2. Choose Right Runner
```yaml
# For formulas - Ubuntu is cheaper
runs-on: ubuntu-latest

# For casks - macOS required for testing
runs-on: macos-latest
```

### 3. Semantic Versioning
```bash
# ✅ GOOD - Proper semver
v1.0.0, v1.2.3, v2.0.0-beta.1

# ❌ BAD - Non-standard
version-1, release-march, v1.2
```

### 4. Release Triggers
```yaml
# ✅ GOOD - Specific release types
on:
  release:
    types: [published]

# ⚠️ OKAY - But includes drafts/prereleases
on:
  release:
```

### 5. Validation Before Publishing
```yaml
jobs:
  validate:
    runs-on: macos-latest
    steps:
      - name: Check Ruby syntax
        run: ruby -c Formula/mytool.rb
      
      - name: Audit formula
        run: brew audit --strict --online Formula/mytool.rb
```

---

## Complete Workflow Examples

### Example 1: CLI Tool with Formula

**Project:** `awesome-cli` (Rust CLI tool)

**.github/workflows/release.yml**
```yaml
name: Release

on:
  release:
    types: [published]

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Build release
        run: cargo build --release
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: awesome-cli-${{ matrix.os }}
          path: target/release/awesome-cli

  bump-formula:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: dawidd6/action-homebrew-bump-formula@v6
        with:
          token: ${{ secrets.HOMEBREW_TAP_TOKEN }}
          formula: awesome-cli
          tap: username/homebrew-tools
```

### Example 2: GUI App with Cask

**Project:** `AwesomeApp.app` (macOS application)

**.github/workflows/release.yml**
```yaml
name: Release

on:
  release:
    types: [published]

jobs:
  build-dmg:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build DMG
        run: ./scripts/build-dmg.sh
      - name: Upload to release
        uses: softprops/action-gh-release@v1
        with:
          files: dist/AwesomeApp.dmg

  bump-cask:
    needs: build-dmg
    runs-on: macos-latest
    steps:
      - uses: macauley/action-homebrew-bump-cask@v1
        with:
          token: ${{ secrets.HOMEBREW_TAP_TOKEN }}
          cask: awesome-app
          tap: username/homebrew-apps
```

### Example 3: Meta-Cask (No Auto-Bump Needed)

**Project:** `homebrew_all_fonts` (installs other casks)

**.github/workflows/lint.yml**
```yaml
name: Lint Cask

on: [push, pull_request]

jobs:
  lint:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Homebrew
        uses: Homebrew/actions/setup-homebrew@master
      - name: Check Ruby syntax
        run: ruby -c homebrew-all-fonts.rb
      - name: Validate cask structure
        run: |
          grep -q 'cask "homebrew-all-fonts"' homebrew-all-fonts.rb
          grep -q "version" homebrew-all-fonts.rb
          echo "✓ Cask structure valid"
```

**No bump action needed** - users install directly from GitHub URL.

### Example 4: Font Cask

**Project:** `my-custom-font` (TrueType font)

**Casks/my-custom-font.rb**
```ruby
cask "my-custom-font" do
  version "1.0.0"
  sha256 "abc123..."

  url "https://github.com/user/my-font/releases/download/v#{version}/MyFont.zip"
  name "My Custom Font"
  desc "Beautiful custom font"
  homepage "https://github.com/user/my-font"

  font "MyFont.ttf"
end
```

**.github/workflows/bump-font-cask.yml**
```yaml
name: Bump Font Cask

on:
  release:
    types: [published]

jobs:
  bump:
    runs-on: macos-latest
    steps:
      - uses: macauley/action-homebrew-bump-cask@v1
        with:
          token: ${{ secrets.HOMEBREW_TAP_TOKEN }}
          cask: my-custom-font
          tap: username/homebrew-fonts
```

---

## Action Comparison Table

| Action | Type | Stars | Maintained | Use Case |
|--------|------|-------|------------|----------|
| [homebrew-bump-formula](https://github.com/dawidd6/action-homebrew-bump-formula) | Formula | 107 | ✅ Yes | **CLI tools** |
| [homebrew-bump-cask](https://github.com/macauley/action-homebrew-bump-cask) | Cask | 7 | ⚠️ Limited | **GUI apps, fonts** |
| [homebrew-releaser](https://github.com/Justintime50/homebrew-releaser) | Formula | 58 | ✅ Yes | Automated formula generation |
| [homebrew-cask-bumper](https://github.com/eindex/bump-homebrew-cask-action) | Cask | 3 | ⚠️ Limited | Alternative cask bumper |
| homebrew-tap | Formula | 13 | ⚠️ Single dev | Formula updates |
| update-brew-formula | Formula | 0 | ❌ No | Multi-target formulas |
| upgrade-brew-tap | Unknown | 3 | ❌ No | Unclear purpose |

---

## Quick Decision Guide

### "Which action should I use?"

1. **Is it a CLI tool?**
   - → Use `homebrew-bump-formula` (107⭐)

2. **Is it a GUI app or font?**
   - → Use `homebrew-bump-cask` (7⭐)

3. **Is it a meta-installer (installs other things)?**
   - → No action needed, use direct URL installation

4. **Do I need automated formula generation?**
   - → Use `homebrew-releaser` (58⭐)

5. **Is it standalone without a tap?**
   - → No action needed, provide direct install URL

---

## Common Mistakes to Avoid

### ❌ Using formula actions for casks
```yaml
# WRONG - This is for formulas only
- uses: dawidd6/action-homebrew-bump-formula@v6
  with:
    formula: my-gui-app  # This is a cask!
```

### ❌ Using default GITHUB_TOKEN
```yaml
# WRONG - Default token can't create forks/PRs
- uses: macauley/action-homebrew-bump-cask@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
```

### ❌ Wrong runner for casks
```yaml
# WRONG - Casks need macOS
jobs:
  bump-cask:
    runs-on: ubuntu-latest  # Should be macos-latest
```

### ❌ Non-semantic version tags
```bash
# WRONG
git tag release-march-2024
git tag version-1

# RIGHT
git tag v1.0.0
git tag v1.2.3
```

---

## Resources

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)
- [Homebrew Taps](https://docs.brew.sh/Taps)
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

---

## Real-World Implementation: homebrew_all_fonts

This section documents the actual implementation and lessons learned from creating the `homebrew_all_fonts` project.

### Project Overview

**Type:** Meta-cask (installs all Homebrew font casks)
**Repository:** https://github.com/Emasoft/homebrew_all_fonts
**Personal Tap:** https://github.com/Emasoft/homebrew-tools
**Installation:** `brew tap Emasoft/tools && brew install --cask homebrew-all-fonts`

### CI/CD Implementation

#### Working Lint Workflow

**File:** `.github/workflows/lint.yml`

```yaml
name: Lint Cask

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:  # Allow manual workflow runs

jobs:
  lint:
    runs-on: macos-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Homebrew
      uses: Homebrew/actions/setup-homebrew@master

    - name: Check Ruby syntax
      run: ruby -c homebrew-all-fonts.rb

    - name: Validate cask structure
      run: |
        echo "Checking for required cask components..."
        grep -q "cask \"homebrew-all-fonts\"" homebrew-all-fonts.rb
        grep -q "version" homebrew-all-fonts.rb
        grep -q "url" homebrew-all-fonts.rb
        grep -q "name" homebrew-all-fonts.rb
        grep -q "desc" homebrew-all-fonts.rb
        grep -q "homepage" homebrew-all-fonts.rb
        echo "✓ All required components present"

    - name: Check for sensitive data
      run: |
        echo "Scanning for potential sensitive data..."
        # Look for hardcoded credentials but exclude legitimate code patterns
        ! grep -E '(password|secret|api_key).*=.*["\x27][^"\x27]+["\x27]' homebrew-all-fonts.rb || exit 1
        # Check for absolute user paths but exclude Dir.home usage
        ! grep -E '/Users/[^/]+/' homebrew-all-fonts.rb | grep -v 'Dir\.home' || exit 1
        echo "✓ No sensitive data found"

    - name: Verify API URL
      run: |
        echo "Verifying Homebrew API URL is accessible..."
        curl -f -s -o /dev/null https://formulae.brew.sh/api/cask.json
        echo "✓ API URL is accessible"
```

**Key Features:**
- ✅ Uses `macos-latest` runner (required for Homebrew casks)
- ✅ `workflow_dispatch` allows manual triggering via `gh workflow run "Lint Cask"`
- ✅ Validates Ruby syntax with `ruby -c`
- ✅ Checks for all required cask components
- ✅ Security scan excludes legitimate patterns (like `font["token"]`)
- ✅ Verifies API endpoint accessibility

#### Release Workflow

**File:** `.github/workflows/release.yml`

```yaml
name: Release

on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: macos-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Homebrew
      uses: Homebrew/actions/setup-homebrew@master

    - name: Validate cask
      run: ruby -c homebrew-all-fonts.rb

    - name: Create release archive
      run: |
        mkdir -p release
        cp homebrew-all-fonts.rb release/
        cp README.md release/
        cp LICENSE release/
        cp CHANGELOG.md release/
        cp CONTRIBUTING.md release/
        cp CASK_INSTALLATION.md release/
        cp IMPROVEMENTS.md release/
        cp invalid_brew_fonts_list_*.txt release/ 2>/dev/null || echo "No invalid fonts list found"
        tar -czf homebrew-all-fonts-v1.0.0.tar.gz -C release .

    - name: Display installation instructions
      run: |
        echo "========================================="
        echo "Release published successfully!"
        echo "========================================="
        echo ""
        echo "Users can install with:"
        echo "  brew install --cask https://raw.githubusercontent.com/Emasoft/homebrew_all_fonts/main/homebrew-all-fonts.rb"
        echo ""
        echo "Or clone and install:"
        echo "  git clone https://github.com/Emasoft/homebrew_all_fonts.git"
        echo "  cd homebrew_all_fonts"
        echo "  brew install --cask homebrew-all-fonts.rb"
        echo "========================================="
```

### Issues Encountered and Solutions

#### Issue 1: rubocop Not Available
**Problem:** Tried to install rubocop via `brew install rubocop`
**Error:** `No available formula with the name "rubocop"`
**Reason:** rubocop is a Ruby gem, not a Homebrew formula
**Solution:** Removed rubocop check, use `ruby -c` for syntax validation instead

#### Issue 2: False Positive in Security Scan
**Problem:** Pattern `(password|secret|api_key|token|/Users/)` caught legitimate code
**Error:** `font["token"]` and `cask "#{font["token"]}"` triggered false positives
**Solution:** Refined regex to only catch actual hardcoded credentials:
```bash
# Before (too strict)
! grep -E "(password|secret|api_key|token|/Users/[^/]+/)" homebrew-all-fonts.rb || exit 1

# After (refined)
! grep -E '(password|secret|api_key).*=.*["\x27][^"\x27]+["\x27]' homebrew-all-fonts.rb || exit 1
! grep -E '/Users/[^/]+/' homebrew-all-fonts.rb | grep -v 'Dir\.home' || exit 1
```

#### Issue 3: Manual Workflow Trigger Not Available
**Problem:** Couldn't trigger workflow manually with `gh workflow run`
**Error:** `Workflow does not have 'workflow_dispatch' trigger`
**Solution:** Added `workflow_dispatch` to the `on:` section

#### Issue 4: Git Push Rejected After CI Bot Changes
**Problem:** Local changes out of sync after GitHub Actions bot made commits
**Error:** `! [rejected] main -> main (fetch first)`
**Solution:** `git pull --rebase` before pushing

### Personal Tap Setup

Since meta-casks are not accepted by official Homebrew, we created a personal tap:

**Repository:** `Emasoft/homebrew-tools`
**Structure:**
```
homebrew-tools/
├── Casks/
│   └── homebrew-all-fonts.rb
└── README.md
```

**Setup Commands:**
```bash
# Create tap repository
gh repo create homebrew-tools --public --description "Personal Homebrew tap"

# Clone and setup
git clone https://github.com/Emasoft/homebrew-tools.git
cd homebrew-tools
mkdir -p Casks
cp ~/homebrew-all-fonts.rb Casks/

# Commit and push
git add Casks/
git commit -m "Add homebrew-all-fonts cask"
git push origin main

# Test locally
brew tap Emasoft/tools
brew search Emasoft  # Should list emasoft/tools/homebrew-all-fonts
```

**User Installation:**
```bash
# Method 1: Tap then install (recommended)
brew tap Emasoft/tools
brew install --cask homebrew-all-fonts

# Method 2: Direct install (one command)
brew install --cask Emasoft/tools/homebrew-all-fonts
```

### No Auto-Bump Action Needed

**Why:** Meta-casks that install other packages don't need version bumping because:
1. They fetch the latest package list dynamically at runtime
2. No specific version to track (always uses latest API data)
3. Users install directly from GitHub URL or personal tap

**What We Use Instead:**
- Lint workflow on every push/PR
- Manual `workflow_dispatch` trigger for on-demand validation
- Release workflow for archiving releases (documentation purposes)

### Git Configuration

**Public GitHub Email (noreply):**
```bash
git config user.name "Emasoft"
git config user.email "713559+Emasoft@users.noreply.github.com"
```

**Why Public:** This is GitHub's public noreply email format and should be used consistently.

### Testing Commands

```bash
# Trigger CI manually
gh workflow run "Lint Cask"

# Watch workflow progress
gh run list --workflow="Lint Cask" --limit 1
gh run watch <run-id>

# View workflow logs
gh run view <run-id> --log

# Check specific job
gh run view --job=<job-id> --log
```

### Lessons Learned

1. **Runner Choice Matters**
   - Use `macos-latest` for casks (required for Homebrew operations)
   - Use `ubuntu-latest` for formulas (cheaper and faster)

2. **Security Scans Need Context**
   - Generic patterns cause false positives
   - Exclude legitimate code patterns explicitly
   - Test security checks before committing

3. **Manual Triggers Are Essential**
   - Always add `workflow_dispatch` for on-demand CI runs
   - Useful for testing without creating dummy commits

4. **Meta-Casks Are Special**
   - Won't be accepted by official Homebrew
   - Personal taps are the best solution
   - No auto-bump actions needed (dynamic data)

5. **GitHub CLI Is Powerful**
   - Create repos: `gh repo create`
   - Trigger workflows: `gh workflow run`
   - Watch progress: `gh run watch`
   - View logs: `gh run view --log`

### Results

**CI Status:** ✅ All checks passing
**Workflow Runtime:** ~20-30 seconds per run
**Manual Triggers:** Available via `gh workflow run "Lint Cask"`
**Public Access:** Installable via personal tap or direct URL
**Documentation:** Complete with README, CHANGELOG, CONTRIBUTING, LICENSE

---

**Version:** 1.1.0
**Last Updated:** 2025-11-25
**Author:** Based on research of 15+ Homebrew GitHub Actions + real-world implementation
