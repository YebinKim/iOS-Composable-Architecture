//
//  CounterView_macOS.swift
//  Counter
//
//  Created by Yebin Kim on 2021/04/03.
//

// MARK: The Point - Dedicated platform SwiftUI views
#if os(macOS)
import Combine
import ComposableArchitecture
import PrimeAlert
import PrimeModal
import SwiftUI

public struct CounterView: View {

    // MARK: State - Counter view performance
    struct State: Equatable {
        let alertNthPrime: PrimeAlert?
        let count: Int
        let isNthPrimeButtonDisabled: Bool
        let isPrimePopoverShown: Bool

        // MARK: State - Adapting view stores
        let isIncrementButtonDisabled: Bool
        let isDecrementButtonDisabled: Bool

        // MARK: Action - View actions
        let nthPrimeButtonTitle: String
    }

    // MARK: Action - View actions
    enum Action {
        case decreaseCount
        case increaseCount
        case nthPrimeButtonTapped
        case alertDismissButtonTapped
        case isPrimeButtonTapped
        case primePopoverDismissed
//        case doubleTap
    }

//    @ObservedObject var store: Store<CounterViewState, CounterViewAction>
    // MARK: State - View store performance
    let store: Store<CounterFeatureState, CounterFeatureAction>
    @ObservedObject var viewStore: ViewStore<State, Action>

//    @State var isPrimeModalShown: Bool = false

    // MARK: Performance - View.init/body: tracking
    public init(store: Store<CounterFeatureState, CounterFeatureAction>) {
        print("CounterView.init")
        self.store = store
        self.viewStore = self.store
//            .scope(
//                value: State.init(counterFeatureState:),
//                // MARK: Action - View actions
//                action: {
//                    switch $0 {
//                    case .decreaseCount:
//                        return .counter(.decreaseCount)
//                    case .increaseCount:
//                        return .counter(.increaseCount)
//                    case .nthPrimeButtonTapped:
//                        return .counter(.requestNthPrime)
//                    case .alertDismissButtonTapped:
//                        return .counter(.alertDismissButtonTapped)
//                    case .isPrimeButtonTapped:
//                        return .counter(.isPrimeButtonTapped)
//                    case .primeModalDismissed:
//                        return .counter(.primeModalDismissed)
//                    case .doubleTap:
//                        return .counter(.requestNthPrime)
//                    }
//                }
//            )
            // MARK: Action - Tests and the view store
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
                    // MARK: State - Counter view performance
                    .disabled(self.viewStore.value.isDecrementButtonDisabled)

                Text("\(self.viewStore.value.count)")

                Button("+") { self.viewStore.send(.increaseCount) }
                    // MARK: State - Counter view performance
                    .disabled(self.viewStore.value.isIncrementButtonDisabled)
            }
            Button("Is this prime?") { self.viewStore.send(.isPrimeButtonTapped) }
            Button(self.viewStore.value.nthPrimeButtonTitle) {
                // MARK: Action - Action adaptation
//                self.store.send(.counter(.nthPrimeButtonTapped))
                self.viewStore.send(.nthPrimeButtonTapped)
            }
            .disabled(self.viewStore.value.isNthPrimeButtonDisabled)
        }
//        .font(.title)
//        .navigationBarTitle("Counter demo")
        .popover(
            isPresented: Binding(
                get: { self.viewStore.value.isPrimePopoverShown },
                set: { _ in self.viewStore.send(.primePopoverDismissed) }
            )
//            isPresented: .constant(self.viewStore.value.isPrimeModalShown),
//            onDismiss: { self.viewStore.send(.primeModalDismissed) }
        ) {
            IsPrimeModalView(
                store: self.store.scope(
                    value: { ($0.count, $0.favoritePrimes) },
                    action: { .primeModal($0) }
                )
            )
        }
        .alert(
          item: Binding.constant(self.viewStore.value.alertNthPrime)
        ) { alert in
            Alert(
                title: Text("The \(ordinal(self.viewStore.value.count)) prime is \(alert.prime)"),
                dismissButton: .default(Text("Ok")) {
                    self.viewStore.send(.alertDismissButtonTapped)
                }
            )
        }
        // MARK: Action - Action adaptation
//        .frame(
//            minWidth: 0,
//            maxWidth: .infinity,
//            minHeight: 0,
//            maxHeight: .infinity
//        )
//        .background(Color.clear)
//        .onTapGesture(count: 2) {
//            self.viewStore.send(.doubleTap)
//        }
    }

//    private func nthPrimeButtonAction() {
//        self.viewStore.send(.doubleTap)
//    }
}

// MARK: State - Counter view performance
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
