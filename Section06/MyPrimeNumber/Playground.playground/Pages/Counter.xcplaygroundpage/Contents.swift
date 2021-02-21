import PlaygroundSupport
import SwiftUI
import ComposableArchitecture
@testable import Counter

// MARK: Testable State Management: Effects - Controlling the counter effect
Current = .mock

Current.nthPrime = { _ in .sync { 7236893748932 }}

PlaygroundPage.current.liveView = UIHostingController(
    rootView: CounterView(
        store: Store<CounterViewState, CounterViewAction>(
            initialValue: CounterViewState(
                alertNthPrime: nil,
                count: 0,
                favoritePrimes: [],
                isNthPrimeButtonDisabled: false
            ),
            reducer: logging(counterViewReducer)
        )
    )
)
