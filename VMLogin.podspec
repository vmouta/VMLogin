Pod::Spec.new do |s|
    s.name             = "VMLogin"
    s.version          = "0.0.1"
    s.summary          = "A simple login."
    s.description      = <<-DESC
                        A OAuth Login
                       DESC

    s.homepage         = "https://github.com/vmouta/VMLogin"
    s.license          = { :type => "MIT", :file => "LICENSE" }
    s.author           = { "Vasco Mouta" => "vasco.mouta@gmail.com" }
    s.source           = { :git => "https://github.com/vmouta/VMLogin.git", :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/vmouta'

    s.platform     = :ios, '10.0'
    s.requires_arc = true

    s.source_files = 'Pod/Classes/**/*'
    s.frameworks = "UIKit", "Foundation", "FirebaseAuth"
    s.dependency 'FirebaseAuth'

end
