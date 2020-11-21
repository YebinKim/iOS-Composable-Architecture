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

// 앱 액션 모델
enum AppAction {
//    case counter(CounterAction)
//    case primeModal(PrimeModalAction)
    // MARK: The Point: Fixing the root app
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
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    
    return { state, action in
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
        }
        
        reducer(&state, action)
    }
}

// MARK: - Global Reducer
let appReducer: (inout AppState, AppAction) -> Void = combine(
    // MARK: The Point: The counter app
    // CounterView Reducer를 분리 -> Playground에서도 실행할 수 있도록
//    pullback(counterReducer, value: \.count, action: \.counter),
//    pullback(primeModalReducer, value: \.primeModal, action: \.primeModal),
    // MARK: The Point: Fixing the root app
    pullback(counterViewReducer, value: \.counterView, action: \.counterView),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)
