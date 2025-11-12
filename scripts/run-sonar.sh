#!/bin/bash

##########################################################
# Sonar Scanner Wrapper Script
# Silent on success, shows output only on errors
##########################################################

set -e  # Exit on error

# Check if sonar-scanner is installed
if ! command -v sonar-scanner &> /dev/null; then
    echo "❌ Error: sonar-scanner not found"
    echo "Install it with: brew install sonar-scanner"
    exit 1
fi

# Check if sonar-project.properties exists
if [ ! -f "sonar-project.properties" ]; then
    echo "❌ Error: sonar-project.properties not found"
    echo "Create it in your project root"
    exit 1
fi

# Run sonar-scanner silently, capture output only for errors
OUTPUT=$(sonar-scanner -Dsonar.verbose=false -Dsonar.log.level=ERROR 2>&1)
EXIT_CODE=$?

# Only print output if there was an error
if [ $EXIT_CODE -ne 0 ]; then
    echo "$OUTPUT"
    echo ""
    echo "❌ Sonar analysis failed"
    exit 1
fi

# Success = silent (no output)
exit 0