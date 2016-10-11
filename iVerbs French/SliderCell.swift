//
//  SliderCell.swift
//  iVerbs
//
//  Created by Brad Reed on 08/10/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import UIKit
import NightNight

class SliderCell: iVerbsTintedCell, SettingCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var setting: Setting? {
        didSet {
            self.label.text = setting?.label
            self.slider.value = setting?.value ?? 0
        }
    }
    
    override func awakeFromNib() {
        label.mixedTextColor = MixedColor(normal: UIColor.darkText, night: UIColor.white)
        slider.mixedMinimumTrackTintColor = MixedColor(normal: iVerbs.colour, night: iVerbs.Colour.darkBlue)
    }
    
}
