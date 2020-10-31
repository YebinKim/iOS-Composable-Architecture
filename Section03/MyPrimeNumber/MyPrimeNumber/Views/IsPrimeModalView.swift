//
//  IsPrimeModalView.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import ComposableArchitecture
import PrimeModal
import SwiftUI

struct IsPrimeModalView: View {
    
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        VStack {
            if isPrime(self.store.value.count) {
                Text("\(self.store.value.count) is prime 🎉")
                if self.store.value.favoritePrimes.contains(self.store.value.count) {
                    Button("Remove from favorite primes") {
                        self.store.send(.primeModal(.removeFavoritePrime))
                    }
                } else {
                    Button("Save to favorite primes") {
                        self.store.send(.primeModal(.addFavoritePrime))
                    }
                }
            } else {
                Text("\(self.store.value.count) is not prime 😅")
            }
            
        }
    }
    
    private func isPrime(_ p: Int) -> Bool {
        if p <= 1 { return false }
        if p <= 3 { return true }
        for i in 2...Int(sqrtf(Float(p))) {
            if p % i == 0 { return false }
        }
        return true
    }
}

struct IsPrimeModalView_Previews: PreviewProvider {
    static var previews: some View {
        IsPrimeModalView(store: Store(initialValue: AppState(), reducer: appReducer))
    }
}
