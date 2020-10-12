//
//  Reducers.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/03.
//

import Foundation

// MARK: 함수형 상태 관리
// Reducer 사용 - 상태 변화가 결합된 새로운 값 반환
//enum CounterAction {
//    case decrTapped
//    case incrTapped
//}

//func counterReducer(state: AppState, action: CounterAction) -> AppState {
//    var copy = state
//    switch action {
//    case .decrTapped:
//        copy.count -= 1
//    case .incrTapped:
//        copy.count += 1
//    }
//    return copy
//}

// MARK: Ergonomics: in-out Reducers
//func counterReducer(value: inout AppState, action: CounterAction) {
//    switch action {
//    case .decrTapped:
//        value.count -= 1
//    case .incrTapped:
//        value.count += 1
//    }
//}

// MARK: 상태 변화 코드 Store로 이동
enum CounterAction {
    case decreaseCount
    case increaseCount
}

enum PrimeModalAction {
    case addFavoritePrime
    case removeFavoritePrime
}

enum FavoritePrimesAction {
    case removeFavoritePrimes(IndexSet)
}

enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritePrimes(FavoritePrimesAction)
}

//func appReducer(value: inout AppState, action: AppAction) -> Void {
//    switch action {
//    case .counter(.decreaseCount):
//        value.count -= 1
//
//    case .counter(.increaseCount):
//        value.count += 1
//
//    case .primeModal(.addFavoritePrime):
//        value.favoritePrimes.append(value.count)
//        value.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(value.count)))
//
//    case .primeModal(.removeFavoritePrime):
//        value.favoritePrimes.removeAll(where: { $0 == value.count })
//        value.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(value.count)))
//
//    case let .favoritePrimes(.removeFavoritePrimes(indexSet)):
//        for index in indexSet {
//            let prime = value.favoritePrimes[index]
//            value.favoritePrimes.remove(at: index)
//            value.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
//        }
//    }
//}

// MARK: Combining reducers
// 두 개의 Reducer 동작을 하나의 Reducer로 결합
//func combine<Value, Action>(
//    _ first: @escaping (inout Value, Action) -> Void,
//    _ second: @escaping (inout Value, Action) -> Void
//) -> (inout Value, Action) -> Void {
//
//    return { value, action in
//        first(&value, action)
//        second(&value, action)
//    }
//}

// 다수의 Reducer 동작을 하나의 Reducer로 결합
func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {

    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
    }
}

// 큰 Reducer(appReducer)를 개별 Reducer로 분리해서 결합시킴
//let appReducer = combine(
//    counterReducer,
//    primeModalReducer,
//    favoritePrimesReducer
//)

// MARK: Focusing a reducer's state
// Reducer에서 AppState 전체를 알 필요가 x -> 필요한 부분(state.count)만 가지고 동작하도록 포커싱
// 근데 이렇게 하면 101번 줄 오류 발생 -> Cannot convert value of type 'Int' to expected argument type 'AppState'
// 이걸 해결하기 위한 방법: Pullback

//func counterReducer(state: inout AppState, action: AppAction) -> Void {
func counterReducer(count: inout Int, action: AppAction) -> Void {
    switch action {
    case .counter(.decreaseCount):
//        state.count -= 1
        count -= 1

    case .counter(.increaseCount):
//        state.count += 1
        count += 1

    default:
        break
    }
}

// primeModalReducer는 필요로 하는 AppState가 많기 때문에 포커싱 작업 x
func primeModalReducer(state: inout AppState, action: AppAction) -> Void {
    switch action {
    case .primeModal(.addFavoritePrime):
        state.favoritePrimes.append(state.count)
        state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))

    case .primeModal(.removeFavoritePrime):
        state.favoritePrimes.removeAll(where: { $0 == state.count })
        state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))

    default:
        break
    }
}

// MARK: Pulling back more reducers
// FavoritePrimesState 모델을 생성하고 Reducer 리팩토링
// 하지만 타입을 변경하면 오류 발생 -> Cannot convert value of type 'AppState' to expected argument type 'FavoritePrimesState'
//func favoritePrimesReducer(state: inout AppState, action: AppAction) -> Void {
func favoritePrimesReducer(state: inout FavoritePrimesState, action: AppAction) -> Void {
    switch action {
    case let .favoritePrimes(.removeFavoritePrimes(indexSet)):
        for index in indexSet {
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
            state.favoritePrimes.remove(at: index)
        }

    default:
        break
    }
}

// MARK: Pulling back reducers along state
// 글로벌 -> 로컬 값으로 참조하는 경로를 제공한 경우
// 로컬 값의 Reducer를 글로벌 값의 Reducer로 변환 할 수 있음

//func pullback<LocalValue, GlobalValue, Action>(
//    _ reducer: @escaping (inout LocalValue, Action) -> Void,
//    _ f: @escaping (GlobalValue) -> LocalValue /* 글로벌 -> 로컬 값으로 이동 */
//) -> (inout GlobalValue, Action) -> Void {
//
//    return  { globalValue, action in
//        var localValue = f(globalValue)
//        reducer(&localValue, action)
//    }
//}

// 위는 로컬 값의 복사본을 만든 다음 Reducer를 사용하여 변경하지만, 원본에는 아무 작업도하지 않음
// -> 글로벌 값이 전혀 변경되지 않으므로 Reducer를 적용해도 값이 변하지 않음

//func pullback<LocalValue, GlobalValue, Action>(
//    _ reducer: @escaping (inout LocalValue, Action) -> Void,
//    get: @escaping (GlobalValue) -> LocalValue,
//    set: @escaping (inout GlobalValue, LocalValue) -> Void
//) -> (inout GlobalValue, Action) -> Void {
//
//    return  { globalValue, action in
//        var localValue = get(globalValue)
//        reducer(&localValue, action)
//        set(&globalValue, localValue) // 원본 값 세팅
//    }
//}
//
//let appReducer = combine(
//    pullback(counterReducer, get: { $0.count }, set: { $0.count = $1 }),
//    primeModalReducer,
//    pullback(favoritePrimesReducer, get: { $0 }, set: { $0 = $1 })
//)

// MARK: Key path pullbacks
// getter/setter 쌍을 하나로 묶는 방법 -> KeyPath

func pullback<LocalValue, GlobalValue, Action>(
    _ reducer: @escaping (inout LocalValue, Action) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue>
) -> (inout GlobalValue, Action) -> Void {
    return { globalValue, action in
        reducer(&globalValue[keyPath: value], action)
    }
}

let _appReducer = combine(
    pullback(counterReducer, value: \.count),
    primeModalReducer,
    pullback(favoritePrimesReducer, value: \.favoritePrimesState)
)
let appReducer = pullback(_appReducer, value: \.self)
