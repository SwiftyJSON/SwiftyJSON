Pod::Spec.new do |s|
  s.name        = "SwiftyJSON"
  s.version     = "1.0.0"
  s.summary     = "SwiftyJSON makes it easy to deal with JSON data in Swift"
  s.homepage    = "https://github.com/SwiftyJSON/SwiftyJSON"
  s.license     = { :type => "MIT" }

  s.osx.deployment_target = "10.10"
  s.source   = { :git => "https://github.com/SwiftyJSON/SwiftyJSON" }
  s.source_files = "Source/SwiftyJSON.swift"
end
