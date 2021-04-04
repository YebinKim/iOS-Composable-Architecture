//
//  AppState.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import Counter
import FavoritePrimes
import PrimeAlert
import SwiftUI

// 앱 상태 모델
struct AppState: Equatable {

    var count = 0
    var favoritePrimes: [Int] = []
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []

    var alertNthPrime: PrimeAlert? = nil
    var isNthPrimeButtonDisabled: Bool = false
    // 누락 코드
    var isPrimeModalShown: Bool = false
    
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

    var counterView: CounterFeatureState {
        get {
            CounterFeatureState(
                alertNthPrime: self.alertNthPrime,
                count: self.count,
                favoritePrimes: self.favoritePrimes,
                isNthPrimeButtonDisabled: self.isNthPrimeButtonDisabled,
                isPrimeDetailShown: self.isPrimeModalShown
            )
        }
        set {
            self.alertNthPrime = newValue.alertNthPrime
            self.count = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
            self.isNthPrimeButtonDisabled = newValue.isNthPrimeButtonDisabled
            self.isPrimeModalShown = newValue.isPrimeDetailShown
        }
    }

    var favoritePrimesState: FavoritePrimesState {
        get {
            (self.alertNthPrime, self.favoritePrimes)
        }
        set {
            (self.alertNthPrime, self.favoritePrimes) = newValue
        }
    }
}
