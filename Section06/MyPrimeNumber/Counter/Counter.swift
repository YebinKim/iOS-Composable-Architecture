//
//  Counter.swift
//  Counter
//
//  Created by Yebin Kim on 2020/11/01.
//

import ComposableArchitecture
import PrimeModal
import SwiftUI
import Combine
import CasePaths

public typealias CounterState = (alertNthPrime: PrimeAlert?, count: Int, isNthPrimeButtonDisabled: Bool)

// 앱 액션 모델
public enum CounterAction: Equatable {
    case decreaseCount
    case increaseCount
    case nthPrimeButtonTapped
    case nthPrimeResponse(n: Int, prime: Int?)
    case alertDismissButtonTapped
}

public struct PrimeAlert: Equatable, Identifiable {
    public let n: Int
    public let prime: Int
    public var id: Int { self.prime }

    public init(n: Int, prime: Int) {
        self.n = n
        self.prime = prime
    }
}

// 앱 상태 모델
public struct CounterViewState: Equatable {
    public var alertNthPrime: PrimeAlert?
    public var count: Int
    public var favoritePrimes: [Int]
    public var isNthPrimeButtonDisabled: Bool

    public init(
        alertNthPrime: PrimeAlert? = nil,
        count: Int = 0,
        favoritePrimes: [Int] = [],
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

public enum CounterViewAction: Equatable {
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

public let counterViewReducer: Reducer<CounterViewState, CounterViewAction, CounterEnvironment> = combine(
    pullback(
        counterReducer,
        value: \CounterViewState.counter,
        action: /CounterViewAction.counter,
        environment: { $0 }
    ),
    pullback(
        primeModalReducer,
        value: \.primeModal,
        action: /CounterViewAction.primeModal,
        environment: { _ in () }
    )
)

// MARK: - Reducers
// 앱의 기능 별 로직을 구현한 Reducer
public func counterReducer(
    state: inout CounterState,
    action: CounterAction,
    environment: CounterEnvironment
) -> [Effect<CounterAction>] {
    switch action {
    case .increaseCount:
        state.count += 1
        return []

    case .decreaseCount:
        state.count -= 1

        // MARK: Dependency Injection Made Composable - Effects recap
        let count = state.count
        return [
            .fireAndForget {
                print("DecreaseCount Tapped", count)
            },

            Just(CounterAction.increaseCount)
                .delay(for: 1, scheduler: DispatchQueue.main)
                .eraseToEffect()
        ]

    case .nthPrimeButtonTapped:
        state.isNthPrimeButtonDisabled = true
        let n = state.count
        return [
            environment(state.count)
                .map { CounterAction.nthPrimeResponse(n: n, prime: $0) }
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        ]

    case .nthPrimeResponse(let n, let prime):
        state.alertNthPrime = prime.map { PrimeAlert(n: n, prime: $0) }
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
        self.store.send(.counter(.nthPrimeButtonTapped))
    }
}

//public struct CounterEnvironment {
//    var nthPrime: (Int) -> Effect<Int?>
//}
//
//extension CounterEnvironment {
//    static let live = CounterEnvironment(nthPrime: Counter.nthPrime)
//}
//
//#if DEBUG
//extension CounterEnvironment {
//    static let mock = CounterEnvironment(nthPrime: { _ in .sync { 17 } })
//}
//#endif
//
//var Current = CounterEnvironment.live

public typealias CounterEnvironment = (Int) -> Effect<Int?>

// MARK: Utils
private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}
