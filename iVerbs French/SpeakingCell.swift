//
//  ConjugationCell.swift
//  iVerbs
//
//  Created by Brad Reed on 05/10/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import UIKit
import AVFoundation

class SpeakingCell: iVerbsTintedCell {
    
    // This should be set in tableView:cellForRowAtIndexPath:
    //
    // Used for the speaking of verbs, so the Speech Synthesiser
    // knows which language to speak in
    var language: Language?
    
    // Return the text to speak when the user taps 'Speak'
    // or copy when the user taps 'Copy' on the menu
    var textToSpeak: String {
        return detailTextLabel?.text ?? ""
    }
    
    // Return true/false if the cell can perform the given command
    // This cell handles the 'copy' and 'speak' actions, so return true for those
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(SpeakingCell.copy(_:)) || action == #selector(SpeakingCell.speak(_:)))
    }
    
    // This means that the cell can become the 'first responder'
    // First responder means that it can become active and handle events
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    // MARK: Speak
    
    // Speak the conjugation
    // Nothing will be said if the language is not set
    func speak(_ sender: AnyObject?) {
        if self.language != nil {
            let speaker = Speaker(language: self.language!)
            speaker.speak(self.textToSpeak)
        }
    }
    
    // MARK: Copy
    
    // Copy the conjugated form to the clipboard
    func copyText(_ sender: AnyObject?) {
        UIPasteboard.general.string = self.textToSpeak
    }
}
