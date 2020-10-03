//
//  FavoritePrimesView.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import SwiftUI

struct FavoritePrimesView: View {

    @ObservedObject var store: Store<AppState, AppAction>

    var body: some View {
        List {
            ForEach(self.store.value.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
//                for index in indexSet {
//                    let prime = self.store.value.favoritePrimes[index]
//                    self.store.value.favoritePrimes.remove(at: index)
//                    self.store.value.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
//                }
                // MARK: 상태 변화 코드 Store로 이동
                self.store.send(.favoritePrimes(.removeFavoritePrimes(indexSet)))
            }
        }
        .navigationBarTitle("Favorite Primes")
    }
}
