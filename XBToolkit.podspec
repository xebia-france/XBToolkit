Pod::Spec.new do |s|
  s.name         = "XBToolkit"
  s.version      = "2.0"
  s.summary      = "Xebia mapping and serializing tools for iOS & OSX."
  s.homepage     = "https://github.com/xebia-france/XBToolkit"
  s.author       = { 'Alexis Kinsella' => 'alexis.kinsella@gmail.com' }

  s.license      = 'Apache License, Version 2.0'
  s.source       = { :git => "https://github.com/xebia-france/XBToolkit.git", :branch => s.version.to_s }

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.7'

  s.source_files = 'XBToolkit-common/**/*.{h,m}'
  s.ios.source_files = 'XBToolkit-ios/XBToolkit-ios/**/*.{h,m}'
  s.osx.source_files = 'XBToolkit-osx/XBToolkit-osx/**/*.{h,m}'

  s.requires_arc = true

  s.dependency 'Underscore.m',      '~> 0.2.1'
  s.dependency 'AFNetworking',      '~> 2.0.3'
  s.dependency 'Mantle',            '~> 1.3.1'

end
