//
//  IapSettingCell.swift
//  iVerbs
//
//  Created by Brad Reed on 01/08/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import UIKit
import StoreKit
import NightNight

class IapSettingCell: iVerbsTintedCell {
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    var product: Product? {
        didSet {
            guard let product = product else { return }
            
            textLabel?.text = product.localizedTitle // Set title
            
            // Set localised price
            let locale = Locale(identifier: product.priceLocaleIdentifier)
            IapSettingCell.priceFormatter.locale = locale
            
            detailTextLabel?.text = IapSettingCell.priceFormatter.string(from: NSNumber(value: product.price))
            detailTextLabel?.mixedTextColor = MixedColor(normal: UIColor.darkText, night: UIColor.white)
            
            if product.purchased {
                self.accessoryType = .checkmark
            } else {
                self.accessoryType = .none
            }
        }
    }
    
    
}
