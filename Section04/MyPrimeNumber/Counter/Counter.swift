//
//  Counter.swift
//  Counter
//
//  Created by Yebin Kim on 2020/11/01.
//

import ComposableArchitecture
import PrimeModal
import SwiftUI

// 앱 액션 모델
public enum CounterAction {
    case decreaseCount
    case increaseCount
}

public typealias CounterViewState = (count: Int, favoritePrimes: [Int])

public enum CounterViewAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)

    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }
    var primeModal: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }
        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
        }
    }
}

public let counterViewReducer: (inout CounterViewState, CounterViewAction) -> Effect = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.self, action: \.primeModal)
)

// MARK: - Reducers
// 앱의 기능 별 로직을 구현한 Reducer
public func counterReducer(count: inout Int, action: CounterAction) -> Effect {
    switch action {
    case .increaseCount:
        count += 1
        return {}
    case .decreaseCount:
        count -= 1
        return {}
    }
}

public struct CounterView: View {

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
