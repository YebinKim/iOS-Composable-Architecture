//
//  AppState.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import Counter
import SwiftUI

// 앱 상태 모델
struct AppState: Equatable {

    @Published var count = 0
    @Published var favoritePrimes: [Int] = []
    @Published var loggedInUser: User? = nil
    @Published var activityFeed: [Activity] = []

    var alertNthPrime: PrimeAlert? = nil
    var isNthPrimeButtonDisabled: Bool = false
    
    struct Activity: Equatable {
        let timestamp: Date
        let type: ActivityType
        
        enum ActivityType: Equatable {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)
        }
    }
    
    struct User: Equatable {
        let id: Int
        let name: String
        let bio: String
    }
}

extension AppState {

    var counterView: CounterViewState {
        get {
            CounterViewState(
                alertNthPrime: self.alertNthPrime,
                count: self.count,
                favoritePrimes: self.favoritePrimes,
                isNthPrimeButtonDisabled: self.isNthPrimeButtonDisabled
            )
        }
        set {
            self.alertNthPrime = newValue.alertNthPrime
            self.count = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
            self.isNthPrimeButtonDisabled = newValue.isNthPrimeButtonDisabled
        }
    }
}
