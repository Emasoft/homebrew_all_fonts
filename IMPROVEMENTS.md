# Homebrew All Fonts - Smart Invalid Fonts Management

## Key Improvement: Automatic Invalid Fonts List Evolution

The cask now intelligently manages a cumulative invalid fonts list across multiple runs.

### How It Works

1. **First Run (No existing list)**:
   ```
   - Downloads all fonts from Homebrew API
   - Filters for font casks only
   - No exclusions applied
   - Installs fonts
   - Generates: invalid_brew_fonts_list_20251125_150000.txt (with newly failed fonts)
   ```

2. **Second Run (With existing list)**:
   ```
   - Downloads all fonts from Homebrew API
   - Filters for font casks only
   - Loads most recent invalid list (362 fonts)
   - Excludes those 362 fonts from installation
   - Installs remaining fonts
   - Some new fonts fail (e.g., 5 fonts)
   - Generates: invalid_brew_fonts_list_20251125_160000.txt
     └─ Contains: 362 (previous) + 5 (new) = 367 fonts total
   ```

3. **Third Run**:
   ```
   - Uses invalid_brew_fonts_list_20251125_160000.txt (367 fonts)
   - Excludes all 367 fonts
   - Installs remaining fonts
   - Even more fonts might fail (upstream issues)
   - Generates updated list with cumulative failures
   ```

### Features

✅ **Automatic Detection** - Finds most recent `invalid_brew_fonts_list_*.txt` file
✅ **Cumulative Learning** - Each run adds newly failed fonts to the list
✅ **Zero Configuration** - Works automatically, no user input needed
✅ **Timestamped History** - All lists are preserved with timestamps
✅ **Both Methods Supported** - Works with Brew Bundle AND Loop methods
✅ **No Duplicates** - Automatically deduplicates font names
✅ **Sorted Output** - Alphabetically sorted for easy comparison

### Invalid Fonts List Format

```
# invalid_brew_fonts_list_20251125_145859.txt
font-broken-upstream
font-disabled-cask
font-missing-source
...
```

- One font per line
- Token format (e.g., `font-name-here`)
- Plain text
- No comments or metadata
- Sorted alphabetically

### Log Parsing

#### Brew Bundle Method
Parses brew bundle output for:
- `Error: Cask 'font-name' ...`
- `Cask 'font-name' has been disabled`
- Any error mentioning a font-* cask

#### Loop Method
Directly tracks installation status:
- Checks exit status
- Looks for "successfully" / "already installed" / "latest version"
- Marks as failed if none of above found

### Output Example

```
============================================================
Invalid Fonts List Updated
============================================================
Previous invalid fonts: 362
Newly failed fonts:     5
Total invalid fonts:    367
Saved to: invalid_brew_fonts_list_20251125_160000.txt
============================================================

Newly failed fonts this run:
  - font-newly-broken-1
  - font-newly-broken-2
  - font-newly-broken-3
  - font-newly-broken-4
  - font-newly-broken-5
```

### Benefits

1. **Progressive Refinement**: Each run makes the next run faster and more reliable
2. **No Manual Intervention**: Completely automatic
3. **Audit Trail**: Timestamped files show history of failures
4. **Shareable**: Can commit the invalid list to git for team use
5. **Upstream Recovery**: If a previously failed font is fixed upstream, just delete the invalid list and it will be retried

### Manual Override

You can also manually create/edit the invalid fonts list:

```bash
# Create from scratch
echo "font-problematic-1" > invalid_brew_fonts_list_$(date +%Y%m%d_%H%M%S).txt
echo "font-problematic-2" >> invalid_brew_fonts_list_$(date +%Y%m%d_%H%M%S).txt

# Or edit existing
vim $(ls -t invalid_brew_fonts_list_*.txt | head -1)
```

The cask will automatically use the most recent file.

### Workflow Example

```bash
# First installation
brew install --cask homebrew-all-fonts.rb
# Choose method 2 (Loop)
# Installs 2,197 fonts, 362 fail
# Creates: invalid_brew_fonts_list_20251125_120000.txt

# Later: New fonts added to Homebrew
brew reinstall --cask homebrew-all-fonts.rb
# Automatically loads invalid_brew_fonts_list_20251125_120000.txt
# Skips those 362 fonts
# Installs new fonts + remaining old fonts
# Updates list if any new failures occur
```

### Comparison with Static Brewfile

| Feature | Dynamic Cask | Static Brewfile |
|---------|--------------|-----------------|
| Auto-updates invalid list | ✅ Yes | ❌ No |
| Cumulative learning | ✅ Yes | ❌ No |
| Works across runs | ✅ Yes | ⚠️ Manual |
| Timestamps | ✅ Yes | ❌ No |
| Both install methods | ✅ Yes | ⚠️ Limited |
| Log parsing | ✅ Automatic | ❌ Manual |

### Advanced Usage

#### Compare Invalid Lists Over Time
```bash
# See what changed between runs
diff invalid_brew_fonts_list_20251125_120000.txt \
     invalid_brew_fonts_list_20251125_130000.txt
```

#### Merge Multiple Lists
```bash
# Combine lists from different machines
cat invalid_brew_fonts_list_*.txt | sort -u > merged_list.txt
mv merged_list.txt invalid_brew_fonts_list_$(date +%Y%m%d_%H%M%S).txt
```

#### Reset and Retry All Fonts
```bash
# Temporarily rename invalid lists
mkdir old_invalid_lists
mv invalid_brew_fonts_list_*.txt old_invalid_lists/

# Run cask (will start fresh)
brew reinstall --cask homebrew-all-fonts.rb

# If needed, restore old list
mv old_invalid_lists/invalid_brew_fonts_list_*.txt .
```

---

**Version**: 2.0.0
**Date**: November 25, 2025
**Feature**: Smart Invalid Fonts Management
