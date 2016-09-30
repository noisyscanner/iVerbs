//
//  Verb.swift
//  Realm-Test
//
//  Created by Brad Reed on 29/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

class Verb: Object {
    dynamic var id = 0
    dynamic var english = ""
    dynamic var infinitive = ""
    dynamic var normalisedInfinitive = ""

    override static func primaryKey() -> String {
        return "id"
    }

}