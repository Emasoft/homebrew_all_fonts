# Homebrew Expert Skill

Expert guidance for creating, publishing, and automating Homebrew packages (formulas and casks) with GitHub Actions, based on real-world implementation experience.

## Table of Contents

1. [Understanding Homebrew Packages](#understanding-homebrew-packages)
2. [Writing Casks](#writing-casks)
3. [GitHub Actions CI/CD](#github-actions-cicd)
4. [Personal Taps](#personal-taps)
5. [Official Homebrew Submission](#official-homebrew-submission)
6. [Common Issues & Solutions](#common-issues--solutions)
7. [Testing & Validation](#testing--validation)
8. [Real-World Best Practices](#real-world-best-practices)

---

## Understanding Homebrew Packages

### Formulas vs Casks

**Formulas:**
- Command-line tools, libraries, services
- Examples: git, node, python, nginx
- Install: `brew install <name>`
- Location: `homebrew-core` or personal taps

**Casks:**
- GUI applications, fonts, browser plugins
- Examples: Google Chrome, VS Code, fonts
- Install: `brew install --cask <name>`
- Location: `homebrew-cask` or personal taps

**Meta-Casks:**
- Special casks that install other casks/formulas
- Use preflight/postflight hooks
- **NOT accepted in official Homebrew**
- Best suited for personal taps

### Decision Tree

```
Is it a command-line tool?
├─ YES → Formula
└─ NO → Is it a GUI app or font?
   ├─ YES → Cask
   └─ NO → Is it a meta-installer?
      └─ YES → Cask (personal tap only)
```

---

## Writing Casks

### Basic Structure

```ruby
cask "my-app" do
  version "1.0.0"
  sha256 "abc123..."

  url "https://example.com/downloads/MyApp-#{version}.dmg"
  name "My Application"
  desc "Short description of what this app does"
  homepage "https://example.com"

  app "MyApp.app"
end
```

### Required Stanzas

1. **cask "name"** - Lowercase with hyphens only
2. **version** - Software version (or `:latest`)
3. **url** - Download URL (can use `#{version}`)
4. **name** - Human-readable name
5. **desc** - One-line description
6. **homepage** - Official website or repository

### Font Cask Example

```ruby
cask "font-my-font" do
  version "2.1.0"
  sha256 "def456..."

  url "https://github.com/user/font/releases/download/v#{version}/Font.zip"
  name "My Font"
  desc "Beautiful custom font family"
  homepage "https://github.com/user/font"

  font "MyFont-Regular.ttf"
  font "MyFont-Bold.ttf"
  font "MyFont-Italic.ttf"
end
```

### Advanced Features

#### Installation Hooks

```ruby
# Run code before installation
preflight do
  system_command "/usr/bin/killall", args: ["MyApp"]
end

# Run code after installation
postflight do
  system_command "#{appdir}/MyApp.app/Contents/MacOS/setup"
end
```

#### Meta-Cask with Dynamic Installation

```ruby
cask "homebrew-all-fonts" do
  version "1.0.0"
  sha256 :no_check

  url "https://formulae.brew.sh/api/cask.json"
  name "Homebrew All Fonts"
  desc "Installs all available Homebrew font casks"
  homepage "https://github.com/user/repo"

  preflight do
    require "json"

    # Parse cask list
    cask_json = File.read(staged_path / "cask.json")
    casks = JSON.parse(cask_json)

    # Filter for fonts
    fonts = casks.select { |c| c["ruby_source_path"]&.include?("Casks/font/") }

    # Load invalid fonts list if exists
    invalid_fonts_file = Dir.glob("invalid_brew_fonts_list_*.txt").max_by { |f| File.mtime(f) }
    if invalid_fonts_file && File.exist?(invalid_fonts_file)
      invalid_fonts = File.readlines(invalid_fonts_file).map(&:strip)
      fonts.reject! { |f| invalid_fonts.include?(f["token"]) }
    end

    # Install fonts
    fonts.each { |font| system "brew", "install", "--cask", font["token"] }
  end

  caveats "All fonts installed to ~/Library/Fonts/"
end
```

#### Architecture-Specific URLs

```ruby
if Hardware::CPU.intel?
  url "https://example.com/MyApp-Intel.dmg"
  sha256 "abc123..."
else
  url "https://example.com/MyApp-AppleSilicon.dmg"
  sha256 "def456..."
end
```

### Naming Conventions

**Applications:**
- `my-app` (lowercase, hyphens)
- Remove spaces: `My App` → `my-app`
- Remove special chars: `My App!` → `my-app`

**Fonts:**
- Must start with `font-`
- Family name: `font-roboto`
- Variant: `font-roboto-mono`

---

## GitHub Actions CI/CD

### Lint Workflow (Working Example)

**File:** `.github/workflows/lint.yml`

```yaml
name: Lint Cask

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:  # Allow manual triggering

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
        # Look for hardcoded credentials but exclude legitimate patterns
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

**Key Points:**
- Use `macos-latest` runner for casks (Homebrew requires macOS)
- Include `workflow_dispatch` for manual triggering
- Validate Ruby syntax with `ruby -c`
- Check all required stanzas
- Security scan with context-aware patterns
- Verify external dependencies

### Release Workflow

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
      run: ruby -c your-cask.rb

    - name: Create release archive
      run: |
        mkdir -p release
        cp your-cask.rb release/
        cp README.md release/
        cp LICENSE release/
        tar -czf release.tar.gz -C release .

    - name: Display installation instructions
      run: |
        echo "Install with:"
        echo "  brew install --cask https://raw.githubusercontent.com/user/repo/main/your-cask.rb"
```

### Manual Workflow Triggering

```bash
# Trigger workflow
gh workflow run "Lint Cask"

# Watch progress
gh run list --workflow="Lint Cask" --limit 1
gh run watch <run-id>

# View logs
gh run view <run-id> --log
```

---

## Personal Taps

Personal taps provide a professional installation experience without official Homebrew approval.

### Why Use Personal Taps

✅ **Advantages:**
- Full control over content
- No rejection risk
- Easy updates for users (`brew upgrade`)
- Professional appearance
- Multiple casks in one tap
- Searchable with `brew search`

### Setup Process

**1. Create Repository**

```bash
# Repository MUST be named: homebrew-<tap-name>
gh repo create homebrew-tools --public --description "Personal Homebrew tap"
```

**2. Clone and Setup Structure**

```bash
git clone https://github.com/username/homebrew-tools.git
cd homebrew-tools

# Create Casks directory
mkdir -p Casks

# Add your cask
cp ~/my-cask.rb Casks/my-cask.rb
```

**3. Directory Structure**

```
homebrew-tools/
├── Casks/
│   ├── my-app.rb
│   └── my-font.rb
├── Formula/          # Optional: for formulas
│   └── my-tool.rb
└── README.md
```

**4. Commit and Push**

```bash
git add Casks/
git commit -m "Add my-cask cask"
git push origin main
```

**5. Test Locally**

```bash
# Tap the repository
brew tap username/tools

# Search for your casks
brew search username
# Should show: username/tools/my-cask

# Install
brew install --cask my-cask
```

### User Installation

**Method 1: Tap then install (recommended)**
```bash
brew tap username/tools
brew install --cask my-cask
```

**Method 2: Direct install**
```bash
brew install --cask username/tools/my-cask
```

**Method 3: Direct URL**
```bash
brew install --cask https://raw.githubusercontent.com/username/homebrew-tools/main/Casks/my-cask.rb
```

---

## Official Homebrew Submission

### Acceptance Requirements

#### 1. Repository Notability

✅ **Required:**
- ≥30 forks
- ≥30 watchers
- ≥75 stars

**Check stats:**
```bash
gh repo view user/repo --json forkCount,watchers,stargazerCount
```

#### 2. Software Requirements

✅ **Must be:**
- Stable release (not beta/alpha)
- Actively maintained
- Runs on latest macOS
- Free from malware

❌ **Cannot be:**
- Pre-release versions
- Requires SIP disabled
- Meta-installer or bulk installer
- Interactive (requires user input)
- Discovery/cataloging tool

#### 3. Quality Standards

✅ **Must pass:**
```bash
brew audit --strict --online --cask your-cask.rb
brew style your-cask.rb
```

### Submission Process

**1. Fork homebrew-cask**
```bash
gh repo fork Homebrew/homebrew-cask --clone=true
cd homebrew-cask
```

**2. Create branch**
```bash
git checkout -b add-cask-my-app
```

**3. Add cask to correct directory**
```bash
# my-app → Casks/m/my-app.rb
# font-roboto → Casks/f/font-roboto.rb
cp ~/my-app.rb Casks/m/my-app.rb
```

**4. Test thoroughly**
```bash
brew audit --strict --online --cask my-app
brew style Casks/m/my-app.rb
brew install --cask my-app
brew uninstall --cask my-app
brew reinstall --cask my-app
```

**5. Commit with proper format**
```bash
git add Casks/m/my-app.rb
git commit -m "my-app 1.0.0 (new cask)

Created with \`brew create --cask\`."
```

**6. Push and create PR**
```bash
git push origin add-cask-my-app
gh pr create --repo Homebrew/homebrew-cask --title "Add my-app cask"
```

### Why Meta-Casks Are Rejected

**Homebrew philosophy:**
> "Homebrew Cask is not a discoverability service"

❌ **Rejection reasons:**
1. Discovery tool conflict
2. Not a traditional application
3. User interaction required
4. Functional overlap with `brew search`

**Expected response:**
> "This appears to be a meta-cask that installs other casks. Homebrew-cask is not a discoverability service. Users should install individual casks as needed."

---

## Common Issues & Solutions

### Issue 1: rubocop Not Available

**Problem:** `brew install rubocop` fails
**Error:** `No available formula with the name "rubocop"`
**Reason:** rubocop is a Ruby gem, not a Homebrew formula
**Solution:** Use `ruby -c` for syntax validation instead

### Issue 2: False Positive in Security Scan

**Problem:** Pattern catches legitimate code like `font["token"]`
**Solution:** Refine regex to only catch actual credentials

```bash
# Too strict
! grep -E "(password|secret|api_key|token)" file.rb

# Better
! grep -E '(password|secret|api_key).*=.*["\x27][^"\x27]+["\x27]' file.rb
```

### Issue 3: Missing Manual Trigger

**Problem:** `gh workflow run` fails with "no workflow_dispatch trigger"
**Solution:** Add to workflow:

```yaml
on:
  push:
    branches: [ main ]
  workflow_dispatch:  # Add this
```

### Issue 4: Git Push Rejected After CI Changes

**Problem:** Local out of sync after GitHub Actions commits
**Error:** `! [rejected] main -> main (fetch first)`
**Solution:** `git pull --rebase && git push`

---

## Testing & Validation

### Local Testing Commands

```bash
# Ruby syntax
ruby -c my-cask.rb

# Audit (basic)
brew audit --cask my-cask.rb

# Audit (strict - before official submission)
brew audit --strict --online --cask my-cask.rb

# Style check
brew style my-cask.rb

# Test installation
brew install --cask my-cask.rb

# Test uninstallation
brew uninstall --cask my-cask

# Test reinstallation
brew reinstall --cask my-cask
```

### CI Testing

```bash
# Trigger manually
gh workflow run "Lint Cask"

# Check status
gh run list --workflow="Lint Cask" --limit 1

# Watch progress
gh run watch <run-id>

# View detailed logs
gh run view <run-id> --log
gh run view --job=<job-id> --log
```

---

## Real-World Best Practices

### Git Configuration

Use GitHub's noreply email for public projects:

```bash
git config user.name "YourUsername"
git config user.email "12345+YourUsername@users.noreply.github.com"
```

### Runner Choice

- **Casks:** Use `macos-latest` (Homebrew requires macOS)
- **Formulas:** Use `ubuntu-latest` (cheaper and faster)

### Security Scanning

- Test patterns before committing
- Exclude legitimate code patterns explicitly
- Avoid generic patterns that cause false positives

### Workflow Design

- Always include `workflow_dispatch` for manual runs
- Validate all required stanzas
- Check external dependencies (APIs, URLs)
- Keep workflows focused and fast (20-30 seconds)

### Documentation

Essential files for public casks:
- `README.md` - Installation instructions, features
- `LICENSE` - MIT or similar
- `CHANGELOG.md` - Version history
- `CONTRIBUTING.md` - Contribution guidelines
- `.gitignore` - Exclude large/temporary files

### Common Mistakes to Avoid

❌ **Wrong:**
```ruby
# Spaces in name
cask "My App" do

# No version
url "https://example.com/app.dmg"

# Hardcoded paths
app "/Applications/MyApp.app"

# Missing sha256
version "1.0.0"
url "..."
```

✅ **Correct:**
```ruby
# Lowercase with hyphens
cask "my-app" do

# Always include version
version "1.0.0"

# Relative paths
app "MyApp.app"

# Include sha256
sha256 "abc123..."
```

---

## When to Use This Skill

This skill should be invoked when the user:
- Asks to create a Homebrew cask or formula
- Wants to publish to Homebrew (official or personal tap)
- Needs to set up CI/CD for Homebrew packages
- Asks about GitHub Actions for Homebrew
- Wants to automate Homebrew package testing
- Encounters issues with Homebrew submission
- Needs to create a meta-cask or bulk installer
- Asks about Homebrew package validation
- Wants to understand Homebrew acceptance criteria

## Real-World Validation

This skill is based on the successful creation and publication of:
- **Project:** homebrew_all_fonts
- **Repository:** https://github.com/Emasoft/homebrew_all_fonts
- **Personal Tap:** https://github.com/Emasoft/homebrew-tools
- **CI Status:** ✅ All checks passing
- **Runtime:** ~20-30 seconds per CI run
- **Result:** Professionally published meta-cask with comprehensive documentation
