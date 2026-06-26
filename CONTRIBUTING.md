# Contributing to android-kernel-build

Thank you for your interest in contributing! This document outlines the process and standards for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Standards](#code-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- Linux kernel build environment, clang/llvm, make, gcc, python3, shellcheck, ccache

### Setup

```bash
# Clone the repository
git clone https://github.com/JWEB0689/android-kernel-build.git
cd android-kernel-build

# Install dependencies
sudo apt-get install -y bc bison flex libssl-dev make libc6-dev libncurses5-dev libelf-dev dwarves python3 python3-pip ccache git wget curl zip unzip clang-17 lld-17 llvm-17

# Run tests to verify setup
shellcheck build.sh scripts/*.sh patch_manager/*.py {{TEST_CMD}}{{TEST_CMD}} python3 -m py_compile scripts/*.py patch_manager/*.py
```

## Development Workflow

1. **Fork** the repository
2. **Create a branch** from `main`/`master`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following the code standards below
4. **Run tests and linting** locally:
   ```bash
   shellcheck build.sh scripts/*.sh patch_manager/*.py && python3 -m py_compile scripts/*.py patch_manager/*.py
   shellcheck build.sh scripts/*.sh patch_manager/*.py {{TEST_CMD}}{{TEST_CMD}} python3 -m py_compile scripts/*.py patch_manager/*.py
   ```
5. **Commit** with conventional commits:
   ```bash
   git commit -m "feat(scope): description of change"
   ```
6. **Push** to your fork and **open a Pull Request**

## Code Standards

### Conventional Commits

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding missing tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

### Language-Specific Standards

### Shell Scripts
- shellcheck clean
- Use functions, avoid global variables
- Quote all variables
- Set -euo pipefail

### Python
- Use type hints
- Run ruff for linting
- Follow PEP 8

### Kernel Build
- All patches apply cleanly
- Build with ccache + clang
- ccache statistics reported

### Formatting

- Run the formatter before committing: `shellcheck build.sh scripts/*.sh patch_manager/*.py`
- CI will fail if code is not properly formatted

### Linting

- Run linter before committing: `shellcheck build.sh scripts/*.sh patch_manager/*.py && python3 -m py_compile scripts/*.py patch_manager/*.py`
- No new lint warnings allowed

## Testing

### Running Tests

```bash
shellcheck build.sh scripts/*.sh patch_manager/*.py {{TEST_CMD}}{{TEST_CMD}} python3 -m py_compile scripts/*.py patch_manager/*.py
```

### Test Requirements

- All new features must include tests
- Bug fixes must include a regression test
- Aim for >80% code coverage
- Tests must pass on all supported platforms

### Test Organization

- Unit tests: `tests/unit/` or `*_test.*` alongside source
- Integration tests: `tests/integration/`
- E2E tests: `tests/e2e/`

## Documentation

### Required Documentation Updates

- **README.md**: Update if user-facing behavior changes
- **CHANGELOG.md**: Add entry under "Unreleased" section
- **API docs**: Update docstrings/comments for public APIs
- **Architecture docs**: Update if structural changes

### Documentation Style

- Clear, concise, and example-driven
- Keep it up to date with code changes
- Use markdown for all documentation

## Pull Request Process

### Before Submitting

- [ ] Tests pass locally (`shellcheck build.sh scripts/*.sh patch_manager/*.py {{TEST_CMD}}{{TEST_CMD}} python3 -m py_compile scripts/*.py patch_manager/*.py`)
- [ ] Linting passes (`shellcheck build.sh scripts/*.sh patch_manager/*.py && python3 -m py_compile scripts/*.py patch_manager/*.py`)
- [ ] Formatting correct (`shellcheck build.sh scripts/*.sh patch_manager/*.py`)
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (under "Unreleased")
- [ ] Conventional commit messages

### PR Requirements

- **Title**: Follows conventional commits (e.g., `feat: add new feature`)
- **Description**: Explains *what* and *why*, not *how*
- **Linked Issues**: Reference related issues (`Fixes #123`)
- **Screenshots**: For UI changes
- **Breaking Changes**: Clearly marked in description

### Review Process

1. Automated CI must pass
2. At least 1 maintainer approval required
3. No unresolved review comments
4. Branch must be up to date with base branch

### Merge Strategy

- **Squash and merge** for feature branches
- **Rebase and merge** for small fixes
- **Merge commit** for major releases

## Release Process

Releases are automated via GitHub Actions:

1. Tag a release: `git tag v1.2.3 && git push origin v1.2.3`
2. CI builds artifacts for all platforms
3. GitHub Release created with artifacts
4. CHANGELOG.md updated automatically
5. Package published to registry (if configured)

### Versioning

Follows [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## Getting Help

- Open a [Discussion](../../discussions) for questions
- Check existing [Issues](../../issues) before creating new ones
- For security issues, see [SECURITY.md](SECURITY.md)

---

*Template based on rtk/odysseus contributing guidelines*