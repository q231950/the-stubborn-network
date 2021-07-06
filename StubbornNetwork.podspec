Pod::Spec.new do |spec|
    spec.name         = "StubbornNetwork"
    spec.version      = "0.1.3"
    spec.summary      = "A Swifty and clean stubbing machine."
    spec.description  = <<-DESC
    The Stubborn Network makes your SwiftUI development more efficient and UI tests more reliable by stubbing responses of your network requests.
    
    It makes it easy to record new stubs and it speeds things up!
    DESC
    spec.homepage     = "https://github.com/q231950/the-stubborn-network"
    spec.license      = { :type => "MIT", :file => "LICENSE" }
    spec.author             = { "author" => "martinkim.pham@gmail.com" }
    spec.documentation_url = "https://github.com/q231950/the-stubborn-network#-stubbed-ui-tests"
    spec.platforms = { :ios => "13.0", :osx => "10.15", :watchos => "6.0" }
    spec.swift_version = "5.2"
    spec.source       = { :git => "https://github.com/q231950/the-stubborn-network.git", :tag => "#{spec.version}" }
    spec.source_files  = "Sources/StubbornNetwork/**/*.swift"
    end
