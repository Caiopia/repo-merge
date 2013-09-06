Pod::Spec.new do |s|
  s.name         = "Bugsnag"
  s.version      = "3.0.0"
  s.summary      = "iOS notifier for SDK for bugsnag.com"
  s.homepage     = "https://bugsnag.com"
  s.license      = 'MIT'
  s.author       = { "Bugsnag" => "notifiers@bugsnag.com" }
  s.source       = { :git => "https://github.com/bugsnag/bugsnag-objective-c.git", :tag => "3.0.0" }
  s.platform     = :ios, '4.0'
  s.source_files = ['bugsnag/*.{h,m}']
  s.requires_arc = true

  s.ios.source_files = "bugsnag/iOS/*.{h,m}"

  s.post_install do |lib|
    puts lib.target.inspect
  end
end
