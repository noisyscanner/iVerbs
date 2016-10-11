//
//  iVerbs.Swift
//  iVerbs
//
//  Created by Brad Reed on 30/09/2015.
//  Copyright © 2015 Brad Reed. All rights reserved.
//

import UIKit
import RealmSwift
import SCLAlertView

struct iVerbs {
    
    static var colour = UIColor(red: 0.165, green: 0.427, blue: 0.62, alpha: 1) // #2a6d9e

    struct Colour {
        static let dark = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1) // #171717
        static let darkTable = UIColor(red: 13/255, green: 13/255, blue: 13/255, alpha: 1) // #0D0D0D
        static let darkNav = UIColor(red: 0.0941, green: 0.0941, blue: 0.0941, alpha: 1) // #181818
        static let darkSep = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1) // #222222
        
        static let lightSep = UIColor(red: 0.784, green: 0.781, blue: 0.8, alpha: 1) // #C8C7CC
        static let darkBlue = UIColor(red: 15/255, green: 40/255, blue: 59/255, alpha: 1) // #0F283B
        
        
    }
    /*static var colour: UIColor {
        return Setting.by(identifier: "night")?.on ?
        static var colour = UIColor(red: 0.165, green: 0.427, blue: 0.62, alpha: 1) : // #2a6d9e
    }*/
    
    struct Api {
        static var baseURL = "http://ivapi.bradreed.co.uk"
//        static var baseURL = "http://brads-macbook-air.local"
        static let salt = "mSRy4DOUWH TmJ1o-bLlnl~pfDkKrWmtktl~OMHZQbQ1ufcf o%aQl1q8iiQ"
        
    }
    
    // Display an error alert to the user TODO optional retry closure parameter
    static func displayError(_ title: String, message: String, cancelButtonTitle: String = "Okay") {
        // Alerts must be displayed on the main thread
        DispatchQueue.main.async {
            let alert = SCLAlertView()
//            alert.showCloseButton = true
            
            let _ = alert.showError(title, subTitle: message, closeButtonTitle: cancelButtonTitle)
            
        }
    }
    
}
