//
//  VerbListCell.swift
//  iVerbs French
//
//  Created by Brad Reed on 04/01/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class iVerbsTintedCell: UITableViewCell {
    
    // This should be set in tableView:cellForRowAtIndexPath:
    //
    // Used for the speaking of verbs, so the Speech Synthesiser
    // knows which language to speak in
    var language: Language? {
        // TODO: Is this efficient? Seems inefficient as fuck
        didSet {
            let sbv = UIView(frame: CGRectMake(0, 0, 320, 44))
            sbv.backgroundColor = UIColor(rgba: "#" + language!.colour)
            self.selectedBackgroundView = sbv
    
            let highlightedColour = UIColor.whiteColor()
            self.textLabel?.highlightedTextColor = highlightedColour
            self.detailTextLabel?.highlightedTextColor = highlightedColour
        }
    }
    
}