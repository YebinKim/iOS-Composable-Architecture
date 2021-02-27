//
//  Reducers.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/03.
//

import ComposableArchitecture
import Counter
import FavoritePrimes
import PrimeModal
import CasePaths

// 앱 액션 모델
enum AppAction {
    case counterView(CounterViewAction)
    case favoritePrimes(FavoritePrimesAction)

    var counterView: CounterViewAction? {
        get {
            guard case let .counterView(value) = self else { return nil }
            return value
        }
        set {
            guard case .counterView = self, let newValue = newValue else { return }
            self = .counterView(newValue)
        }
    }
    
    var favoritePrimes: FavoritePrimesAction? {
        get {
            guard case let .favoritePrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritePrimes = self, let newValue = newValue else { return }
            self = .favoritePrimes(newValue)
        }
    }
}

// ActivityFeed 도메인에 특화된 High-order Reducr
func activityFeed(
    _ reducer: @escaping Reducer<AppState, AppAction, AppEnvironment>
) -> Reducer<AppState, AppAction, AppEnvironment> {
    
    return { state, action, environment in
        switch action {
        case .counterView(.counter):
            break
            
        case .counterView(.primeModal(.addFavoritePrime)):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
            
        case .counterView(.primeModal(.removeFavoritePrime)):
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
            
        case let .favoritePrimes(.removeFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
            }
        case .favoritePrimes(.loadedFavoritePrimes(_)): break

        case .favoritePrimes(.saveButtonTapped): break

        case .favoritePrimes(.loadButtonTapped): break
        }

        return reducer(&state, action, environment)
    }
}

typealias AppEnvironment = (
    fileClient: FileClient,
    nthPrime: (Int) -> Effect<Int?>
)

// MARK: - Global Reducer
let appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
    pullback(
        counterViewReducer,
        value: \AppState.counterView,
        action: /AppAction.counterView,
        environment: { $0.nthPrime }
    ),
    pullback(
        favoritePrimesReducer,
        value: \.favoritePrimes,
        action: /AppAction.favoritePrimes,
        environment: { $0.fileClient }
    )
)
