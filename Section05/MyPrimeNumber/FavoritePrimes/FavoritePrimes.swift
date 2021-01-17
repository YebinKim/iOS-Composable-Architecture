//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Yebin Kim on 2020/11/01.
//

import ComposableArchitecture
import SwiftUI

public enum FavoritePrimesAction: Equatable {
    case removeFavoritePrimes(IndexSet)
    case loadedFavoritePrimes([Int])
    case saveButtonTapped
    case loadButtonTapped
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> [Effect<FavoritePrimesAction>] {
    switch action {
    case let .removeFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
        return []

    case let .loadedFavoritePrimes(favoritePrimes):
        state = favoritePrimes
        return []

    case .saveButtonTapped:
        let state = state
        return [saveEffect(favoritePrimes: state)]

    case .loadButtonTapped:
        return [
            loadEffect
                .compactMap { $0 }
                .eraseToEffect()
        ]
    }
}

public struct FavoritePrimesView: View {

    @ObservedObject var store: Store<[Int], FavoritePrimesAction>

    public init(store: Store<[Int], FavoritePrimesAction>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(self.store.value, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                self.store.send(.removeFavoritePrimes(indexSet))
            }
        }
        .navigationBarTitle("Favorite Primes")
        .navigationBarItems(
            trailing: HStack {
                Button("Save to disk") {
                    self.store.send(.saveButtonTapped)
                }
                Button("Load") {
                    self.store.send(.loadButtonTapped)
                }
            }
        )
    }
}

private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
    return .fireAndForget {
        let data = try! JSONEncoder().encode(favoritePrimes)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsUrl = URL(fileURLWithPath: documentsPath)
        let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
        try! data.write(to: favoritePrimesUrl)
    }
}

private let loadEffect = Effect<FavoritePrimesAction?>.sync {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let documentsUrl = URL(fileURLWithPath: documentsPath)
    let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
    guard
        let data = try? Data(contentsOf: favoritePrimesUrl),
        let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
    else { return nil }
    return .loadedFavoritePrimes(favoritePrimes)
}

import Combine

extension Effect {
    static func sync(work: @escaping () -> Output) -> Effect {
        return Deferred {
            Just(work())
        }.eraseToEffect()
    }
}
