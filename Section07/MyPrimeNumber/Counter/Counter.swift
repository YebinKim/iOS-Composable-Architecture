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
//    isPrimeModalShown: Bool
    // MARK: The Point - Dedicated platform SwiftUI views
    isPrimeDetailShown: Bool
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
//    public var isPrimeModalShown: Bool
    public var isPrimeDetailShown: Bool

    // MARK: State - Adapting view stores
//    public var isIncrementButtonDisabled: Bool
//    public var isDecrementButtonDisabled: Bool
//    public var isLoadingIndicatorHidden: Bool

    public init(
        alertNthPrime: PrimeAlert? = nil,
        count: Int = 0,
        favoritePrimes: [Int] = [],
        isNthPrimeButtonDisabled: Bool = false,
//        isPrimeModalShown: Bool = false
        isPrimeDetailShown: Bool = false
    ) {
        self.alertNthPrime = alertNthPrime
        self.count = count
        self.favoritePrimes = favoritePrimes
        self.isNthPrimeButtonDisabled = isNthPrimeButtonDisabled
        self.isPrimeDetailShown = isPrimeDetailShown
    }

    public var counter: CounterState {
        get { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled, self.isPrimeDetailShown) }
        set { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled, self.isPrimeDetailShown) = newValue }
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
        state.isPrimeDetailShown = true
        return []

    case .primeModalDismissed:
        state.isPrimeDetailShown = false
        return []
    }
}

public typealias CounterEnvironment = (Int) -> Effect<Int?>
