import PlaygroundSupport
import SwiftUI
import ComposableArchitecture
@testable import FavoritePrimes

// MARK: Testable State Management: Effects - Controlling the favorite primes save and load effect
Current = .mock

Current.fileClient.load = { _ in
    Effect.sync { try! JSONEncoder().encode(Array(1...1000)) }
}

PlaygroundPage.current.liveView = UIHostingController(
    rootView: NavigationView {
        FavoritePrimesView(
            store: Store<[Int], FavoritePrimesAction>(
                initialValue: [2, 3, 5, 7, 11],
                reducer: favoritePrimesReducer
            )
        )
    }
)
