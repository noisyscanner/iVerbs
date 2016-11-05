//
//  IVError.swift
//  iVerbs
//
//  Created by Brad Reed on 20/09/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import Foundation

enum IVError: Error {
    case invalidToken
    case noData
    case auth
    
    var localizedDescription: String {
        switch self {
        case .auth:
            return "Authentication error"
        case .noData:
            return "No data received from iVerbs server"
        case .invalidToken:
            return "Invalid token from iVerbs server"
        }
    }
}
