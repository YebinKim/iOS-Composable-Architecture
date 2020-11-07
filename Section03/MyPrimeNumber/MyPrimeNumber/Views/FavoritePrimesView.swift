//
//  FavoritePrimesView.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import ComposableArchitecture
import SwiftUI

struct FavoritePrimesView: View {

    //@ObservedObject var store: Store<AppState, AppAction>
    // MARK: View State: Focusing on view state
    @ObservedObject var store: Store<[Int], AppAction>

    var body: some View {
        List {
            ForEach(self.store.value, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                self.store.send(.favoritePrimes(.removeFavoritePrimes(indexSet)))
            }
        }
        .navigationBarTitle("Favorite Primes")
    }
}
