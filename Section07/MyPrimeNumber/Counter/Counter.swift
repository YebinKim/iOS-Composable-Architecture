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
//    case nthPrimeButtonTapped
    case nthPrimeResponse(n: Int, prime: Int?)
    case alertDismissButtonTapped
    // 누락 코드
    case isPrimeButtonTapped
    case primeModalDismissed
    // MARK: Action - Action adaptation
//    case doubleTap
    // MARK: Action - View actions
    case requestNthPrime
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

//    case .nthPrimeButtonTapped, .doubleTap:
    // MARK: Action - View actions
    case .requestNthPrime:
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

        // MARK: Action - View actions
        let nthPrimeButtonTitle: String
    }

    // MARK: Action - View actions
    enum Action {
        case decreaseCount
        case increaseCount
        case nthPrimeButtonTapped
        case alertDismissButtonTapped
        case isPrimeButtonTapped
        case primeModalDismissed
        case doubleTap
    }

//    @ObservedObject var store: Store<CounterViewState, CounterViewAction>
    // MARK: State - View store performance
    let store: Store<CounterFeatureState, CounterFeatureAction>
    @ObservedObject var viewStore: ViewStore<State, Action>

//    @State var isPrimeModalShown: Bool = false

    // MARK: Performance - View.init/body: tracking
    public init(store: Store<CounterFeatureState, CounterFeatureAction>) {
        print("CounterView.init")
        self.store = store
        self.viewStore = self.store
//            .scope(
//                value: State.init(counterFeatureState:),
//                // MARK: Action - View actions
//                action: {
//                    switch $0 {
//                    case .decreaseCount:
//                        return .counter(.decreaseCount)
//                    case .increaseCount:
//                        return .counter(.increaseCount)
//                    case .nthPrimeButtonTapped:
//                        return .counter(.requestNthPrime)
//                    case .alertDismissButtonTapped:
//                        return .counter(.alertDismissButtonTapped)
//                    case .isPrimeButtonTapped:
//                        return .counter(.isPrimeButtonTapped)
//                    case .primeModalDismissed:
//                        return .counter(.primeModalDismissed)
//                    case .doubleTap:
//                        return .counter(.requestNthPrime)
//                    }
//                }
//            )
            // MARK: Action - Tests and the view store
            .scope(
                value: State.init,
                action: CounterFeatureAction.init
            )
            .view
    }

    public var body: some View {
        print("CounterView.body")
        return VStack {
            HStack {
                Button("-") { self.viewStore.send(.decreaseCount) }
                    // MARK: State - Counter view performance
                    .disabled(self.viewStore.value.isDecrementButtonDisabled)

                Text("\(self.viewStore.value.count)")

                Button("+") { self.viewStore.send(.increaseCount) }
                    // MARK: State - Counter view performance
                    .disabled(self.viewStore.value.isIncrementButtonDisabled)
            }
            Button("Is this prime?") { self.viewStore.send(.isPrimeButtonTapped) }
            Button(self.viewStore.value.nthPrimeButtonTitle) {
                // MARK: Action - Action adaptation
//                self.store.send(.counter(.nthPrimeButtonTapped))
                self.viewStore.send(.nthPrimeButtonTapped)
            }
            .disabled(self.viewStore.value.isNthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
        .sheet(
            isPresented: .constant(self.viewStore.value.isPrimeModalShown),
            onDismiss: { self.viewStore.send(.primeModalDismissed) }
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
                    self.viewStore.send(.alertDismissButtonTapped)
                }
            )
        }
        // MARK: Action - Action adaptation
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity
        )
        .background(Color.white)
        .onTapGesture(count: 2) {
            self.viewStore.send(.doubleTap)
        }
    }

    private func nthPrimeButtonAction() {
        self.viewStore.send(.doubleTap)
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
        // MARK: Action - View actions
        self.nthPrimeButtonTitle = "What is the \(ordinal(counterFeatureState.count)) prime?"
    }
}

// MARK: Action - Tests and the view store
extension CounterFeatureAction {
    init(action: CounterView.Action) {
        switch action {
        case .decreaseCount:
            self = .counter(.decreaseCount)
        case .increaseCount:
            self = .counter(.increaseCount)
        case .nthPrimeButtonTapped:
            self = .counter(.requestNthPrime)
        case .alertDismissButtonTapped:
            self = .counter(.alertDismissButtonTapped)
        case .isPrimeButtonTapped:
            self = .counter(.isPrimeButtonTapped)
        case .primeModalDismissed:
            self = .counter(.primeModalDismissed)
        case .doubleTap:
            self = .counter(.requestNthPrime)
        }
    }
}

public typealias CounterEnvironment = (Int) -> Effect<Int?>
