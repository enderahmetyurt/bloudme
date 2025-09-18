# Contributing to Bloudme

Thank you for your interest in contributing to Bloudme! We welcome contributions from everyone, whether you're a beginner or an experienced developer.

## 🚀 Getting Started

1. **Fork the repository** and clone it locally
2. **Set up your development environment** following the [README.md](README.md) instructions
3. **Create a new branch** for your feature or bug fix:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b bugfix/issue-description
   ```

## 🔧 Development Process

### Before You Start
- Check the [Issues](https://github.com/enderahmetyurt/bloudme/issues) to see if someone is already working on it
- For large changes, please open an issue first to discuss your approach
- Make sure you have the latest code from the main branch

### Making Changes
1. **Write tests** for new functionality
2. **Follow the existing code style** and conventions
3. **Keep commits focused** - one feature/fix per commit
4. **Write clear commit messages**

### Code Style
- Follow Ruby community standards
- Use the provided Rubocop configuration: `bundle exec rubocop`
- Run security checks: `bundle exec brakeman`
- Ensure all tests pass: `rails test`

### Testing
- Write tests for all new features
- Update existing tests when modifying functionality
- Run the full test suite before submitting:
  ```bash
  rails test
  rails test:system
  ```

## 📝 Pull Request Process

1. **Update documentation** if you've changed functionality
2. **Add tests** that cover your changes
3. **Run the linter and tests** locally
4. **Create a Pull Request** with:
   - Clear title describing the change
   - Description explaining what and why
   - Reference to any related issues
   - Screenshots (if UI changes)

### PR Title Format
- `feat: add new RSS feed parser`
- `fix: resolve bookmark deletion issue`
- `docs: update installation instructions`
- `refactor: improve feed update performance`

## 🐛 Bug Reports

When reporting bugs, please include:
- **Clear description** of the issue
- **Steps to reproduce** the problem
- **Expected vs actual behavior**
- **Environment details** (OS, Ruby version, etc.)
- **Error messages** or logs (if any)

Use our [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) if available.

## 💡 Feature Requests

For feature requests:
- **Describe the problem** you're trying to solve
- **Explain your proposed solution**
- **Consider alternatives** you've thought about
- **Provide use cases** and examples

## 🏷️ Issue Labels

We use these labels to organize issues:
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention is needed
- `documentation` - Improvements to docs

## 📋 Development Guidelines

### Ruby/Rails Specific
- Follow Rails conventions and best practices
- Use strong parameters for all form inputs
- Implement proper error handling
- Write descriptive variable and method names

### Database Changes
- Create migrations for schema changes
- Test migrations both up and down
- Consider data migration implications
- Update seeds if necessary

### Frontend Changes
- Use Stimulus controllers for JavaScript
- Follow Tailwind CSS patterns
- Ensure responsive design
- Test across different browsers

### Background Jobs
- Use Solid Queue for asynchronous processing
- Implement proper error handling
- Consider job retry logic
- Add monitoring where appropriate

## 🔒 Security

- Never commit sensitive data (keys, passwords, etc.)
- Use Rails credentials for secrets
- Follow secure coding practices
- Report security vulnerabilities privately (see [SECURITY.md](SECURITY.md))

## 📄 License

By contributing to Bloudme, you agree that your contributions will be licensed under the MIT License.

## 🤝 Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md) to ensure a welcoming environment for all contributors.

## ❓ Questions?

- Check the [documentation](README.md)
- Look through [existing issues](https://github.com/enderahmetyurt/bloudme/issues)
- Ask in a new issue with the `question` label

Thank you for contributing to Bloudme! 🎉