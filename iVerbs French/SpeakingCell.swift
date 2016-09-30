//
//  ConjugationCell.swift
//  iVerbs French
//
//  Created by Brad Reed on 05/10/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import UIKit
import AVFoundation

class ConjugationCell: iVerbsTintedCell {
    
    // MARK: Speak
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return (action == Selector("copy:") || action == Selector("speak:"))
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // Speak the conjugation
    // Nothing will be said if the language is not set
    func speak(sender: AnyObject?) {
        if language != nil {
            let synth = AVSpeechSynthesizer()
            let utterance = AVSpeechUtterance(string: self.detailTextLabel!.text!)
            utterance.voice = AVSpeechSynthesisVoice(language: language!.locale)
            utterance.rate = 1/4
            synth.speakUtterance(utterance)
        }
    }
    
    // Copy the conjugated form to the clipboard
    override func copy(sender: AnyObject?) {
        UIPasteboard.generalPasteboard().string = self.detailTextLabel!.text!
    }
}