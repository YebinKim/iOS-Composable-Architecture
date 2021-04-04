//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by Yebin Kim on 2020/11/01.
//

import Combine
import CasePaths

// MARK: Ergonomic State Management: Part 1 - Free functions
// (inout RandomNumberGenerator) -> A
struct Gen<A> {
    let run: (inout RandomNumberGenerator) -> A
}

// (inout Substring) -> A?
struct Parser<A> {
    let run: (inout Substring) -> A?
}

// (@escaping (A) -> Void) -> Void
//struct Effect<A> {
//    let run: (@escaping (A) -> Void) -> Void
//}

// MARK: Ergonomic State Management: Part 1 - Reducer as a struct
//public typealias Reducer<Value, Action, Environment> = (inout Value, Action, Environment) -> [Effect<Action>]
public struct Reducer<Value, Action, Environment> {

    let reducer: (inout Value, Action, Environment) -> [Effect<Action>]

    public init(_ reducer: @escaping (inout Value, Action, Environment) -> [Effect<Action>]) {
        self.reducer = reducer
    }
}

extension Reducer {
    // MARK: - Utils
    // 여러개의 Reducer를 결합시키는 역할을 하는 combine 메서드
//    public func combine<Value, Action, Environment>(
//        _ reducers: Reducer<Value, Action, Environment>...
//    ) -> Reducer<Value, Action, Environment> {
//        return { value, action, environment in
//            let effects = reducers.flatMap { $0(&value, action, environment) }
//            return effects
//        }
//    }
    public func combine<Value, Action, Environment>(
        _ reducers: Reducer<Value, Action, Environment>...
    ) -> Reducer<Value, Action, Environment> {
        return .init { value, action, environment in
            let effects = reducers.flatMap { $0(&value, action, environment) }
            return effects
        }
    }

    // combine과 pullback을 사용함으로써 Reducer가 세부 속성으로 포커싱될 수 있게 만듬
    // LocalValue를 GlobalValue로 변환시키는 역할을 하는 pullback 메서드
//    public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction, LocalEnvironment, GlobalEnvironment>(
//        _ reducer: @escaping Reducer<LocalValue, LocalAction, LocalEnvironment>,
//        value: WritableKeyPath<GlobalValue, LocalValue>,
//        action: CasePath<GlobalAction, LocalAction>,
//        environment: @escaping (GlobalEnvironment) -> LocalEnvironment
//    ) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
//        return { globalValue, globalAction, globalEnvironment in
//            guard let localAction = action.extract(from: globalAction) else { return [] }
//            let localEffects = reducer(&globalValue[keyPath: value], localAction, environment(globalEnvironment))
//
//            return localEffects.map { localEffect in
//                localEffect.map(action.embed)
//                    .eraseToEffect()
//            }
//        }
//    }
    public func pullback<GlobalValue, GlobalAction, GlobalEnvironment>(
        value: WritableKeyPath<GlobalValue, Value>,
        action: CasePath<GlobalAction, Action>,
        environment: @escaping (GlobalEnvironment) -> Environment
    ) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
        return .init { globalValue, globalAction, globalEnvironment in
            guard let localAction = action.extract(from: globalAction) else { return [] }
            let localEffects = self(&globalValue[keyPath: value], localAction, environment(globalEnvironment))

            return localEffects.map { localEffect in
                localEffect.map(action.embed)
                    .eraseToEffect()
            }
        }
    }

//    public func logging<Value, Action, Environment>(
//        _ reducer: @escaping Reducer<Value, Action, Environment>
//    ) -> Reducer<Value, Action, Environment> {
//        return { value, action, environment in
//            let effects = reducer(&value, action, environment)
//            let newValue = value
//            return [.fireAndForget {
//                print("Action: \(action)")
//                print("Value:")
//                dump(newValue)
//                print("---")
//            }] + effects
//        }
//    }
    // MARK: Ergonomic State Management: Part 1 - Reducer methods
    public func logging(
        printer: @escaping (Environment) -> (String) -> Void = { _ in { print($0) } }
    ) -> Reducer {
        .init { value, action, environment in
            let effects = self(&value, action, environment)
            let newValue = value
            let print = printer(environment)
            return [.fireAndForget {
                print("Action: \(action)")
                print("Value:")
                var dumpedNewValue = ""
                dump(newValue, to: &dumpedNewValue)
                print(dumpedNewValue)
                print("---")
            }] + effects
        }
    }

    public func callAsFunction(
        _ value: inout Value,
        _ action: Action,
        _ environment: Environment
    ) -> [Effect<Action>] {
        self.reducer(&value, action, environment)
    }
}

// MARK: Library
// 앱 아키텍처를 지원하는 핵심 라이브러리
// 앱 상태 및 액션을 변경할 수 있는 유일한 컨테이너
public final class Store<Value, Action> {

    private let reducer: Reducer<Value, Action, Any>
    private let environment: Any
    @Published private var value: Value
    private var viewCancellable: Cancellable?
    private var effectCancellables: Set<AnyCancellable> = []

    public init<Environment>(
        initialValue: Value,
        // MARK: Ergonomic State Management: Part 1 - Reducer as a struct
//        reducer: @escaping Reducer<Value, Action, Environment>,
        reducer: Reducer<Value, Action, Environment>,
        environment: Environment
    ) {
        self.reducer = .init { value, action, environment in
            reducer(&value, action, environment as! Environment)
        }
        self.value = initialValue
        self.environment = environment
    }

    private func send(_ action: Action) {
        let effects = self.reducer(&self.value, action, self.environment)
        effects.forEach { effect in
            var effectCancellable: AnyCancellable?
            var didComplete = false
            effectCancellable = effect.sink(
                receiveCompletion: { [weak self, weak effectCancellable] _ in
                    didComplete = true
                    guard let effectCancellable = effectCancellable else { return }
                    self?.effectCancellables.remove(effectCancellable)
                },
                receiveValue: { [weak self] in self?.send($0) }
            )
            if !didComplete, let effectCancellable = effectCancellable {
                self.effectCancellables.insert(effectCancellable)
            }
        }
    }

    public func scope<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(self.value),
            reducer: .init { localValue, localAction, _ in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
            },
            environment: self.environment
        )
        localStore.viewCancellable = self.$value
            .map(toLocalValue)
            .sink { [weak localStore] newValue in localStore?.value = newValue }
        return localStore
    }
}

public final class ViewStore<Value, Action>: ObservableObject {

    @Published public fileprivate(set) var value: Value
    fileprivate var cancellable: Cancellable?

    public let send: (Action) -> Void

    init(
        initialValue: Value,
        send: @escaping (Action) -> Void
    ) {
        self.value = initialValue
        self.send = send
    }
}

extension Store {

    public func view(
        removeDuplicates predicate: @escaping (Value, Value) -> Bool
    ) -> ViewStore<Value, Action> {

        let viewStore = ViewStore(
            initialValue: self.value,
            send: self.send
        )

        viewStore.cancellable = self.$value
            .removeDuplicates(by: predicate)
            .sink { [weak viewStore] newValue in
                viewStore?.value = newValue
            }


        return viewStore
    }
}

extension Store where Value: Equatable {
    public var view: ViewStore<Value, Action> {
        self.view(removeDuplicates: ==)
    }
}
