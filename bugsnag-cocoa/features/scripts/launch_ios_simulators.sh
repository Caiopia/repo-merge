#!/usr/bin/env bash

osascript -e 'launch application "Simulator"'

# Simulators used in the test suite:
xcrun simctl boot "iPhone 8"
# If appending to this list, add to uninstall_ios_app.sh as well
