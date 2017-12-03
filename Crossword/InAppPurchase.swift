//
//  InAppPurchase.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/24/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import Foundation
import StoreKit

enum IAP: String {
    case ThreeHints         = "com.tstick.Crossmoji.ThreeHints"
    case TenHints           = "com.tstick.Crossmoji.TenHints"
    case ThirtyHints        = "com.tstick.Crossmoji.ThirtyHints"
    case SeventyfiveHints   = "com.tstick.Crossmoji.SeventyfiveHints"
    case TwohundredHints    = "com.tstick.Crossmoji.TwohundredHints"
    case RemoveAds          = "com.tstick.Crossmoji.RemoveAds"
}

class InAppPurchase: NSObject {
    private override init() {}
    var count = 0
    static let shared = InAppPurchase()
    
    // Available products
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    // The presenting view controller is used so we can display a UIAlert
    // after a purchase failure or purchase restore.
    var presentingController: UIViewController!
    
    // Allows us to save purchases to device
    let defaults = UserDefaults.standard
    
    func getProducts() {
        // Gets products from itunes connect
        let products: Set = [IAP.ThreeHints.rawValue, IAP.TenHints.rawValue,
                             IAP.ThirtyHints.rawValue, IAP.SeventyfiveHints.rawValue,
                             IAP.TwohundredHints.rawValue, IAP.RemoveAds.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        
        // Sets our transaction observer
        paymentQueue.add(self)
    }
    
    func purchaseProduct(product: IAP, in view: UIViewController) {
        // Saves the view sent the request
        presentingController = view
        
        if products.count <= 0 {
            // Gives a dialog if there are no available products
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            alert.title = "Product retrieval failed"
            alert.message = "There product is not available at this time."
            
            presentingController.present(alert, animated: true, completion: nil)
            return
        }
        
        // If the product is the one we're looking for, set it for purchase
        guard let productToPurchase = products.filter({$0.productIdentifier == product.rawValue}).first else {
            // Gives a dialog if the selected product was not found
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            alert.title = "Product not found"
            alert.message = "We could not find a product matching the one you are trying to purchase."
            
            presentingController.present(alert, animated: true, completion: nil)

            return
        }
        
        // If the user can make purchases, perform the purchase
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: productToPurchase)
            paymentQueue.add(payment)
        } else {
            // If the user can't make the purchase, alert them
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            alert.title = "Purchase failed"
            alert.message = "User is not allowed to make this purchase."
            presentingController.present(alert, animated: true, completion: nil)
        }
    }
    
    func restorePurchases(in view: UIViewController) {
        // Saves the view sent the request
        presentingController = view
        
        // If the user can make the restore, perform it
        if SKPaymentQueue.canMakePayments() {
            paymentQueue.restoreCompletedTransactions()
        } else {
            // If the user can't make the restore, alert them
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            alert.title = "Restore failed"
            alert.message = "User is not allowed to make restore this purchase."
            presentingController.present(alert, animated: true, completion: nil)
        }
    }
    
    func handlePurchase(purchase: String) {
        // Handles the purchase and gives the user what they bought
        switch purchase {
        case IAP.ThreeHints.rawValue:
            print("Purchased 3 hints")
            Settings.cheatCount += 3
            defaults.set(Settings.cheatCount, forKey: "cheatCount")
        case IAP.TenHints.rawValue:
            print("Purchased 10 hints")
            Settings.cheatCount += 10
            defaults.set(Settings.cheatCount, forKey: "cheatCount")
        case IAP.ThirtyHints.rawValue:
            print("Purchased 30 hints")
            Settings.cheatCount += 30
            defaults.set(Settings.cheatCount, forKey: "cheatCount")
        case IAP.SeventyfiveHints.rawValue:
            print("Purchased 75 hints")
            Settings.cheatCount += 75
            defaults.set(Settings.cheatCount, forKey: "cheatCount")
        case IAP.TwohundredHints.rawValue:
            print("Purchased 200 hints")
            Settings.cheatCount += 200
            defaults.set(Settings.cheatCount, forKey: "cheatCount")
        case IAP.RemoveAds.rawValue:
            print("Purchased/Restored remove ads")
            Settings.adsDisabled = true
            defaults.set(Settings.adsDisabled, forKey: "adsDisabled")
        default:
            print("Unknown purchase identifier")
        }
    }
}

extension InAppPurchase: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
}

extension InAppPurchase: SKPaymentTransactionObserver {
    // Happens when the transaction is finished
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // This alert is used to notify of restore completion or purchase failure
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                // A purchased transaction should give the user their product
                self.handlePurchase(purchase: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
            case .restored:
                // A restored transaction should restore the user purchase and inform
                // of the completon
                self.handlePurchase(purchase: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                alert.title = "Purchase restored"
                alert.message = "All previous purchases have been restored."
                presentingController.present(alert, animated: true, completion: nil)
            case .failed:
                // A failed transaction should inform the user that their purchase failed
                alert.title = "Transaction Failed"
                alert.message = "The transaction could not be completed at this time."
                queue.finishTransaction(transaction)
                presentingController.present(alert, animated: true, completion: nil)
            case .deferred:
                queue.finishTransaction(transaction)
            }
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
        case .deferred:
            return "Deferred"
        case .failed:
            return "Failed"
        case .purchased:
            return "Purchased"
        case .purchasing:
            return "Purchasing"
        case .restored:
            return "Restored"
        }
    }
}
