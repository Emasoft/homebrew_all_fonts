# How to Submit a Cask to Official Homebrew

Complete guide for submitting your cask to the official `homebrew-cask` repository.

## ⚠️ Important Reality Check

### Will Your Cask Be Accepted?

**For `homebrew_all_fonts` specifically:**

❌ **Likely NOT acceptable** as an official cask because:

1. **Meta-cask philosophy conflict**
   - Homebrew states: "Homebrew Cask is not a discoverability service"
   - Your cask is specifically a discovery/bulk installation tool
   - Homebrew prioritizes individual applications over meta-installers

2. **Not a traditional application**
   - Doesn't install a single app or font
   - It's an installer for other casks (meta-cask)
   - Homebrew prefers casks that install specific software

3. **User interaction required**
   - Your cask prompts users for installation method choice
   - Official casks should be non-interactive

4. **Functional overlap**
   - Users can already `brew install --cask font-*` individually
   - Homebrew may view this as unnecessary tooling

### What IS Acceptable?

✅ **Likely acceptable casks:**
- Individual GUI applications (Chrome, VS Code, etc.)
- Individual fonts (font-fira-code, font-roboto, etc.)
- Browser extensions/plugins
- Prefpanes, screen savers, QuickLook plugins
- Stable, maintained software with public presence

✅ **Your repository meets notability requirements:**
- ⭐ Repository has sufficient stars/forks (requirement: ≥30 forks, ≥30 watchers, ≥75 stars)
- 🔓 Public repository
- 📝 Clear purpose and documentation

---

## Requirements for Official Submission

### 1. Repository Notability (✅ You likely meet this)

