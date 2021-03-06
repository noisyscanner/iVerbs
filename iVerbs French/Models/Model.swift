//
//  Model.swift
//  iVerbs
//
//  Created by Brad Reed on 21/09/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift

typealias JSONDict = [String: AnyObject]

protocol Model {
    
    init?(dict: JSONDict)
    
}
