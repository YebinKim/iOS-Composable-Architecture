//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by Yebin Kim on 2020/11/01.
//

import Combine

// MARK: Synchronous Effects - Reducers as pure functions
//public typealias Reducer<Value, Action> = (inout Value, Action) -> Effect
// MARK: Synchronous Effects - Effects as values
//public typealias Effect = () -> Void
// MARK: Unidirectional Effects - Synchronous effects that produce results
//public typealias Effect<Action> = () -> Action?
// MARK: Unidirectional Effects - Combining multiple effects that produce results
public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]
// MARK: Asynchronous Effects - The async effect
//public typealias Effect<Action> = (@escaping (Action) -> Void) -> Void

// MARK: Library
// 앱 아키텍처를 지원하는 핵심 라이브러리
// 앱 상태 및 액션을 변경할 수 있는 유일한 컨테이너
public final class Store<Value, Action>: ObservableObject {
    
    private let reducer: Reducer<Value, Action>
    @Published public private(set) var value: Value
    private var cancellable: Cancellable?

    public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
        self.value = initialValue
        self.reducer = reducer
    }

    // MARK: Synchronous Effects - Updating our architecture for effects
    public func send(_ action: Action) {
//        self.reducer(&self.value, action)

//        let effect = self.reducer(&self.value, action)
//        effect()

        //  MARK: Asynchronous Effects - The async signature
        let effects = self.reducer(&self.value, action)
//        effects.forEach { effect in
//            if let action = effect() {
//                self.send(action)
//            }
//        }

//        DispatchQueue.global().async {
//            effects.forEach { effect in
//                if let action = effect() {
//                    DispatchQueue.main.async {
//                        self.send(action)
//                    }
//                }
//            }
//        }
        effects.forEach { effect in
//          effect(self.send)
            effect.run(self.send)
        }
    }

    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(self.value),
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
            }
        )
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        return localStore
    }
}

// MARK: - Utils
// combine과 pullback을 사용함으로써 Reducer가 세부 속성으로 포커싱될 수 있게 만듬
// LocalValue를 GlobalValue로 변환시키는 역할을 하는 pullback 메서드
public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {

    // MARK: Unidirectional Effects - Pulling local effects back globally
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        let localEffects = reducer(&globalValue[keyPath: value], localAction)

        return localEffects.map { localEffect in
            Effect { callback in
//        guard let localAction = localEffect() else { return nil }
                localEffect.run { localAction in
                    var globalAction = globalAction
                    globalAction[keyPath: action] = localAction
                    callback(globalAction)
                }
            }
        }

//    return effect
    }
}

// 여러개의 Reducer를 결합시키는 역할을 하는 combine 메서드
public func combine<Value, Action>(
    _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {

    return { value, action in
//        for reducer in reducers {
//            reducer(&value, action)
//        }

//        let effects = reducers.map { $0(&value, action) }
//        return {
//            for effect in effects {
//                effect()
//            }
//        }

        let effects = reducers.flatMap { $0(&value, action) }
        return effects
    }
}

public func logging<Value, Action>(
    _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducer(&value, action)
        let newValue = value
        return [Effect { _ in
            print("Action: \(action)")
            print("Value:")
            dump(newValue)
            print("---")
        }] + effects
    }
}

// MARK: The Point - Composable, transformable effects
public struct Effect<A> {

    public let run: (@escaping (A) -> Void) -> Void

    public init(run: @escaping (@escaping (A) -> Void) -> Void) {
        self.run = run
    }

    public func map<B>(_ transform: @escaping (A) -> B) -> Effect<B> {
        return Effect<B> { callback in
            self.run { callback(transform($0)) }
        }
    }

//    public func receive(on queue: DispatchQueue) -> Effect {
//        return Effect { callback in
//            self.run { a in queue.async { callback(a) }
//            }
//        }
//    }
}
