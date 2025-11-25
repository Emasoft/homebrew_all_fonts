# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-25

### Added
- Initial release of Homebrew All Fonts cask
- Dynamic font list fetching from Homebrew API (`https://formulae.brew.sh/api/cask.json`)
- Smart filtering for font casks only (using `ruby_source_path` contains `"Casks/font/"`)
- Intelligent invalid cask tracking with timestamped lists
- Cumulative learning system that remembers failed installations across runs
- Two installation methods:
  - Brew Bundle Method (fast, stops on first error)
  - Loop Method (safe, continues on errors)
- Automatic log parsing to detect newly failed casks
- Real-time progress tracking during installation
- Interactive method selection at runtime
- Option to save Brewfile and exit for later installation
- Comprehensive installation summary with success/failure counts
- Automatic detection of most recent invalid fonts list
- Support for ~2,500+ font casks from Homebrew
- Marker file creation for tracking installation state
- Proper uninstall preflight warnings
- Detailed caveats with usage instructions
- Zero-configuration automatic operation

### Features
- Dynamic cask list always reflects latest Homebrew fonts
- Smart exclusion of disabled/broken upstream casks
- Timestamped history of invalid casks for audit trail
- No manual intervention required for cask management
- Progressive refinement with each installation run
- Shareable invalid cask lists for team environments
- Automatic upstream recovery detection (retry previously failed casks by deleting list)

### Technical
- Ruby DSL cask implementation
- Preflight hook for all installation logic
- Postflight hook for marker file creation
- Uninstall preflight for user warnings
- JSON parsing from Homebrew API
- Regex-based log parsing for both installation methods
- Temporary Brewfile generation
- File I/O for invalid list management
- Open3 for command execution and output capture

### Documentation
- Comprehensive README with features, installation, and usage
- Technical details and requirements
- Troubleshooting guide
- Uninstallation instructions
- Reset and retry procedures
- Examples and comparisons
- MIT License
- Contributing guidelines
- This changelog

## [Unreleased]

### Planned
- GitHub Actions workflow for automated linting
- GitHub Actions workflow for Homebrew publishing
- Automated testing suite
- Support for custom invalid list paths
- Option to specify font categories or filters
- Parallel installation with git lock handling
- Progress bar for visual feedback
- Email/notification support for completion
- Docker container for testing
- Homebrew tap creation

---

[1.0.0]: https://github.com/Emasoft/homebrew_all_fonts/releases/tag/v1.0.0
