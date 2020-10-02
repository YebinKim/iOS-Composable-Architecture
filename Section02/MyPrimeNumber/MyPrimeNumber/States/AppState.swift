//
//  AppState.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import SwiftUI
import Combine

class AppState: ObservableObject {

    @Published var count = 0
    @Published var favoritePrimes: [Int] = []
    @Published var activityFeed: [Activity] = []
    @Published var loggedInUser: User? = nil

    struct Activity {
        let timestamp: Date
        let type: ActivityType

        enum ActivityType {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)
        }
    }

    struct User {
        let id: Int
        let name: String
        let bio: String
    }
}

//extension AppState {
//
//    func addFavoritePrime() {
//        self.favoritePrimes.append(self.count)
//        self.activityFeed.append(Activity(timestamp: Date(), type: .addedFavoritePrime(self.count)))
//    }
//
//    func removeFavoritePrime(_ prime: Int) {
//        self.favoritePrimes.removeAll(where: { $0 == prime })
//        self.activityFeed.append(Activity(timestamp: Date(), type: .removedFavoritePrime(prime)))
//    }
//
//    func removeFavoritePrime() {
//        self.removeFavoritePrime(self.count)
//    }
//
//    func removeFavoritePrimes(at indexSet: IndexSet) {
//        for index in indexSet {
//            self.removeFavoritePrime(self.favoritePrimes[index])
//        }
//    }
//}
