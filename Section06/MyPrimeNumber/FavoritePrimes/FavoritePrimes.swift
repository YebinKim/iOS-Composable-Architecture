//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Yebin Kim on 2020/11/01.
//

import ComposableArchitecture
import SwiftUI
import Combine

public enum FavoritePrimesAction: Equatable {
    case removeFavoritePrimes(IndexSet)
    case loadedFavoritePrimes([Int])
    case saveButtonTapped
    case loadButtonTapped
}

public func favoritePrimesReducer(
    state: inout [Int],
    action: FavoritePrimesAction,
    environment: FavoritePrimesEnvironment
) -> [Effect<FavoritePrimesAction>] {
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
        return [
            environment.save("favorite-primes.json", try! JSONEncoder().encode(state))
              .fireAndForget()
        ]

    case .loadButtonTapped:
        return [
            environment.load("favorite-primes.json")
                .compactMap { $0 }
                .decode(type: [Int].self, decoder: JSONDecoder())
                .catch { _ in Empty(completeImmediately: true) }
                .map(FavoritePrimesAction.loadedFavoritePrimes)
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

//public struct FavoritePrimesEnvironment {
//    var fileClient: FileClient
//}
//
//extension FavoritePrimesEnvironment {
//    static let live = FavoritePrimesEnvironment(fileClient: .live)
//}
//
//var Current = FavoritePrimesEnvironment.live
//
//#if DEBUG
//extension FavoritePrimesEnvironment {
//    static let mock = FavoritePrimesEnvironment(
//        fileClient: FileClient(
//            load: { _ in Effect<Data?>.sync {
//                try! JSONEncoder().encode([2, 31])
//            } },
//            save: { _, _ in .fireAndForget {} }
//        )
//    )
//}
//#endif

public typealias FavoritePrimesEnvironment = FileClient

public struct FileClient {
    var load: (String) -> Effect<Data?>
    var save: (String, Data) -> Effect<Never>
}

extension FileClient {
    public static let live = Self(
        load: { fileName in
            .sync {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentsUrl = URL(fileURLWithPath: documentsPath)
                let favoritePrimesUrl = documentsUrl.appendingPathComponent(fileName)
                return try? Data(contentsOf: favoritePrimesUrl)
            }
        },
        save: { fileName, data in
            .fireAndForget {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentsUrl = URL(fileURLWithPath: documentsPath)
                let favoritePrimesUrl = documentsUrl.appendingPathComponent(fileName)
                try! data.write(to: favoritePrimesUrl)
            }
        })
}

// (Never) -> A
func absurd<A>(_ never: Never) -> A {}

extension Publisher where Output == Never, Failure == Never {
    func fireAndForget<A>() -> Effect<A> {
        return self.map(absurd).eraseToEffect()
    }
}
