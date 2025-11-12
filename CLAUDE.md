# Project Context

Please always reference and follow the guidelines in CONVENTIONS.md for this project.

## Testing and Quality Workflow

**IMPORTANT**: Do NOT run tests, formatting, linting, or SonarQube commands directly.

All testing and quality checks are handled automatically by hooks:
- After editing code: SwiftFormat and SwiftLint run automatically
- After writing/creating files: Tests with coverage and SonarQube analysis run automatically

The hooks system will execute:
1. `bash scripts/test-with-coverage.sh` - Runs full test suite with 80% coverage requirement
2. `bash scripts/run-sonar.sh` - Runs SonarQube analysis

You do not need to verify tests pass - the hooks will fail if tests or quality checks don't pass.