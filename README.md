# Homebrew All Fonts

A smart Homebrew cask that automatically installs all available font casks from Homebrew with intelligent error handling and memory of failed installations.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-compatible-brightgreen.svg)](https://www.apple.com/macos/)
[![Homebrew](https://img.shields.io/badge/Homebrew-4.0+-orange.svg)](https://brew.sh/)

## Features

✨ **Dynamic Font List** - Always fetches the latest available fonts from Homebrew API  
🛡️ **Smart Error Handling** - Automatically remembers and skips casks that failed installation  
🔄 **Cumulative Learning** - Each run improves the next by maintaining a history of failures  
⚡ **Two Installation Methods** - Fast (brew bundle) or Safe (loop with error handling)  
📊 **Progress Tracking** - Real-time installation progress and detailed summary  
🎯 **Zero Configuration** - Works automatically with no manual intervention required  
📝 **Timestamped History** - All invalid cask lists are preserved with timestamps  
🚀 **Always Up-to-Date** - Reinstall to automatically get new fonts from Homebrew  

## How It Works

1. **Downloads** the latest cask definitions from `https://formulae.brew.sh/api/cask.json`
2. **Filters** for font casks only (those in `Casks/font/`)
3. **Loads** the most recent `invalid_brew_fonts_list_*.txt` to exclude problematic casks
4. **Generates** a temporary Brewfile with valid casks only
5. **Installs** using your chosen method (brew bundle or loop)
6. **Parses** installation logs to detect newly failed casks
7. **Updates** the invalid list with cumulative failures from all runs

## Installation

### Quick Install

```bash
brew install --cask Emasoft/homebrew_all_fonts/homebrew-all-fonts
```

### From GitHub

```bash
# Clone the repository
git clone https://github.com/Emasoft/homebrew_all_fonts.git
cd homebrew_all_fonts

# Install directly from the cask file
brew install --cask homebrew-all-fonts.rb
```

## Usage

When you run the installation, you'll be prompted to choose:

### Option 1: Brew Bundle Method (Fast)
- Fastest installation
- Stops on first error
- Best for clean systems
- Uses `brew bundle` under the hood

### Option 2: Loop Method (Safe)
- Slower but more reliable
- Continues even if casks fail
- Shows detailed progress for each font
- Provides comprehensive summary at the end

### Option 3: Save Brewfile and Exit
- Generates a timestamped Brewfile
- Install later at your convenience
- Useful for reviewing the font list first

## Updating

To install new fonts and update existing ones:

```bash
brew reinstall --cask homebrew-all-fonts
```

This will:
- Download the latest cask definitions
- Automatically skip previously failed casks
- Install any new fonts that weren't available before
- Update the invalid fonts list if new failures occur

## Smart Invalid Cask Management

The cask maintains a cumulative list of casks that failed to install:

### First Run (No existing list)
```
- Downloads all fonts from Homebrew API
- No exclusions applied
- Installs fonts
- Generates: invalid_brew_fonts_list_20251125_150000.txt
```

### Second Run (With existing list)
```
- Loads most recent invalid list (e.g., 362 casks)
- Excludes those 362 casks from installation
- Installs remaining fonts
- Some new fonts fail (e.g., 5 casks)
- Generates: invalid_brew_fonts_list_20251125_160000.txt
  └─ Contains: 362 (previous) + 5 (new) = 367 casks total
```

### Third Run and Beyond
```
- Uses latest invalid list (367 casks)
- Continues to refine the list
- Each run gets faster and more reliable
```

## Uninstalling

### Uninstall the Cask Only
```bash
brew uninstall --cask homebrew-all-fonts
```
*Note: This does NOT remove the installed fonts*

### Uninstall All Font Casks
```bash
brew list --cask | grep '^font-' | xargs brew uninstall --cask
```

### Uninstall Specific Fonts
```bash
brew uninstall --cask font-name-here
```

## Reset and Retry

To reset and retry all casks (including previously failed ones):

```bash
# Remove or rename the invalid fonts list
rm invalid_brew_fonts_list_*.txt

# Or move to backup
mkdir old_invalid_lists
mv invalid_brew_fonts_list_*.txt old_invalid_lists/

# Reinstall (will start fresh)
brew reinstall --cask homebrew-all-fonts
```

## Technical Details

### Data Source
- **API URL**: `https://formulae.brew.sh/api/cask.json`
- **Filter**: `ruby_source_path` contains `"Casks/font/"`
- **Total Fonts**: ~2,500+ (and growing)

### What Gets Installed
- All available font casks from Homebrew
- Fonts are installed to `~/Library/Fonts/`
- A marker file is created at `~/Library/Application Support/homebrew-all-fonts/`

### Requirements
- macOS
- Homebrew 4.0+
- Internet connection
- Disk space (~5-10 GB recommended)
- Time (first run can take several hours)

### Invalid Fonts List Format
```
# invalid_brew_fonts_list_20251125_145859.txt
font-broken-upstream
font-disabled-cask
font-missing-source
...
```

- One cask per line
- Token format (e.g., `font-name-here`)
- Plain text
- Sorted alphabetically
- Timestamped filename

## Advantages

| Feature | This Cask | Static Brewfile |
|---------|-----------|-----------------|
| Always up-to-date | ✅ Yes | ❌ Manual updates |
| Auto-excludes failed casks | ✅ Yes | ❌ No |
| Cumulative learning | ✅ Yes | ❌ No |
| Single command install | ✅ Yes | ✅ Yes |
| Interactive method choice | ✅ Yes | ❌ No |
| Timestamped history | ✅ Yes | ❌ No |
| Both install methods | ✅ Yes | ⚠️ Limited |
| Automatic log parsing | ✅ Yes | ❌ Manual |

## Troubleshooting

### Installation Hangs
- Some fonts may have slow downloads
- Wait or cancel and use the Safe (Loop) method

### Some Fonts Fail
- This is normal (some fonts have broken upstream sources)
- Use the Safe method to see which fonts failed
- Failed fonts are automatically remembered for next time

### Check Currently Installed Fonts
```bash
brew list --cask | grep '^font-' | wc -l
```

### View Invalid Fonts List
```bash
cat invalid_brew_fonts_list_*.txt
```

### Compare Lists Over Time
```bash
diff invalid_brew_fonts_list_20251125_120000.txt \
     invalid_brew_fonts_list_20251125_130000.txt
```

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a history of changes to this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- Font cask definitions from [Homebrew Cask API](https://formulae.brew.sh/api/cask.json)
- All fonts provided by the [Homebrew community](https://github.com/Homebrew/homebrew-cask-fonts)
- Created for convenient bulk font management on macOS

## Support

If you encounter any issues or have suggestions:

1. Check the [Issues](https://github.com/Emasoft/homebrew_all_fonts/issues) page
2. Search for existing issues or create a new one
3. Provide detailed information about your environment and the problem

---

**Version**: 1.0.0  
**Platform**: macOS (Homebrew)  
**Status**: Active Development  

Made with ❤️ for the Homebrew community
