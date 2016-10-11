//
//  VerbListCell.swift
//  iVerbs
//
//  Created by Brad Reed on 17/02/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import Foundation

// Table View Cell in VerbListController (Verb List)
// Inherits functionality for speaking cells from SpeakingCell
class VerbListCell: SpeakingCell {
    
    // Which way around the labels in the table are
    // 
    // case .Infinitive:
    // [Infinitive        English]
    // case .English:
    // [English        Infinitive]
    //
    var listOrder = VerbListOrder.infinitive
    
    // Return the infinitive form for the speech synthesiser to speak
    override var textToSpeak: String {
        // If the infinitive is in the left label (textLabel), return that
        // If the infinitive is in the right label (detailTextLabel), return that
        // If the labels are nil for some reason, return an empty string
        return listOrder == .infinitive ? self.textLabel?.text ?? "" : self.detailTextLabel?.text ?? ""
    }
    
}
