//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Yebin Kim on 2020/11/01.
//
// MARK: Reducer 모듈화: Modularizing the favorite primes reducer

public enum FavoritePrimesAction {
    case removeFavoritePrimes(IndexSet)
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> Void {
    switch action {
    case let .removeFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
    }
}
