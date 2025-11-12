#!/bin/bash
set -e

# Configuration
SCHEME="Wero"
DESTINATION="platform=iOS Simulator,name=iPhone 17"
COVERAGE_THRESHOLD=80.0
RESULT_BUNDLE_PATH="build/result.xcresult"

echo "🧪 Running tests with code coverage..."

# Create build directory if it doesn't exist
mkdir -p build

# Remove old result bundle if it exists
rm -rf "$RESULT_BUNDLE_PATH"

# Run tests with result bundle for SonarQube
xcodebuild test \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -enableCodeCoverage YES \
  -resultBundlePath "$RESULT_BUNDLE_PATH" \
  -quiet

echo "📊 Analyzing coverage from: $RESULT_BUNDLE_PATH"

# Extract coverage percentage from JSON (lineCoverage is a decimal, multiply by 100)
COVERAGE=$(xcrun xccov view --report --json "$RESULT_BUNDLE_PATH" | \
  python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    coverage = data['lineCoverage'] * 100
    print(f'{coverage:.2f}')
except Exception as e:
    print('0.00', file=sys.stderr)
    sys.exit(1)
")

if [ -z "$COVERAGE" ] || [ "$COVERAGE" = "0.00" ]; then
  echo "⚠️  Warning: Could not extract coverage percentage"
  exit 0
fi

echo "📈 Code Coverage: ${COVERAGE}%"

# Check threshold
if (( $(echo "$COVERAGE < $COVERAGE_THRESHOLD" | bc -l) )); then
  echo "❌ Code coverage ${COVERAGE}% is below ${COVERAGE_THRESHOLD}% threshold"
  exit 1
fi

echo "✅ Code coverage meets ${COVERAGE_THRESHOLD}% threshold"
echo "✅ Result bundle saved to: $RESULT_BUNDLE_PATH (ready for SonarQube)"