//
//  Counter.swift
//  Counter
//
//  Created by Yebin Kim on 2020/11/01.
//

import ComposableArchitecture
import PrimeModal
import PrimeAlert
import SwiftUI
import Combine
import CasePaths

public typealias CounterState = (
    alertNthPrime: PrimeAlert?,
    count: Int,
    isNthPrimeButtonDisabled: Bool,
    // 누락 코드
    isPrimeModalShown: Bool
)

// 앱 액션 모델
public enum CounterAction: Equatable {
    case decreaseCount
    case increaseCount
    case nthPrimeButtonTapped
    case nthPrimeResponse(n: Int, prime: Int?)
    case alertDismissButtonTapped
    // 누락 코드
    case isPrimeButtonTapped
    case primeModalDismissed
}

// 앱 상태 모델
//public struct CounterViewState: Equatable {
// MARK: State - Counter view performance
public struct CounterFeatureState: Equatable {
    public var alertNthPrime: PrimeAlert?
    public var count: Int
    public var favoritePrimes: [Int]
    public var isNthPrimeButtonDisabled: Bool
    public var isPrimeModalShown: Bool

    // MARK: State - Adapting view stores
//    public var isIncrementButtonDisabled: Bool
//    public var isDecrementButtonDisabled: Bool
//    public var isLoadingIndicatorHidden: Bool

    public init(
        alertNthPrime: PrimeAlert? = nil,
        count: Int = 0,
        favoritePrimes: [Int] = [],
        isNthPrimeButtonDisabled: Bool = false,
        isPrimeModalShown: Bool = false
    ) {
        self.alertNthPrime = alertNthPrime
        self.count = count
        self.favoritePrimes = favoritePrimes
        self.isNthPrimeButtonDisabled = isNthPrimeButtonDisabled
        self.isPrimeModalShown = isPrimeModalShown
    }

    public var counter: CounterState {
        get { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled, self.isPrimeModalShown) }
        set { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled, self.isPrimeModalShown) = newValue }
    }

    public var primeModal: PrimeModalState {
        get { (self.count, self.favoritePrimes) }
        set { (self.count, self.favoritePrimes) = newValue }
    }
}

//public enum CounterViewAction: Equatable {
// MARK: State - Counter view performance
public enum CounterFeatureAction: Equatable {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
}

public let counterViewReducer: Reducer<CounterFeatureState, CounterFeatureAction, CounterEnvironment> = combine(
    pullback(
        counterReducer,
        value: \CounterFeatureState.counter,
        action: /CounterFeatureAction.counter,
        environment: { $0 }
    ),
    pullback(
        primeModalReducer,
        value: \.primeModal,
        action: /CounterFeatureAction.primeModal,
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

    case .isPrimeButtonTapped:
        state.isPrimeModalShown = true
        return []

    case .primeModalDismissed:
        state.isPrimeModalShown = false
        return []
    }
}

public struct CounterView: View {

    // MARK: State - Counter view performance
    struct State: Equatable {
        let alertNthPrime: PrimeAlert?
        let count: Int
        let isNthPrimeButtonDisabled: Bool
        let isPrimeModalShown: Bool

        // MARK: State - Adapting view stores
        let isIncrementButtonDisabled: Bool
        let isDecrementButtonDisabled: Bool
    }

//    @ObservedObject var store: Store<CounterViewState, CounterViewAction>
    // MARK: State - View store performance
    let store: Store<CounterFeatureState, CounterFeatureAction>
    @ObservedObject var viewStore: ViewStore<State>

//    @State var isPrimeModalShown: Bool = false

    // MARK: Performance - View.init/body: tracking
    public init(store: Store<CounterFeatureState, CounterFeatureAction>) {
        print("CounterView.init")
        self.store = store
        self.viewStore = self.store
            .scope(value: State.init(counterFeatureState:), action: { $0 })
            .view(removeDuplicates: ==)
    }

    public var body: some View {
        print("CounterView.body")
        return VStack {
            HStack {
                Button("-") { self.store.send(.counter(.decreaseCount)) }
                    // MARK: State - Counter view performance
                    .disabled(self.viewStore.value.isDecrementButtonDisabled)

                Text("\(self.viewStore.value.count)")

                Button("+") { self.store.send(.counter(.increaseCount)) }
                    // MARK: State - Counter view performance
                    .disabled(self.viewStore.value.isIncrementButtonDisabled)
            }
            Button("Is this prime?") { self.store.send(.counter(.isPrimeButtonTapped)) }
            Button("What is the \(ordinal(self.viewStore.value.count)) prime?") {
                self.store.send(.counter(.nthPrimeButtonTapped))
            }
            .disabled(self.viewStore.value.isNthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
        .sheet(
            isPresented: .constant(self.viewStore.value.isPrimeModalShown),
            onDismiss: { self.store.send(.counter(.primeModalDismissed)) }
        ) {
            IsPrimeModalView(
                store: self.store.scope(
                    value: { ($0.count, $0.favoritePrimes) },
                    action: { .primeModal($0) }
                )
            )
        }
        .alert(
          item: Binding.constant(self.viewStore.value.alertNthPrime)
        ) { alert in
            Alert(
                title: Text("The \(ordinal(self.viewStore.value.count)) prime is \(alert.prime)"),
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

// MARK: State - Counter view performance
extension CounterView.State {
    init(counterFeatureState: CounterFeatureState) {
        self.alertNthPrime = counterFeatureState.alertNthPrime
        self.count = counterFeatureState.count
        self.isNthPrimeButtonDisabled = counterFeatureState.isNthPrimeButtonDisabled
        self.isPrimeModalShown = counterFeatureState.isPrimeModalShown
        self.isIncrementButtonDisabled = counterFeatureState.isNthPrimeButtonDisabled
        self.isDecrementButtonDisabled = counterFeatureState.isNthPrimeButtonDisabled
    }
}

public typealias CounterEnvironment = (Int) -> Effect<Int?>
