//
//  StoreManager.swift
//  iVerbs
//
//  Created by Brad Reed on 25/05/2016.
//  Copyright © 2016 Brad Reed. All rights reserved.
//

import StoreKit
import Alamofire

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

open class StoreManager : NSObject {
    
    
    fileprivate let productIdentifiers: Set<ProductIdentifier>
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    static let StoreManagerPurchaseNotification = "StoreManagerPurchaseNotification"
    static let StoreManagerFailureNotification = "StoreManagerFailureNotification"
    
    var skProducts: [SKProduct]?
    
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        for productIdentifier in productIds {
            // TODO: Store purchased in Realm
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    /// Validate IAP receipt from Apple
    func validateReceipt(callback: @escaping (_ success: Bool) -> Void) {
        
        if let receipt =  Bundle.main.appStoreReceiptURL {
            do {
                let data = try Data(contentsOf: receipt)
                let requestContents:[String:String] =
                    ["receipt": data.base64EncodedString(options: [])]
                let requestData = try! JSONSerialization.data(withJSONObject: requestContents,options: [])
                var request = URLRequest(url: URL(string: "https://bradreed.co.uk/ivapi/v1/verify")!)
                request.httpMethod = "POST"
                request.httpBody = requestData
                
                let param = try URLEncoding.httpBody.encode(request, with: nil)
                
                Alamofire.request(param)
                    .responseJSON { response in
                        let apiresponse = ApiResponse(response: response)
                        if let valid = apiresponse.data?["valid"] as? Bool {
                            callback(valid)
                        } else {
                            // Data not received, assume failure
                            callback(false)
                        }
                    }
            } catch let error {
                print("Error validating receipt", error)
                callback(false)
            }
        } else { callback(false) }
    
    }
}

// MARK: - StoreKit API

extension StoreManager {
    
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        
        productsRequest!.start()
    }
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func buyProduct(productModel: Product) {
        if skProducts == nil {
            // Products are not loaded, load them and call this function again
            self.requestProducts {_,_ in
                self.buyProduct(productModel: productModel)
            }
        } else {
            let identifier = productModel.productIdentifier
            guard let skProduct = self.skProducts!.filter({ skProduct in
                return identifier == skProduct.productIdentifier
            }).first else {
                // Product doesn't actually exist, fail
                NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: StoreManager.StoreManagerFailureNotification)))
                return
            }
            self.buyProduct(skProduct)
        }
    }
    
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

// MARK: - SKProductsRequestDelegate

extension StoreManager: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        self.skProducts = response.products
        productsRequestCompletionHandler?(true, self.skProducts)
        clearRequestAndHandler()
        
        for p in self.skProducts! {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension StoreManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                validateReceipt() { success in
                    if success {
                        self.complete(transaction: transaction)
                    } else {
                        self.fail(transaction: transaction)
                    }
                }
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                validateReceipt() { success in
                    if success {
                        self.restore(transaction: transaction)
                    } else {
                        self.fail(transaction: transaction)
                    }
                }
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    // There are no transactions to restore probably
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
         deliverFailedNotification(error: error.localizedDescription)
    }

    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        
        // TODO: Validate receipt
        
        deliverPurchaseNotification(for: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        deliverPurchaseNotification(for: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        var error: String? = nil
        
        if let transactionError = transaction.error as? NSError {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                error = transaction.error?.localizedDescription
                print("Transaction Error: \(error)")
            }
        }
        
        deliverFailedNotification(error: error)
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotification(for identifier: String?) {
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: StoreManager.StoreManagerPurchaseNotification), object: identifier)
    }
    
    private func deliverFailedNotification(error: String?) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: StoreManager.StoreManagerFailureNotification), object: error)
        
    }
}
