//
//  CounterView_iOS.swift
//  Counter
//
//  Created by Yebin Kim on 2021/04/03.
//

#if os(iOS)
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
        let isPrimeModalShown: Bool
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
        case primeModalDismissed
        case doubleTap
    }

    let store: Store<CounterFeatureState, CounterFeatureAction>
    @ObservedObject var viewStore: ViewStore<State, Action>

    public init(store: Store<CounterFeatureState, CounterFeatureAction>) {
        self.store = store
        self.viewStore = self.store
            .scope(
                value: State.init,
                action: CounterFeatureAction.init
            )
            .view
    }

    public var body: some View {
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
        .font(.title)
        .navigationBarTitle("Counter demo")
        .sheet(
            isPresented: .constant(self.viewStore.isPrimeModalShown),
            onDismiss: { self.viewStore.send(.primeModalDismissed) }
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
                // MARK: Ergonomic State Management: Part 2 - Bindings and the architecture
                title: Text("The \(ordinal(self.viewStore.count)) prime is \(alert.prime)")
//                title: Text("The \(ordinal(self.viewStore.count)) prime is \(alert.prime)"),
//                dismissButton: .default(Text("Ok")) {
//                    self.viewStore.send(.alertDismissButtonTapped)
//                }
            )
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity
        )
        .background(Color.clear)
        .onTapGesture(count: 2) {
            self.viewStore.send(.doubleTap)
        }
    }

    private func nthPrimeButtonAction() {
        self.viewStore.send(.doubleTap)
    }
}

extension CounterView.State {
    init(counterFeatureState: CounterFeatureState) {
        self.alertNthPrime = counterFeatureState.alertNthPrime
        self.count = counterFeatureState.count
        self.isNthPrimeButtonDisabled = counterFeatureState.isNthPrimeButtonDisabled
        self.isPrimeModalShown = counterFeatureState.isPrimeDetailShown
        self.isIncrementButtonDisabled = counterFeatureState.isNthPrimeButtonDisabled
        self.isDecrementButtonDisabled = counterFeatureState.isNthPrimeButtonDisabled
        self.nthPrimeButtonTitle = "What is the \(ordinal(counterFeatureState.count)) prime?"
    }
}

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
        case .primeModalDismissed:
            self = .counter(.primeModalDismissed)
        case .doubleTap:
            self = .counter(.requestNthPrime)
        }
    }
}
#endif
