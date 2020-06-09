# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'XploreProject' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for XploreProject

pod 'FacebookCore'
pod 'FacebookLogin'
pod 'Alamofire'
pod 'SDWebImage'
pod 'FirebaseDatabase'
pod 'GoogleMaps'
pod 'GooglePlaces'
pod 'FTIndicator'
pod 'SplunkMint'
pod 'SwiftyJSON'
pod 'MBProgressHUD'
pod 'FirebaseStorage'
pod 'GoogleSignIn'
pod 'Cosmos', '~> 11.0'
pod 'IQKeyboardManagerSwift'

pod 'MessageKit'
pod 'Firebase/Messaging'
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Storage'
pod 'Firebase/Firestore'

pod 'SimpleImageViewer'
pod 'SwiftKeychainWrapper'

pod 'Google-Mobile-Ads-SDK'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'MessageKit'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end

platform :ios, '9.0'
pod 'PayPal-iOS-SDK'

pod 'OpalImagePicker'

end
