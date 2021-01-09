//
//  Counter.swift
//  Counter
//
//  Created by Yebin Kim on 2020/11/01.
//

import ComposableArchitecture
import PrimeModal
import SwiftUI

// MARK: Asynchronous Effects - Local state to global state
public typealias CounterState = (alertNthPrime: PrimeAlert?, count: Int, isNthPrimeButtonDisabled: Bool)

// 앱 액션 모델
public enum CounterAction {
    case decreaseCount
    case increaseCount
    // MARK: Asynchronous Effects - Extracting our asynchronous effect
    case nthPrimeButtonTapped
    case nthPrimeResponse(Int?)
    // MARK: Asynchronous Effects - Thinking unidirectionally
    case alertDismissButtonTapped
}

//public typealias CounterViewState = (count: Int, favoritePrimes: [Int])
// 앱 상태 모델
public struct CounterViewState {
    public var alertNthPrime: PrimeAlert?
    public var count: Int
    public var favoritePrimes: [Int]
    public var isNthPrimeButtonDisabled: Bool

    public init(
        alertNthPrime: PrimeAlert? = nil,
        count: Int,
        favoritePrimes: [Int],
        isNthPrimeButtonDisabled: Bool = false
    ) {
        self.alertNthPrime = alertNthPrime
        self.count = count
        self.favoritePrimes = favoritePrimes
        self.isNthPrimeButtonDisabled = isNthPrimeButtonDisabled
    }

    public var counter: CounterState {
        get { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled) }
        set { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled) = newValue }
    }

    public var primeModal: PrimeModalState {
        get { (self.count, self.favoritePrimes) }
        set { (self.count, self.favoritePrimes) = newValue }
    }
}

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

public let counterViewReducer = combine(
  pullback(counterReducer, value: \CounterViewState.counter, action: \CounterViewAction.counter),
  pullback(primeModalReducer, value: \.primeModal, action: \.primeModal)
)

// MARK: - Reducers
// 앱의 기능 별 로직을 구현한 Reducer
public func counterReducer(state: inout CounterState, action: CounterAction) -> [Effect<CounterAction>] {
    switch action {
    case .increaseCount:
        state.count += 1
        return []

    case .decreaseCount:
        state.count -= 1
        return []

    case .nthPrimeButtonTapped:
        state.isNthPrimeButtonDisabled = true
//        let count = state.count
//        return [{
//            var p: Int?
//            let sema = DispatchSemaphore(value: 0)
//            nthPrime(count) { prime in
//                p = prime
//                sema.signal()
//            }
//            sema.wait()
//            return .nthPrimeResponse(p)
//        }]

//        return [{ callback in
//            // MARK: Refactor-related bugs
//            nthPrime(count) { prime in
//                DispatchQueue.main.async {
//                    callback(.nthPrimeResponse(prime))
//                }
//            }
//        }]
        
        return [
            nthPrime(state.count)
                .map(CounterAction.nthPrimeResponse)
                .receive(on: DispatchQueue.main)
                // MARK: - The Combine Framework and Effects: Part 2 - Refactoring asynchronous effects
                .eraseToEffect()
        ]

    case .nthPrimeResponse(let prime):
        state.alertNthPrime = prime.map(PrimeAlert.init(prime:))
        state.isNthPrimeButtonDisabled = false
        return []

    case .alertDismissButtonTapped:
        state.alertNthPrime = nil
        return []
    }
}

public struct CounterView: View {

    @ObservedObject var store: Store<CounterViewState, CounterViewAction>

    @State var isPrimeModalShown: Bool = false
//    @State var alertNthPrime: PrimeAlert?
//    @State var isNthPrimeButtonDisabled = false

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
            .disabled(self.store.value.isNthPrimeButtonDisabled)
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
        .alert(
          item: Binding.constant(self.store.value.alertNthPrime)
        ) { alert in
            Alert(
                title: Text("The \(ordinal(self.store.value.count)) prime is \(alert.prime)"),
                dismissButton: .default(Text("Ok")) {
                    self.store.send(.counter(.alertDismissButtonTapped))
                }
            )
        }
    }

    private func nthPrimeButtonAction() {
//        self.isNthPrimeButtonDisabled = true
//        nthPrime(self.store.value.count) { prime in
//            self.alertNthPrime = prime.map(PrimeAlert.init(prime:))
//            self.isNthPrimeButtonDisabled = false
//        }
        self.store.send(.counter(.nthPrimeButtonTapped))
    }
}

// MARK: Utils
public struct PrimeAlert: Identifiable {
    let prime: Int
    public var id: Int { self.prime }
}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}
