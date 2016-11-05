//
//  Product.swift
//  iVerbs
//
//  Created by Brad Reed on 07/10/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import Foundation
import RealmSwift
import StoreKit

class Product: Object {
    
    dynamic var productIdentifier: String = ""
    dynamic var localizedTitle: String = ""
    dynamic var localizedDescription: String = ""
    dynamic var price: Float = 0.0
    dynamic var priceLocaleIdentifier: String = ""
    
    var purchased: Bool {
        return ProductRepo.store.isProductPurchased(productIdentifier)
    }

    convenience init(skProduct: SKProduct) {
        self.init()
        self.productIdentifier = skProduct.productIdentifier
        self.localizedTitle = skProduct.localizedTitle
        self.localizedDescription = skProduct.localizedDescription
        self.price = skProduct.price.floatValue
        self.priceLocaleIdentifier = skProduct.priceLocale.identifier
    }
    
    // Return all projects
    class func all() -> Results<Product> {
        return RealmManager.realm.objects(Product.self)
    }
    
    // Find Product by its identifier
    class func findBy(identifier: String) -> Product? {
        return all().filter("productIdentifier = '\(identifier)'").first
    }
    
}
