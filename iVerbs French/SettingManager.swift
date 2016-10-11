//
//  SettingManager.swift
//  iVerbs
//
//  Created by Brad Reed on 02/08/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import Foundation

class SettingManager {
    
    var settings = Setting.all()
    
    fileprivate static var _instance: SettingManager?
    
    class var sharedInstance: SettingManager {
        if _instance == nil {
            _instance = SettingManager()
        }
        return _instance!
    }
    
    init() {
        if settings.count == 0 {
            self.setup()
        }
    }
    
    fileprivate func setup() {
        // create default settings in db
        
        let iads = Setting(identifier: "night", label: "Night Mode", on: false)
        let rate = Setting(identifier: "speechrate", label: "Speech Rate", value: 0.5)
        
        RealmManager.realmWrite { realm in
            realm.add(iads)
            realm.add(rate)
        }
    }
    
    func get(_ identifier: String) -> Setting? {
        return RealmManager.realm.objects (Setting.self).filter("identifier = '\(identifier)'").first
    }
    
    
    
}
