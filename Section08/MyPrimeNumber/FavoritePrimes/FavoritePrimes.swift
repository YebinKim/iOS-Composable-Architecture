//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Yebin Kim on 2020/11/01.
//

import ComposableArchitecture
import PrimeAlert
import SwiftUI
import Combine

public enum FavoritePrimesAction: Equatable {
    case removeFavoritePrimes(IndexSet)
    case loadedFavoritePrimes([Int])
    case saveButtonTapped
    case loadButtonTapped
    case primeButtonTapped(Int)
    case nthPrimeResponse(n: Int, prime: Int?)
    case alertDismissButtonTapped

}

public typealias FavoritePrimesState = (
    alertNthPrime: PrimeAlert?,
    favoritePrimes: [Int]
)

// MARK: Ergonomic State Management: Part 1 - Updating the app's modules
//public func favoritePrimesReducer(
//    state: inout FavoritePrimesState,
//    action: FavoritePrimesAction,
//    environment: FavoritePrimesEnvironment
//) -> [Effect<FavoritePrimesAction>] {
public let favoritePrimesReducer = Reducer<FavoritePrimesState, FavoritePrimesAction, FavoritePrimesEnvironment> { state, action, environment in
    switch action {
    case let .removeFavoritePrimes(indexSet):
        for index in indexSet {
            state.favoritePrimes.remove(at: index)
        }
        return []

    case let .loadedFavoritePrimes(favoritePrimes):
        state.favoritePrimes = favoritePrimes
        return []

    case .saveButtonTapped:
        let state = state
        return [
            environment.fileClient.save("favorite-primes.json", try! JSONEncoder().encode(state.favoritePrimes))
              .fireAndForget()
        ]

    case .loadButtonTapped:
        return [
            environment.fileClient.load("favorite-primes.json")
                .compactMap { $0 }
                .decode(type: [Int].self, decoder: JSONDecoder())
                .catch { _ in Empty(completeImmediately: true) }
                .map(FavoritePrimesAction.loadedFavoritePrimes)
                .eraseToEffect()
        ]

    case .primeButtonTapped(let n):
        return [
            environment.nthPrime(n)
                .map { FavoritePrimesAction.nthPrimeResponse(n: n, prime: $0) }
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        ]

    case .nthPrimeResponse(let n, let prime):
        state.alertNthPrime = prime.map { PrimeAlert(n: n, prime: $0) }
        return []

    case .alertDismissButtonTapped:
        state.alertNthPrime = nil
        return []

    }
}

public struct FavoritePrimesView: View {

    let store: Store<FavoritePrimesState, FavoritePrimesAction>
    @ObservedObject var viewStore: ViewStore<FavoritePrimesState, FavoritePrimesAction>

    public init(store: Store<FavoritePrimesState, FavoritePrimesAction>) {
        self.store = store
        self.viewStore = self.store.view(removeDuplicates: ==)
    }

    public var body: some View {
        return List {
            ForEach(self.viewStore.value.favoritePrimes, id: \.self) { prime in
                Button("\(prime)") {
                    self.viewStore.send(.primeButtonTapped(prime))
                }
            }
            .onDelete { indexSet in
                self.viewStore.send(.removeFavoritePrimes(indexSet))
            }
        }
        .navigationBarTitle("Favorite primes")
        .navigationBarItems(
            trailing: HStack {
                Button("Save") {
                    self.viewStore.send(.saveButtonTapped)
                }
                Button("Load") {
                    self.viewStore.send(.loadButtonTapped)
                }
            }
        )
        .alert(
            // MARK: Ergonomic State Management: Part 2 - Binding helpers
//            item: .constant(self.viewStore.value.alertNthPrime)
            item: self.viewStore.binding(
                get: \.alertNthPrime,
                send: .alertDismissButtonTapped
                )
        ) { primeAlert in
            Alert(title: Text(primeAlert.title), dismissButton: Alert.Button.default(Text("Ok"), action: {
                self.viewStore.send(.alertDismissButtonTapped)
            }))
        }
    }
}

public typealias FavoritePrimesEnvironment = (
    fileClient: FileClient,
    nthPrime: (Int) -> Effect<Int?>
)

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
