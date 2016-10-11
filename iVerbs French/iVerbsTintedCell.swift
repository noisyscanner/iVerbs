//
//  VerbListCell.swift
//  iVerbs
//
//  Created by Brad Reed on 04/01/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import UIKit
import NightNight

// Custom table cell with iVerbs colour scheme
class iVerbsTintedCell: UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        mixedBackgroundColor = MixedColor(normal: UIColor.white, night: iVerbs.Colour.dark)
        
        textLabel?.mixedTextColor = MixedColor(normal: UIColor.darkText, night: UIColor.white)
        
        // Set custom background view on tap, with iVerbs colour
        let sbv = UIView()
        sbv.mixedBackgroundColor = MixedColor(normal: iVerbs.colour, night: iVerbs.Colour.darkBlue)
        self.selectedBackgroundView = sbv
        
        // Set colour of text labels when the cell is tapped to white
        self.textLabel?.highlightedTextColor = UIColor.white
        self.detailTextLabel?.highlightedTextColor = UIColor.white
    }

}
