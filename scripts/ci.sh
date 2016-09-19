#!/usr/bin/env bash

set -e

xcodebuild -workspace SwiftyJSON.xcworkspace -scheme "SwiftyJSON iOS" -destination "platform=iOS Simulator,name=iPhone 6s" test

xcodebuild -workspace SwiftyJSON.xcworkspace -scheme "SwiftyJSON OSX" test

xcodebuild -workspace SwiftyJSON.xcworkspace -scheme "SwiftyJSON tvOS" -destination "platform=tvOS Simulator,name=Apple TV 1080p" test
