//
//  CounterView.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import ComposableArchitecture
import Counter
import SwiftUI

struct CounterView: View {

    //@ObservedObject var store: Store<AppState, AppAction>
    // MARK: View State: Focusing on view state
    @ObservedObject var store: Store<CounterViewState, AppAction>
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: PrimeAlert?
    @State var isNthPrimeButtonDisabled = false

    var body: some View {
        VStack {
            HStack {
                Button("-") {
                    self.store.send(.counter(.decreaseCount))
                }
                Text("\(self.store.value.count)")
                Button("+") {
                    self.store.send(.counter(.increaseCount))
                }
            }
            Button(action: { self.isPrimeModalShown = true }) {
                Text("Is this prime?")
            }
            Button(action: self.nthPrimeButtonAction) {
                Text("What is the \(ordinal(self.store.value.count)) prime?")
            }
            .disabled(self.isNthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
        .sheet(isPresented: self.$isPrimeModalShown) {
//            IsPrimeModalView(
//                store: self.store.view { ($0.count, $0.favoritePrimes) }
//            )
            IsPrimeModalView(store: self.store)
        }
        .alert(item: self.$alertNthPrime) { alert in
            Alert(
                title: Text("The \(ordinal(self.store.value.count)) prime is \(alert.prime)"),
                dismissButton: .default(Text("Ok"))
            )
        }
    }

    private func ordinal(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(for: n) ?? ""
    }

    private func nthPrimeButtonAction() {
        self.isNthPrimeButtonDisabled = true
        nthPrime(self.store.value.count) { prime in
            self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
        }
        self.isNthPrimeButtonDisabled = false
    }
}

struct PrimeAlert: Identifiable {
    let prime: Int
    var id: Int { self.prime }
}
