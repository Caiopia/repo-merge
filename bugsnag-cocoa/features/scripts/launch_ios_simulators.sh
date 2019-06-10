#!/usr/bin/env bash

INSTALL_PATH=build/Build/Products/Debug-iphonesimulator/iOSTestApp.app
XCODE_VERSION=$(xcodebuild -version)
OS_VERSION=${MAZE_SDK:="12.1"}

if [[ $XCODE_VERSION == "Xcode 10.1"* ]]; then
SIM_DEVICE="iPhone 8"
else
OS_VERSION=com.apple.CoreSimulator.SimRuntime.iOS-"${OS_VERSION//\./$'-'}"
SIM_DEVICE=com.apple.CoreSimulator.SimDeviceType.iPhone-8
fi

# Create required simulators
xcrun simctl create "maze-sim" "$SIM_DEVICE" "$OS_VERSION"

# Simulators used in the test suite:
xcrun simctl boot "maze-sim"; true

# Install the app on each simulator
xcrun simctl install "maze-sim" "$INSTALL_PATH"

# Preheat the simulators by triggering a crash
xcrun simctl launch "maze-sim" com.bugsnag.iOSTestApp \
    "EVENT_TYPE=preheat"
