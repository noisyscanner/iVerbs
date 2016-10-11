//
//  SettingsDelegate.swift
//  iVerbs
//
//  Created by Brad Reed on 05/10/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import UIKit
import RealmSwift
import NightNight

protocol SettingsDelegate: UITableViewDelegate, UITableViewDataSource {
    
    var manager: SettingManager { get }
    
    func tableView(_ tableView: UITableView, settingForRowAtIndexPath indexPath: IndexPath) -> Setting?
    func tableView(_ tableView: UITableView, settingSwitchedAtIndexPath indexPath: IndexPath, value: Float)
}

extension SettingsDelegate {
    
    // Returns a Setting for the given indexPath
    func tableView(_ tableView: UITableView, settingForRowAtIndexPath indexPath: IndexPath) -> Setting? {
        return manager.settings[indexPath.row]
    }
    
    // Delegate method called when a setting is changed at the given indexPath
    func tableView(_ tableView: UITableView, settingSwitchedAtIndexPath indexPath: IndexPath, value: Float) {
        if let setting = self.tableView(tableView, settingForRowAtIndexPath: indexPath) {
            
            if setting.identifier == "night" {
                // Update UI for night mode
                NightNight.theme = !setting.on ? .night : .normal
            }
            
            setting.update(val: value)
            
        }
        
    }
    
    
    
}
