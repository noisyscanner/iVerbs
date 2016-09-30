//
//  SettingCellDelegate.swift
//  iVerbs
//
//  Created by Brad Reed on 01/08/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import UIKit
import RealmSwift

/*protocol SettingCellDelegate {
    
    var tableView: UITableView! { get set }
    
    func tableView(tableView: UITableView, settingSwitchedAtIndexPath: NSIndexPath, on: Bool)
    
}*/

protocol SettingsDelegate: UITableViewDelegate, UITableViewDataSource {
    
//    var settings: [Setting] { get set }
    
    var tableView: UITableView! { get set }
    func tableView(_ tableView: UITableView, settingForRowAtIndexPath indexPath: IndexPath) -> Setting?
    func tableView(_ tableView: UITableView, settingSwitchedAtIndexPath indexPath: IndexPath, on: Bool)
//    func settingSwitched(setting: Setting, on: Bool)
    
}

extension SettingsDelegate {
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return SettingManager.sharedInstance.groupCount
    }
}
