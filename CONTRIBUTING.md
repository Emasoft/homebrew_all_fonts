# Contributing to Homebrew All Fonts

First off, thank you for considering contributing to Homebrew All Fonts! It's people like you that make this tool better for everyone.

## Code of Conduct

This project and everyone participating in it is governed by our commitment to providing a welcoming and inclusive experience for all contributors. Please be respectful and constructive in your interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** (commands you ran, expected vs actual output)
- **Describe the behavior you observed** and explain why it's a problem
- **Include your environment details**:
  - macOS version
  - Homebrew version (`brew --version`)
  - Ruby version (`ruby --version`)
  - Output of `brew config`

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a step-by-step description** of the suggested enhancement
- **Explain why this enhancement would be useful** to most users
- **List some examples** of how the feature would be used

### Pull Requests

- Fill in the required template
- Follow the Ruby style guide (run `rubocop` if available)
- Include thoughtful commit messages
- Update documentation as needed
- Add entries to CHANGELOG.md under [Unreleased]
- Ensure the cask still passes syntax validation (`ruby -c homebrew-all-fonts.rb`)

## Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/homebrew_all_fonts.git
   cd homebrew_all_fonts
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Edit the cask file: `homebrew-all-fonts.rb`
   - Update documentation as needed
   - Add tests if applicable

4. **Validate your changes**
   ```bash
   # Check Ruby syntax
   ruby -c homebrew-all-fonts.rb
   
   # Test the cask locally
   brew install --cask homebrew-all-fonts.rb
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: Add your feature description"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request**

## Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Examples:
- `feat: Add support for custom invalid list paths`
- `fix: Handle edge case in log parsing`
- `docs: Update installation instructions`

## Code Style

- Follow Ruby community conventions
- Use 2 spaces for indentation
- Keep lines under 120 characters where possible
- Add comments for complex logic
- Use meaningful variable names

## Testing

Before submitting:

1. Test the cask installation:
   ```bash
   brew install --cask homebrew-all-fonts.rb
   ```

2. Test with both methods (brew bundle and loop)

3. Test the invalid fonts list functionality:
   - With no existing list
   - With an existing list
   - Verify cumulative behavior

4. Test uninstall:
   ```bash
   brew uninstall --cask homebrew-all-fonts
   ```

## Areas for Contribution

We especially welcome contributions in these areas:

### High Priority
- Automated testing framework
- CI/CD pipeline improvements
- Performance optimizations
- Error handling enhancements

### Medium Priority
- Additional installation methods
- Progress bar implementation
- Custom filter support
- Documentation improvements

### Ideas Welcome
- Parallel installation with proper locking
- Notification system for completion
- Font category filtering
- Integration with other tools

## Documentation

When adding features, please update:
- README.md (if user-facing changes)
- CHANGELOG.md (under [Unreleased])
- CASK_INSTALLATION.md (if installation process changes)
- IMPROVEMENTS.md (if adding smart features)
- Code comments (for complex logic)

## Questions?

Feel free to open an issue with the `question` label if you have questions about:
- How the cask works
- How to implement a feature
- Development setup
- Contributing process

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in:
- GitHub contributors page
- Release notes
- README credits section (for significant contributions)

Thank you for contributing! 🎉
