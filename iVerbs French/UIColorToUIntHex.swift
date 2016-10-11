//
//  UIColorToUIntHex.swift
//  iVerbs
//
//  Created by Brad Reed on 09/02/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import UIKit

extension UIColor {
    
    // Convert the UIColor into a UInt which can be used
    // with SCLAlertView for colouring
    func toUInt() -> UInt {
        // Define red, green, blue and alpha variables as floats
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        // Get the float values for the colour
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // ???
        return (UInt)(r*255)<<16 | (UInt)(g*255)<<8 | (UInt)(b*255)<<0
    }
    
}