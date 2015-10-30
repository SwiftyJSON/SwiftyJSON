#!/usr/bin/env bash

set -e
xcodebuild -workspace SwiftyJSON.xcworkspace -scheme "SwiftyJSON iOS" -destination "platform=iOS Simulator,name=iPhone 6" test
xcodebuild -workspace SwiftyJSON.xcworkspace -scheme "SwiftyJSON OSX" test

# Not running tvOS since Travis CI doesn't yet support it.
# xcodebuild -workspace SwiftyJSON.xcworkspace -scheme "SwiftyJSON tvOS" -destination "platform=tvOS Simulator,name=Apple TV 1080p" test