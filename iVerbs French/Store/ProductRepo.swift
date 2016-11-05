//
//  ProductRepo.swift
//  iVerbs
//
//  Created by Brad Reed on 02/10/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import Foundation
import StoreKit
import RealmSwift

public class ProductRepo {
    
    static let DisableAds = "uk.co.bradreed.iverbs.ads1"
    
    static let productIdentifiers: Set<ProductIdentifier> = [ProductRepo.DisableAds]
    
    static let store = StoreManager(productIds: ProductRepo.productIdentifiers)
    
    var products: Results<Product> = RealmManager.realm.objects(Product.self)
    
    func refreshProducts(callback: @escaping (Bool, Results<Product>) -> Void) {
        ProductRepo.store.requestProducts { success, skProducts in
            if success {
                self.clearProducts()
                self.storeProducts(products: skProducts!)
            }
            DispatchQueue.main.async {
                callback(success, self.products)
            }
        }
    }
    
    // Store the products in the SKProduct array in the Realm
    private func storeProducts(products: [SKProduct]) {
        let realmProducts = products.map { product in
            return Product(skProduct: product)
        }
        RealmManager.realmWrite { realm in
            realm.add(realmProducts)
        }
    }
    
    // Clear all products from the local cache
    private func clearProducts() {
        RealmManager.realmWrite { realm in
            realm.delete(realm.objects(Product.self))
        }
    }
    
}

/*func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}*/
