//
//  Speaks.swift
//  iVerbs
//
//  Created by Brad Reed on 27/07/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import Foundation

// This protocol extension provides a speak() method to pronounce a word

protocol Speaks {
    
    var textToSpeak: String { get }
    
    var language: Language? { get }
    
    func speak(_ callback: (() -> Void)?)
    
}

extension Speaks {
    
    func speak(_ callback: (() -> Void)? = nil) {
        if self.language != nil {
            let speaker = Speaker(language: self.language!, callback: callback)
            speaker.speak(self.textToSpeak)
        }
        
    }
    
}
