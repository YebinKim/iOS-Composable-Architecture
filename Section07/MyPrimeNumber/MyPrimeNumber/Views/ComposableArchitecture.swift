//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by Yebin Kim on 2020/11/01.
//

import Combine
import CasePaths

public typealias Reducer<Value, Action, Environment> = (inout Value, Action, Environment) -> [Effect<Action>]

// MARK: - Utils
// 여러개의 Reducer를 결합시키는 역할을 하는 combine 메서드
public func combine<Value, Action, Environment>(
    _ reducers: Reducer<Value, Action, Environment>...
) -> Reducer<Value, Action, Environment> {
    return { value, action, environment in
        let effects = reducers.flatMap { $0(&value, action, environment) }
        return effects
    }
}

// combine과 pullback을 사용함으로써 Reducer가 세부 속성으로 포커싱될 수 있게 만듬
// LocalValue를 GlobalValue로 변환시키는 역할을 하는 pullback 메서드
public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction, LocalEnvironment, GlobalEnvironment>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction, LocalEnvironment>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: CasePath<GlobalAction, LocalAction>,
    environment: @escaping (GlobalEnvironment) -> LocalEnvironment
) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
    return { globalValue, globalAction, globalEnvironment in
        guard let localAction = action.extract(from: globalAction) else { return [] }
        let localEffects = reducer(&globalValue[keyPath: value], localAction, environment(globalEnvironment))

        return localEffects.map { localEffect in
            localEffect.map(action.embed)
                .eraseToEffect()
        }
    }
}

public func logging<Value, Action, Environment>(
    _ reducer: @escaping Reducer<Value, Action, Environment>
) -> Reducer<Value, Action, Environment> {
    return { value, action, environment in
        let effects = reducer(&value, action, environment)
        let newValue = value
        return [.fireAndForget {
            print("Action: \(action)")
            print("Value:")
            dump(newValue)
            print("---")
        }] + effects
    }
}

// MARK: Library
// 앱 아키텍처를 지원하는 핵심 라이브러리
// 앱 상태 및 액션을 변경할 수 있는 유일한 컨테이너
public final class Store<Value, Action> /*: ObservableObject*/ {

    private let reducer: Reducer<Value, Action, Any>
    private let environment: Any
    // MARK: State - View models and view stores
    @Published private var value: Value
    private var viewCancellable: Cancellable?
    private var effectCancellables: Set<AnyCancellable> = []

    public init<Environment>(
        initialValue: Value,
        reducer: @escaping Reducer<Value, Action, Environment>,
        environment: Environment
    ) {
        self.reducer = { value, action, environment in
            reducer(&value, action, environment as! Environment)
        }
        self.value = initialValue
        self.environment = environment
    }

    public func send(_ action: Action) {
        let effects = self.reducer(&self.value, action, self.environment)
        effects.forEach { effect in
            var effectCancellable: AnyCancellable?
            var didComplete = false
            effectCancellable = effect.sink(
                // MARK: Performance - Fixing a couple memory leaks
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

    // MARK: State - View models and view stores
//    public func view<LocalValue, LocalAction>(
    public func scope<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(self.value),
            reducer: { localValue, localAction, _ in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
            },
            environment: self.environment
        )
        // MARK: Performance - View.init/body: analysis
        localStore.viewCancellable = self.$value
            .map(toLocalValue)
//            .removeDuplicates()
            .sink { [weak localStore] newValue in localStore?.value = newValue }
        return localStore
    }
}

// MARK: State - View models and view stores
public final class ViewStore<Value>: ObservableObject {

    @Published public fileprivate(set) var value: Value
    fileprivate var cancellable: Cancellable?

    init(initialValue: Value) {
        self.value = initialValue
    }
}

extension Store {

//    var view: ViewStore<Value> {
    // MARK: State - View store performance
    public func view(
        removeDuplicates predicate: @escaping (Value, Value) -> Bool
    ) -> ViewStore<Value> {

        let viewStore = ViewStore(initialValue: self.value)

//        viewStore.cancellable = self.$value.sink(receiveValue: { value in
//            viewStore.value = value
//        })
        // MARK: State - View store performance
//        viewStore.cancellable = self.$value
//            .removeDuplicates()
//            .sink(receiveValue: { value in
//                viewStore.value = value
//            })
        viewStore.cancellable = self.$value
            .removeDuplicates(by: predicate)
            .sink { [weak viewStore] newValue in
                viewStore?.value = newValue
            }


        return viewStore
    }
}

// MARK: State - View store performance
extension Store where Value: Equatable {
    public var view: ViewStore<Value> {
        self.view(removeDuplicates: ==)
    }
}
