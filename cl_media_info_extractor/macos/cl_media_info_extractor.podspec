#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cl_media_info_extractor.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cl_media_info_extractor'
  s.version          = '0.0.1'
  s.summary          = 'Media Info Extractor for Flutter'
  s.description      = <<-DESC
Media Info Extractor for Flutter.
Uses exiftool to extract metadata from media files on macos.
It also has a generic interface to execute apps on macos, which can be used
to execute any app on macos.
has a wrapper around the exiftool command line tool to extract basic information
from media files.
                       DESC
  s.homepage         = 'http://www.cloudonlanapps.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Cloud on LAN Apps' => 'asarangaram@gmail.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'cl_media_info_extractor_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
