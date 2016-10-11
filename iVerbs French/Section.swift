//
//  Section.swift
//  iVerbs
//
//  Created by Brad Reed on 08/10/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation

// Represents a section in the verb list in VerbListController
struct Section {
    var title = "" // The letter for the section
    var verbs: [Verb] = [] // The verbs that the section displays
    
    // A function to add a verb to the verbs array
    // Marked as 'mutating' because this is a struct, not a class
    // Swift structs require this
    mutating func addVerb(_ verb: Verb) {
        self.verbs.append(verb)
    }
}
