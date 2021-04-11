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
    case counterView(CounterFeatureAction)
    case favoritePrimes(FavoritePrimesAction)
    case offlineCounterView(CounterFeatureAction)
}

// ActivityFeed 도메인에 특화된 High-order Reducr
// MARK: Ergonomic State Management: Part 1 - Updating the app's modules
extension Reducer where Value == AppState, Action == AppAction, Environment == AppEnvironment {
    func activityFeed() -> Reducer {
        return .init { state, action, environment in
            switch action {
            case .counterView(.counter),
                 .offlineCounterView(.counter),
                 .favoritePrimes(.loadedFavoritePrimes),
                 .favoritePrimes(.loadButtonTapped),
                 .favoritePrimes(.saveButtonTapped),
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
            return self(&state, action, environment)
        }
    }
}


typealias AppEnvironment = (
    fileClient: FileClient,
    nthPrime: (Int) -> Effect<Int?>,
    offlineNthPrime: (Int) -> Effect<Int?>
)

// MARK: - Global Reducer
// MARK: Ergonomic State Management: Part 1 - Updating the app's modules
let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer.combine(
    counterFeatureReducer.pullback(
        value: \AppState.counterView,
        action: /AppAction.counterView,
        environment: { $0.nthPrime }
    ),
    counterFeatureReducer.pullback(
        value: \AppState.counterView,
        action: /AppAction.offlineCounterView,
        environment: { $0.offlineNthPrime }
    ),
    favoritePrimesReducer.pullback(
        value: \.favoritePrimesState,
        action: /AppAction.favoritePrimes,
        environment: { ($0.fileClient, $0.nthPrime) }
    )
)
