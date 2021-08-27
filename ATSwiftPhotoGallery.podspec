#
# Be sure to run `pod lib lint ATSwiftPhotoGallery.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'ATSwiftPhotoGallery'
  spec.version          = '0.1.0'
  spec.summary          = 'Pure Swift library for selecting multiple photos.'
  spec.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  spec.description      = <<-DESC
  Pure Swift library for selecting multiple photos from photo gallery.
                       DESC

  spec.homepage         = 'https://github.com/ankitthakur/ATSwiftPhotoGallery'
  # spec.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { 'Ankit Thakur' => 'ankitthakur85@icloud.com' }
  spec.source           = { :git => 'https://github.com/ankitthakur/ATSwiftPhotoGallery.git', :tag => spec.version.to_s }
  # spec.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  spec.requires_arc = true
  spec.swift_version  = '5.0'
  spec.ios.deployment_target  = '12.4'

  spec.source_files       = "Sources/**/*.{swift}"

  spec.resource_bundles = {
    'ATSwiftPhotoGallery' => ["Sources/**/*.{storyboard}"]
  }

  # spec.public_header_files = 'Pod/Classes/**/*.h'
  spec.frameworks = 'Photos'
#  spec.dependency 'Kingfisher'
end
