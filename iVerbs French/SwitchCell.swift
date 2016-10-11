//
//  SettingCell.swift
//  iVerbs
//
//  Created by Brad Reed on 01/08/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import UIKit
import NightNight

class SwitchCell: iVerbsTintedCell, SettingCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var onoff: UISwitch!
    
    var setting: Setting? {
        didSet {
            self.label.text = setting?.label
            self.onoff.isOn = setting?.on ?? false
            print("Initial switch: ", setting?.on)
        }
    }
    
    override func awakeFromNib() {
        label.mixedTextColor = MixedColor(normal: UIColor.darkText, night: UIColor.white)
    }
}