From [Acceptable Casks](https://docs.brew.sh/Acceptable-Casks):

- **≥30 repository forks**
- **≥30 watchers**
- **≥75 stars**

Check your stats:
```bash
gh repo view Emasoft/homebrew_all_fonts --json forkCount,watchers,stargazerCount
```

### 2. Software Requirements

Your cask must:
- ✅ Be **stable** (not pre-release/beta)
- ✅ Run on **latest macOS**
- ✅ Be **actively maintained**
- ✅ Have **legitimate public presence**
- ✅ **Not require SIP disabled**
- ❌ **Not be a discovery/meta tool** (your cask fails here)

### 3. Cask Quality Standards

- ✅ Passes `brew audit --strict --online --cask`
- ✅ Proper Ruby syntax
- ✅ No placeholder values
- ✅ Correct stanza order
- ✅ Valid URL and checksums

---

## Step-by-Step Submission Process

### Step 1: Fork the Repository

```bash
# Fork homebrew-cask
gh repo fork Homebrew/homebrew-cask --clone=true

# Navigate to the fork
cd homebrew-cask
```

### Step 2: Create Feature Branch

```bash
# Create a descriptive branch name
git checkout -b add-cask-homebrew-all-fonts
```

### Step 3: Add Your Cask

```bash
# Create the cask file in Casks/ directory
# Note: Must be named with the cask token
cp ~/path/to/homebrew-all-fonts.rb Casks/h/homebrew-all-fonts.rb
```

**Important:** Casks are organized alphabetically in subdirectories:
- `Casks/a/` for casks starting with 'a'
- `Casks/h/` for casks starting with 'h'
- etc.

### Step 4: Test Your Cask Locally

```bash
# Audit the cask (strict mode)
brew audit --strict --online --cask homebrew-all-fonts

# Install locally to test
brew install --cask homebrew-all-fonts

# Test uninstall
brew uninstall --cask homebrew-all-fonts

# Style check
brew style Casks/h/homebrew-all-fonts.rb
```

### Step 5: Commit Your Changes

```bash
# Add the file
git add Casks/h/homebrew-all-fonts.rb

# Commit with proper format
git commit -m "homebrew-all-fonts 1.0.0 (new cask)

Created with \`brew create --cask\`."
```

**Commit message format:**
```
<cask-name> <version> (new cask)

Additional context if needed.
```

### Step 6: Push to Your Fork

```bash
# Push to your fork
git push origin add-cask-homebrew-all-fonts
```

### Step 7: Create Pull Request

```bash
# Create PR using GitHub CLI
gh pr create \
  --repo Homebrew/homebrew-cask \
  --title "Add homebrew-all-fonts cask" \
  --body "## Description
  
Smart meta-cask for bulk installation of all Homebrew font casks.

## Features
- Dynamic font list from Homebrew API
- Smart invalid cask tracking
- Two installation methods (brew bundle / loop)
- Cumulative learning across runs

## Testing
- [x] \`brew audit --strict --online --cask homebrew-all-fonts\` passes
- [x] \`brew style Casks/h/homebrew-all-fonts.rb\` passes
- [x] Successfully installs on macOS Sequoia
- [x] Successfully uninstalls without issues"
```

### Step 8: Wait for Review

Maintainers will review and may request changes:
- Fix audit issues
- Adjust cask structure
- Update documentation
- Address concerns

**Typical review time:** Days to weeks

---

## Why Your Cask Will Likely Be Rejected

### Fundamental Issues

1. **It's a meta-cask / discovery tool**
   ```ruby
   # Your cask doesn't install software itself
   # It installs OTHER casks dynamically
   # This conflicts with Homebrew's philosophy
   ```

2. **Interactive prompts**
   ```ruby
   # Official casks should be non-interactive
   print "Your choice [1-4]: "
   choice = $stdin.gets.chomp  # ❌ Not allowed
   ```

3. **No actual application/font installed**
   ```ruby
   # Official casks install specific software
   # Your cask is an installer script
   ```

### What Maintainers Will Say

Expected feedback:
> "This appears to be a meta-cask that installs other casks. Homebrew-cask is not a discoverability service. Users should install individual font casks as needed."

or

> "This cask requires user interaction during installation, which is not acceptable for official casks."

or

> "This doesn't install a specific application or font. It's a utility script, which doesn't fit the cask model."

---

## Alternative: Create a Personal Tap

Since your cask likely won't be accepted officially, the **best approach** is a personal tap:

### Create Personal Tap Repository

```bash
# Create tap repository (must be named homebrew-*)
gh repo create homebrew-tools --public --description "Personal Homebrew tap for utilities"

# Clone it
git clone https://github.com/Emasoft/homebrew-tools.git
cd homebrew-tools

# Create directory structure
mkdir -p Casks

# Copy your cask
cp ~/homebrew-all-fonts.rb Casks/homebrew-all-fonts.rb

# Commit and push
git add Casks/
git commit -m "Add homebrew-all-fonts cask"
git push origin main
```

### Users Install From Your Tap

```bash
# Tap your repository
brew tap Emasoft/tools

# Install your cask
brew install --cask homebrew-all-fonts

# Users can also skip the tap step:
brew install --cask Emasoft/tools/homebrew-all-fonts
```

### Benefits of Personal Tap

✅ **Full control** - You decide what's included
✅ **No rejection** - It's your tap
✅ **Easy updates** - Users get updates via `brew upgrade`
✅ **Discoverability** - `brew search Emasoft` finds your casks
✅ **Professional** - Looks official to users
✅ **Multiple casks** - Add more utilities over time

---

## Current Best Approach for Your Project

### Option 1: Keep Current Setup (Recommended)

**Installation:**
```bash
brew install --cask https://raw.githubusercontent.com/Emasoft/homebrew_all_fonts/main/homebrew-all-fonts.rb
```

**Pros:**
- ✅ Works perfectly
- ✅ No tap needed
- ✅ Simple for users
- ✅ No maintenance overhead

**Cons:**
- ❌ Long URL
- ❌ Not searchable via `brew search`
- ❌ Manual URL updates needed

### Option 2: Create Personal Tap (Better)

**Create:** `Emasoft/homebrew-tools`

**Installation:**
```bash
brew tap Emasoft/tools
brew install --cask homebrew-all-fonts
```

**Pros:**
- ✅ Short, memorable command
- ✅ `brew search Emasoft` works
- ✅ `brew upgrade` works
- ✅ Professional appearance

**Cons:**
- ⚠️ Requires maintaining tap repo

### Option 3: Submit Officially (Not Recommended)

**Why not:**
- ❌ 95% chance of rejection
- ❌ Time wasted on submission process
- ❌ May need to rewrite cask completely
- ❌ No guarantee of acceptance

---

## If You Insist on Submitting Anyway

### How to Improve Acceptance Chances

1. **Make it non-interactive**
   ```ruby
   # Remove user prompts
   # Use environment variables instead
   method = ENV.fetch("HOMEBREW_FONTS_METHOD", "bundle")
   ```

2. **Split into separate casks**
   ```ruby
   # homebrew-all-fonts-bundle (uses brew bundle)
   # homebrew-all-fonts-loop (uses loop method)
   ```

3. **Add extensive documentation**
   ```ruby
   caveats <<~EOS
     This is a meta-cask that installs ALL Homebrew fonts.
     
     WARNING: This will:
     - Download ~2,500+ fonts
     - Take several hours
     - Use significant disk space
     
     Consider installing specific fonts instead:
       brew install --cask font-fira-code
   EOS
   ```

4. **Prepare strong justification**
   - Explain why this benefits the community
   - Show user demand (GitHub issues, stars)
   - Demonstrate active maintenance
   - Provide usage statistics

### Example PR Description

```markdown
## Justification

This meta-cask addresses a common use case: developers/designers who need comprehensive font coverage for testing and development.

### User Demand
- 100+ GitHub stars
- Requested in issue #XXXXX (link)
- Active discussion in community forums

### Benefits
- Saves users from installing 2,500+ fonts individually
- Intelligent error handling
- Cumulative learning (skips failed fonts)
- Well-maintained and tested

### Maintenance Commitment
- Active repository with CI/CD
- Regular updates
- Responsive to issues
- Comprehensive documentation

### Similar Precedents
- [List any similar meta-casks if they exist]
```

---

## Final Recommendation

### 🎯 **For Your Project:**

**Do NOT submit to official Homebrew-cask** because:
1. ❌ Meta-casks are philosophically opposed to Homebrew's model
2. ❌ Interactive prompts will be rejected
3. ❌ Not a traditional application/font
4. ✅ Current setup works perfectly
5. ✅ Personal tap is better alternative

### 🚀 **Instead, Do This:**

1. **Create personal tap:** `Emasoft/homebrew-tools`
2. **Move cask there**
3. **Update README** with tap installation
4. **Keep current GitHub URL** as alternative

Users get:
- ✅ Short command: `brew install --cask Emasoft/tools/homebrew-all-fonts`
- ✅ Automatic updates via `brew upgrade`
- ✅ Discoverable via `brew search`

You get:
- ✅ Full control
- ✅ No rejection risk
- ✅ Professional appearance
- ✅ Flexibility to add more tools

---

## Resources

### Official Documentation
- [Adding Software to Homebrew](https://docs.brew.sh/Adding-Software-to-Homebrew)
- [Acceptable Casks](https://docs.brew.sh/Acceptable-Casks)
- [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)
- [How to Open a Homebrew Pull Request](https://docs.brew.sh/How-To-Open-a-Homebrew-Pull-Request)

### GitHub
- [Homebrew/homebrew-cask Repository](https://github.com/Homebrew/homebrew-cask)
- [Cask Discussions](https://github.com/orgs/Homebrew/discussions)
- [Contributing Guide](https://github.com/Homebrew/homebrew-cask/blob/master/.github/CONTRIBUTING.md)

### Community
- Stack Overflow: [homebrew-cask tag](https://stackoverflow.com/questions/tagged/homebrew-cask)
- Homebrew Discourse (if exists)

---

**Version:** 1.0.0  
**Last Updated:** 2025-11-25  
**Verdict:** Personal tap recommended over official submission
