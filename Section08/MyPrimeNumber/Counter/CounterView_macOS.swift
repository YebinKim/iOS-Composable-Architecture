//
//  CounterView_macOS.swift
//  Counter
//
//  Created by Yebin Kim on 2021/04/03.
//

#if os(macOS)
import Combine
import ComposableArchitecture
import PrimeAlert
import PrimeModal
import SwiftUI

public struct CounterView: View {

    struct State: Equatable {
        let alertNthPrime: PrimeAlert?
        let count: Int
        let isNthPrimeButtonDisabled: Bool
        let isPrimePopoverShown: Bool
        let isIncrementButtonDisabled: Bool
        let isDecrementButtonDisabled: Bool
        let nthPrimeButtonTitle: String
    }

    enum Action {
        case decreaseCount
        case increaseCount
        case nthPrimeButtonTapped
        case alertDismissButtonTapped
        case isPrimeButtonTapped
        case primePopoverDismissed
    }

    let store: Store<CounterFeatureState, CounterFeatureAction>
    @ObservedObject var viewStore: ViewStore<State, Action>

    public init(store: Store<CounterFeatureState, CounterFeatureAction>) {
        print("CounterView.init")
        self.store = store
        self.viewStore = self.store
            .scope(
                value: State.init,
                action: CounterFeatureAction.init
            )
            .view
    }

    public var body: some View {
        print("CounterView.body")
        return VStack {
            HStack {
                Button("-") { self.viewStore.send(.decreaseCount) }
                    .disabled(self.viewStore.isDecrementButtonDisabled)

                Text("\(self.viewStore.count)")

                Button("+") { self.viewStore.send(.increaseCount) }
                    .disabled(self.viewStore.isIncrementButtonDisabled)
            }
            Button("Is this prime?") { self.viewStore.send(.isPrimeButtonTapped) }
            Button(self.viewStore.nthPrimeButtonTitle) {
                self.viewStore.send(.nthPrimeButtonTapped)
            }
            .disabled(self.viewStore.isNthPrimeButtonDisabled)
        }
        .popover(
            // MARK: Ergonomic State Management: Part 2 - Binding helpers
//            isPresented: Binding(
//                get: { self.viewStore.isPrimePopoverShown },
//                set: { _ in self.viewStore.send(.primePopoverDismissed) }
//            )
            isPresented: self.viewStore.binding(
                get: \.isPrimePopoverShown,
                self: .primePopoverDismissed
            )
        ) {
            IsPrimeModalView(
                store: self.store.scope(
                    value: { ($0.count, $0.favoritePrimes) },
                    action: { .primeModal($0) }
                )
            )
        }
        .alert(
          item: Binding.constant(self.viewStore.alertNthPrime)
        ) { alert in
            Alert(
                title: Text("The \(ordinal(self.viewStore.count)) prime is \(alert.prime)"),
                dismissButton: .default(Text("Ok")) {
                    self.viewStore.send(.alertDismissButtonTapped)
                }
            )
        }
    }
}

extension CounterView.State {
    init(counterFeatureState: CounterFeatureState) {
        self.alertNthPrime = counterFeatureState.alertNthPrime
        self.count = counterFeatureState.count
        self.isNthPrimeButtonDisabled = counterFeatureState.isNthPrimeButtonDisabled
        self.isPrimePopoverShown = counterFeatureState.isPrimeDetailShown
        self.isIncrementButtonDisabled = counterFeatureState.isNthPrimeButtonDisabled
        self.isDecrementButtonDisabled = counterFeatureState.isNthPrimeButtonDisabled
        // MARK: Action - View actions
        self.nthPrimeButtonTitle = "What is the \(ordinal(counterFeatureState.count)) prime?"
    }
}

// MARK: Action - Tests and the view store
extension CounterFeatureAction {
    init(action: CounterView.Action) {
        switch action {
        case .decreaseCount:
            self = .counter(.decreaseCount)
        case .increaseCount:
            self = .counter(.increaseCount)
        case .nthPrimeButtonTapped:
            self = .counter(.requestNthPrime)
        case .alertDismissButtonTapped:
            self = .counter(.alertDismissButtonTapped)
        case .isPrimeButtonTapped:
            self = .counter(.isPrimeButtonTapped)
        case .primePopoverDismissed:
            self = .counter(.primePopoverDismissed)
        case .doubleTap:
            self = .counter(.requestNthPrime)
        }
    }
}
#endif
