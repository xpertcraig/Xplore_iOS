# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'XploreProject' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for XploreProject

pod 'FacebookCore'
pod 'FacebookLogin'
pod 'SplunkMint'
pod 'FirebaseDatabase'
pod 'FirebaseStorage'
pod 'Firebase/Messaging'
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Storage'
pod 'Firebase/Firestore'
pod 'GoogleSignIn'
pod 'GoogleMaps'
pod 'GooglePlaces'
pod 'SwiftyJSON'
#pod 'Google-Mobile-Ads-SDK'

pod 'Alamofire'
pod 'SDWebImage'
pod 'FTIndicator'

pod 'MBProgressHUD'
pod 'Cosmos', '~> 11.0'
pod 'IQKeyboardManagerSwift'
pod 'MessageKit'
pod 'SimpleImageViewer'
pod 'SwiftKeychainWrapper'

pod 'PayPal-iOS-SDK'

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


pod 'OpalImagePicker'
pod 'Bolts'

end
