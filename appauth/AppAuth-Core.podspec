Pod::Spec.new do |s|

  s.name         = "AppAuth-Core"
  s.version      = "0.4.0"
  s.summary      = "AppAuth-Core is a client for iOS and macOS SDK for communicating with OAuth 2.0 and OpenID Connect providers."

  s.description  = <<-DESC

AppAuth-Core for iOS and macOS a client SDK for communicating with
[OAuth 2.0](https://tools.ietf.org/html/rfc6749) and [OpenID Connect]
(http://openid.net/specs/openid-connect-core-1_0.html) providers. It strives to
directly map the requests and responses of those specifications, while following
the idiomatic style of the implementation language. In addition to mapping the
raw protocol flows, convenience methods are available to assist with common
tasks like performing an action with fresh tokens.

                   DESC

  s.homepage     = "https://openid.github.io/AppAuth-iOS"
  s.license      = "Apache License, Version 2.0"
  s.authors      = { "William Denniss" => "wdenniss@google.com",
                     "Steven E Wright" => "stevewright@google.com",
                   }

  s.source       = { :git => "https://github.com/openid/AppAuth-iOS.git", :tag => s.version }

  s.source_files = "Source/**/*.{h,m}"
  s.exclude_files = "Source/**/*IOS.{h,m}", "Source/AppAuth.h"
  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"
  s.requires_arc = true

end

