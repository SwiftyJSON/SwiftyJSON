#!/usr/bin/env bash

set -e

travis_retry xcodebuild -workspace SwiftyJSON.xcworkspace -scheme "SwiftyJSON iOS" -destination "platform=iOS Simulator,name=iPhone 6" build-for-testing test | xcpretty

travis_retry xcodebuild -workspace SwiftyJSON.xcworkspace -scheme "SwiftyJSON OSX" build-for-testing test | xcpretty

travis_retry xcodebuild -workspace SwiftyJSON.xcworkspace -scheme "SwiftyJSON tvOS" -destination "platform=tvOS Simulator,name=Apple TV 1080p" build-for-testing test | xcpretty
