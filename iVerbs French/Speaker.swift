//
//  Speaker.swift
//  iVerbs
//
//  Created by Brad Reed on 17/02/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import Foundation
import AVFoundation

/**
 * Class to manage speaking verbs and conjugations.
 */
class Speaker: NSObject, AVSpeechSynthesizerDelegate {
    
    // The speed at which the text is spoken
    var speechRate: Float = Setting.by(identifier: "speechrate")?.value ?? 0.5
    
    var synth: AVSpeechSynthesizer
    var voice: AVSpeechSynthesisVoice?
    
    var callback: (() -> ())?
    
    // Create new speaker instance, set up language synth and voice
    // with given Language instance
    convenience init(language: Language, callback: (() -> ())? = nil) {
        self.init(locale: language.locale, callback: callback)
    }
    
    // Init with locale as string
    init(locale: String, callback: (() -> ())? = nil) {
        synth = AVSpeechSynthesizer()
        self.callback = callback
        
        super.init()
        
        synth.delegate = self
        
        // language.locale tells the speech synthesizer what language voice to speak in
        voice = AVSpeechSynthesisVoice(language: locale)
    }
    
    // Speak the given text
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        
        utterance.voice = voice
        utterance.rate = speechRate
        
        synth.speak(utterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if callback != nil {
            self.callback!()
        }
    }
    
}
