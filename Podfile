use_frameworks!

target "iVerbs French" do

    platform :ios, '9.0'

    # Realm
    pod 'RealmSwift'

    pod 'TKSubmitTransition', :path => '~/Desktop/Dev/apps/podforks/TKSubmitTransition'
    pod 'NightNight', :path => '~/Desktop/Dev/apps/podforks/NightNight'
    pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift'
    pod 'SwiftSpinner'


    # Alamofire HTTP lib
    pod 'Alamofire',
        :git => 'https://github.com/Alamofire/Alamofire.git',
        :branch => 'master'

    # Pod for Night Mode feature 
#    pod 'NightNight'


    pod 'LGSideMenuController', '~> 1.0.0'

    # AdMob
    source 'https://github.com/CocoaPods/Specs.git'

    pod 'Firebase/Core'
    pod 'Firebase/AdMob'


    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
                config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
                config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            end
        end
    end
end
