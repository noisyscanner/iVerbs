source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
platform :ios, '9.0'

def pods

    # Realm
    pod 'RealmSwift'

    pod 'TKSubmitTransition', :path => './TKSubmitTransition'
    pod 'NightNight', :path => './NightNight'
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


target "iVerbs French" do
    pods
end

target "iVerbs FrenchTests" do
    pods
end
