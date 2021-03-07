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
enum AppAction: Equatable {
    case counterView(CounterViewAction)
    case favoritePrimes(FavoritePrimesAction)
    // MARK: The Point - Local dependencies
    case offlineCounterView(CounterViewAction)
}

// ActivityFeed 도메인에 특화된 High-order Reducr
func activityFeed(
    _ reducer: @escaping Reducer<AppState, AppAction, AppEnvironment>
) -> Reducer<AppState, AppAction, AppEnvironment> {
    
    return { state, action, environment in
        switch action {
        case .counterView(.counter),
             .offlineCounterView(.counter),
             .favoritePrimes(.loadedFavoritePrimes),
             .favoritePrimes(.loadButtonTapped),
             .favoritePrimes(.saveButtonTapped),
             // MARK: The Point - Sharing dependencies
             .favoritePrimes(.primeButtonTapped(_)),
             .favoritePrimes(.nthPrimeResponse),
             .favoritePrimes(.alertDismissButtonTapped):
            break
            
        case .counterView(.primeModal(.addFavoritePrime)),
             .offlineCounterView(.primeModal(.addFavoritePrime)):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
            
        case .counterView(.primeModal(.removeFavoritePrime)),
             .offlineCounterView(.primeModal(.removeFavoritePrime)):
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
            
        case let .favoritePrimes(.removeFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
            }
        }
        return reducer(&state, action, environment)
    }
}


typealias AppEnvironment = (
    fileClient: FileClient,
    nthPrime: (Int) -> Effect<Int?>,
    // MARK: The Point - Local dependencies
    offlineNthPrime: (Int) -> Effect<Int?>
)

// MARK: - Global Reducer
let appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
    pullback(
        counterViewReducer,
        value: \AppState.counterView,
        action: /AppAction.counterView,
        environment: { $0.nthPrime }
    ),
    // MARK: The Point - Local dependencies
    pullback(
        counterViewReducer,
        value: \AppState.counterView,
        action: /AppAction.offlineCounterView,
        //        environment: { $0.nthPrime }
        environment: { $0.offlineNthPrime }
    ),
    // MARK: The Point - Sharing dependencies
    pullback(
        favoritePrimesReducer,
        value: \.favoritePrimesState,
        action: /AppAction.favoritePrimes,
        environment: { ($0.fileClient, $0.nthPrime) }
    )
)
