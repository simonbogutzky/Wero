#!/bin/bash

##########################################################
# Local CI Pipeline für Wero
# Führt alle Quality Gates lokal aus
##########################################################

set -e  # Exit on error

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funktion für Schritt-Output
print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Start
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Wero CI Pipeline${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. Git Status Check
print_step "Checking Git status..."
if [[ -n $(git status -s) ]]; then
    print_warning "Uncommitted changes detected"
    git status -s
    echo ""
fi
print_success "Git check complete"
echo ""

# 2. SwiftFormat
print_step "Running SwiftFormat..."
if swiftformat . --quiet; then
    print_success "Code formatting complete"
else
    print_error "SwiftFormat failed"
    exit 1
fi
echo ""

# 3. SwiftLint
print_step "Running SwiftLint..."
if swiftlint lint --fix --quiet; then
    print_success "Linting complete"
else
    print_error "SwiftLint failed"
    exit 1
fi
echo ""

# 4. Tests mit Coverage
print_step "Running tests with coverage..."
if bash scripts/test-with-coverage.sh; then
    print_success "Tests passed with sufficient coverage"
else
    print_error "Tests or coverage check failed"
    exit 1
fi
echo ""

# 5. SonarQube Analysis
print_step "Running SonarQube analysis..."
if bash scripts/run-sonar.sh; then
    print_success "SonarQube analysis complete"
else
    print_error "SonarQube analysis failed"
    exit 1
fi
echo ""

# Abschluss
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ CI Pipeline successful!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
