import PlaygroundSupport
import SwiftUI
import ComposableArchitecture
@testable import Counter

var environment: FavoritePrimesEnvironment = (
    fileClient: .mock,
    nthPrime: { _ in .sync { 17 } }
)
environment.fileClient.load = { _ in
    Effect.sync { try! JSONEncoder().encode(Array(1...10)) }
}

PlaygroundPage.current.liveView = UIHostingController(
    rootView: NavigationView {
        FavoritePrimesView(
            store: Store<FavoritePrimesState, FavoritePrimesAction>(
                initialValue: (
                    alertNthPrime: nil,
                    favoritePrimes: [2, 3, 5, 7, 11]
                ),
                reducer: favoritePrimesReducer,
                environment: environment
            )
        )
    }
)
