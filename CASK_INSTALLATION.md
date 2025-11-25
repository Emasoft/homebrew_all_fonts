# Homebrew All Fonts Cask

A custom Homebrew cask that dynamically downloads and installs all available font casks from Homebrew.

## Features

✅ **Dynamic Font List** - Always gets the latest available fonts from Homebrew API
✅ **Two Installation Methods** - Fast (brew bundle) or Safe (loop with error handling)
✅ **Auto-filtering** - Automatically excludes disabled/broken fonts
✅ **Interactive** - Choose installation method at runtime
✅ **Progress Tracking** - Shows installation progress and summary
✅ **No Manual Updates** - Reinstall to get new fonts automatically

## How It Works

1. Downloads the latest cask list from `https://formulae.brew.sh/api/cask.json`
2. Filters for font casks only (those in `Casks/font/`)
3. Removes known problematic fonts (e.g., `font-brill`)
4. Presents installation options
5. Installs all available fonts

## Installation

### Method 1: Via Personal Tap (Recommended)

```bash
# Tap the repository (one-time setup)
brew tap Emasoft/tools

# Install the cask
brew install --cask homebrew-all-fonts
```

**Benefits:**
- ✅ Short, memorable command
- ✅ Automatic updates via `brew upgrade`
- ✅ Searchable with `brew search Emasoft`

### Method 2: Direct URL Installation

```bash
# Install directly from GitHub URL
brew install --cask https://raw.githubusercontent.com/Emasoft/homebrew_all_fonts/main/homebrew-all-fonts.rb
```

### Method 3: Local Installation

```bash
# Install from local cask file
brew install --cask homebrew-all-fonts.rb
```

## Usage

When you run the installation, you'll be prompted to choose:

1. **Fast Method** - Uses `brew bundle`
   - Fastest installation
   - Stops on first error
   - Best for clean systems

2. **Safe Method** - Installs one by one
   - Slower but more reliable
   - Continues even if fonts fail
   - Shows detailed progress and summary
   - Lists failed fonts at the end

3. **Cancel** - Exit without installing

## Updating Font List

To check for and install new fonts:

```bash
brew reinstall --cask homebrew-all-fonts
```

This will:
- Download the latest font list
- Install any new fonts that weren't available before
- Skip already installed fonts

## Uninstalling

### Uninstall the Cask Only
```bash
brew uninstall --cask homebrew-all-fonts
```
*Note: This does NOT remove the installed fonts*

### Uninstall All Fonts
```bash
brew list --cask | grep '^font-' | xargs brew uninstall --cask
```

### Uninstall Specific Fonts
```bash
brew uninstall --cask font-name-here
```

## Technical Details

### Data Source
- **URL**: `https://formulae.brew.sh/api/cask.json`
- **Filter**: `ruby_source_path` contains `"Casks/font/"`
- **Exclusions**: Known disabled fonts (e.g., `font-brill`)

### What Gets Installed
- All available font casks from Homebrew (~2,500+ fonts)
- Fonts are installed to `~/Library/Fonts/`
- A marker file is created at `~/Library/Application Support/homebrew-all-fonts/`

### Requirements
- macOS
- Homebrew installed
- Internet connection
- Disk space (~5-10 GB recommended)
- Time (installation can take several hours)

## Advantages Over Static Brewfile

| Feature | This Cask | Static Brewfile |
|---------|-----------|-----------------|
| Always up-to-date | ✅ Yes | ❌ No (manual updates needed) |
| Auto-filters broken fonts | ✅ Yes | ❌ No |
| Single command install | ✅ Yes | ✅ Yes |
| Interactive method choice | ✅ Yes | ❌ No |
| Progress tracking | ✅ Yes | ⚠️ Depends |
| Version controlled | ✅ Ruby file | ✅ Brewfile |

## Troubleshooting

### "Permission denied" Error
```bash
chmod +x homebrew-all-fonts.rb
```

### Installation Hangs
- Some fonts may have slow downloads
- Wait or cancel and use the Safe method

### Some Fonts Fail
- This is normal (some fonts have broken sources)
- Use the Safe method to see which fonts failed
- Failed fonts are automatically skipped

### Want to Preview Font List?
```bash
curl -s https://formulae.brew.sh/api/cask.json | \
  jq -r '.[] | select(.ruby_source_path | contains("Casks/font/")) | .token' | \
  grep -v "font-brill" | \
  wc -l
```

### Check Currently Installed Fonts
```bash
brew list --cask | grep '^font-' | wc -l
```

## Examples

### Quick Install (Accept Defaults)
```bash
brew install --cask homebrew-all-fonts.rb
# Choose option 1 or 2 when prompted
```

### Update to Latest Fonts
```bash
# First, update Homebrew
brew update

# Then reinstall to get new fonts
brew reinstall --cask homebrew-all-fonts.rb
```

### Check Installation Status
```bash
cat ~/Library/Application\ Support/homebrew-all-fonts/.installed
```

## Contributing

To add more fonts to the exclusion list, edit the cask file:

```ruby
disabled_fonts = ["font-brill", "font-another-broken-one"]
```

## License

This cask formula is provided as-is. Individual fonts have their own licenses.

## Credits

- Font list from Homebrew Cask API
- All fonts provided by Homebrew community
- Cask formula created for convenient bulk font management

---

**Version**: 1.0.0
**Platform**: macOS (Homebrew)
**Maintained**: Yes (uses live API)
