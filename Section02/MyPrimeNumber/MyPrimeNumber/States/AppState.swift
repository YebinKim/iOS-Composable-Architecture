//
//  AppState.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import SwiftUI
import Combine

// MARK: 글로벌 상태를 모델링하는 더 나은 방법
// AppState를 값 타입으로 변경하고 ObservableObject 래퍼(Store)로 감싼다
// 값 타입으로 모델링함으로써 데이터를 간단한 단위로 모델링할 수 있게 되고 상태 변화에 대한 영향을 줄임
struct AppState {

    var count = 0
    var favoritePrimes: [Int] = []
    var activityFeed: [Activity] = []
    var loggedInUser: User? = nil

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

// MARK: Pulling back more reducers
// AppState에서 favoritePrimesReducer을 pulling back하여 오류 수정
// MARK: Higher-order activity feeds
// activityFeed 임시 상태 제거
//extension AppState {
//
//    var favoritePrimesState: FavoritePrimesState {
//        get {
//            return FavoritePrimesState(
//                favoritePrimes: self.favoritePrimes,
//                activityFeed: self.activityFeed
//            )
//        }
//        set {
//            self.activityFeed = newValue.activityFeed
//            self.favoritePrimes = newValue.favoritePrimes
//        }
//    }
//}

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
