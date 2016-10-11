//
//  Setting.swift
//  iVerbs
//
//  Created by Brad Reed on 01/08/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import RealmSwift

class Setting: Object {
    
    /*enum Value: Int {
        case On
        case Off
        // ...
    }*/

    static let Ads = "iad"
    
    dynamic var identifier: String = ""
    dynamic var label: String = ""
//    dynamic var on: Bool = false
    dynamic var value: Float = 0.0
    
    // Used as a shortcut for 'boolean' variables stored as a 0 or 1 float
    // This is a bit of a cheat as even if it's not a boolean setting it will return anyway
    var on: Bool {
        return value == 1.0
    }
    
    // Return the total number of available settings
    class var count: Int {
        return RealmManager.realm.objects(Setting.self).count
    }
    
    // Initializer for general setting
    convenience init(identifier: String, label: String, value: Float) {
        self.init()
        self.identifier = identifier
        self.label = label
        self.value = value
    }
    
    // Initiailizer for boolean setting
    convenience init(identifier: String, label: String, on: Bool) {
        let value: Float = on ? 1.0 : 0.0
        self.init(identifier: identifier, label: label, value: value)
    }
    
    // Another shortcut for boolean settings
    // If it's 0, make it 1 (true)
    // otherwise set to 0 (false) by default
    func flip() {
        let val: Float = value == 0.0 ? 1.0 : 0.0
        update(val: val)
    }
    
    // Set the value of the cell
    func update(val: Float) {
        print("Updating setting \(self.identifier) to \(val)")
        RealmManager.realmWrite { realm in
            self.value = val
        }
    }
    
    // Get a setting by its identifier
    class func by(identifier by: String) -> Setting? {
        return SettingManager.sharedInstance.get(by)
    }
    
    // Get all settings
    class func all() -> Results<Setting> {
        return RealmManager.realm.objects(Setting.self)
    }
    
    
}
