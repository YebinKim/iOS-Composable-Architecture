//
//  Counter.swift
//  Counter
//
//  Created by Yebin Kim on 2020/11/01.
//
// MARK: Reducer 모듈화: Modularizing the counter reducer

import ComposableArchitecture
import PrimeModal
import SwiftUI

// 앱 액션 모델
public enum CounterAction {
    case decreaseCount
    case increaseCount
}

public typealias CounterViewState = (count: Int, favoritePrimes: [Int])

// MARK: View Actions: Focusing on counter actions
public enum CounterViewAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
}

// MARK: - Reducers
// 앱의 기능 별 로직을 구현한 Reducer
public func counterReducer(count: inout Int, action: CounterAction) -> Void {
    switch action {
    case .increaseCount:
        count += 1
    case .decreaseCount:
        count -= 1
    }
}

// MARK: View Actions: Focusing on counter actions
public struct CounterView: View {

    //@ObservedObject var store: Store<AppState, AppAction>
    // MARK: View State: Focusing on view state
//    @ObservedObject var store: Store<CounterViewState, AppAction>
    // MARK: View Actions: Focusing on counter actions
    @ObservedObject var store: Store<CounterViewState, CounterViewAction>

    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: PrimeAlert?
    @State var isNthPrimeButtonDisabled = false

    public init(store: Store<CounterViewState, CounterViewAction>) {
        self.store = store
    }

    public var body: some View {
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
            // MARK: View State: Focusing on view state
//            IsPrimeModalView(store: self.store)
            IsPrimeModalView(
                store: self.store.view(
                    value: { ($0.count, $0.favoritePrimes) },
                    action: { .primeModal($0) }
                )
            )
        }
        .alert(item: self.$alertNthPrime) { alert in
            Alert(
                title: Text("The \(ordinal(self.store.value.count)) prime is \(alert.prime)"),
                dismissButton: .default(Text("Ok"))
            )
        }
    }

    private func nthPrimeButtonAction() {
        self.isNthPrimeButtonDisabled = true
        nthPrime(self.store.value.count) { prime in
            self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
        }
        self.isNthPrimeButtonDisabled = false
    }
}

// MARK: Utils
struct PrimeAlert: Identifiable {
    let prime: Int
    var id: Int { self.prime }
}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}
