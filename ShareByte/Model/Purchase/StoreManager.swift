//
//  StoreManager.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 1/6/24.
//

import Foundation
import StoreKit

protocol StoreManagerDelegate {
    func storeManagerChanges()
}

extension SKProduct {
    func localizedPrice()  -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
    
}

class StoreManager: NSObject, ObservableObject {
    static let shared = StoreManager()
    private let allTicketIdentifier: [String] = SafeInfo.productIDs
    var storeManagerDelegate: StoreManagerDelegate?
    @Published var product: SKProduct?
    
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func getProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(StoreManager.shared.allTicketIdentifier))
        request.delegate = self
        request.start()
    }
    
    func purchase(product: SKProduct) -> Bool {
        if !StoreManager.shared.canMakePayments() {
            return false
        } else {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
        return true
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

extension StoreManager: SKProductsRequestDelegate, SKRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //let badProducts = response.invalidProductIdentifiers
        let goodProducts = response.products
        
        if !goodProducts.isEmpty {
            // сортируем по цене
            Task { @MainActor in
                product = response.products[0]
            }
            
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("didFailWithError ", error)
        DispatchQueue.main.async {
            print("purchase failed")
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        DispatchQueue.main.async {
            print("request did finish ")
        }
    }
    
}

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("paymentQueue \(queue)")
        for transaction in transactions {
            print("paymentQUEUE transaction \(transaction.transactionState)")
            if transaction.transactionState == .purchased {
                SKPaymentQueue.default().finishTransaction(transaction)
                
                Dict.AppUserDefaults.setPremiumValues()
                
                if storeManagerDelegate != nil {
                    storeManagerDelegate!.storeManagerChanges()
                }
                
            } else if transaction.transactionState == .restored {
                SKPaymentQueue.default().finishTransaction(transaction)
                
                Dict.AppUserDefaults.setPremiumValues()
                
                if storeManagerDelegate != nil {
                    storeManagerDelegate!.storeManagerChanges()
                }
            } else if transaction.transactionState == .failed {
                // payment failed
                if let error = transaction.error {
                    let errorDesc = error.localizedDescription
                    print("Transaction failed: \(errorDesc)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }    
}
