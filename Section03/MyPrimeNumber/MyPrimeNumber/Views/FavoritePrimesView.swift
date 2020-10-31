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
                self.store.send(.favoritePrimes(.removeFavoritePrimes(indexSet)))
            }
        }
        .navigationBarTitle("Favorite Primes")
    }
}
