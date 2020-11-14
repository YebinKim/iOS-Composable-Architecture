//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by Yebin Kim on 2020/11/01.
//
// MARK: Reducer 모듈화: Modularizing the Composable Architecture

import Combine

// MARK: Library
// 앱 아키텍처를 지원하는 핵심 라이브러리
// 앱 상태 및 액션을 변경할 수 있는 유일한 컨테이너
public final class Store<Value, Action>: ObservableObject {
    // reducer는 private으로 선언
    private let reducer: (inout Value, Action) -> Void
    // value는 public으로 선언
    @Published public private(set) var value: Value
    // sink 매서드는 cancellable을 반환하므로 로컬 Store를 유지할 수 있도록 cancellable 프로퍼티 추가
    private var cancellable: Cancellable?

    public init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.value = initialValue
        self.reducer = reducer
    }

    public func send(_ action: Action) {
        self.reducer(&self.value, action)
    }

    // MARK: View State: Transforming a store's value
    //func __<LocalValue>(

    // __ 메서드는 map 과 동작이 유사하다
    // ((Value) -> LocalValue) -> ((Store<Value, _>) -> Store<LocalValue, _>
    // ((A) -> B) -> ((Store<A, _>) -> Store<B, _>)
    // ((A) -> B) -> ((F<A>) -> F<B>)
    // map: ((A) -> B) -> ((F<A>) -> F<B>)
    //func map<LocalValue>(

    // map을 view로 명명
//    public func view<LocalValue>(
//        _ f: @escaping (Value) -> LocalValue
//    ) -> Store<LocalValue, Action> {
//        let localStore = Store<LocalValue, Action>(
//            initialValue: f(self.value),
//            reducer: { localValue, action in
//                self.send(action)
//                localValue = f(self.value)
//            }
//        )
//        // MARK: View State: Propagating global changes locally
//        //self.$value.sink(receiveValue: <#((Value) -> Void)#>)
//        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
//            localStore?.value = f(newValue)
//        }
//        return localStore
//    }

    // MARK: View Actions: Transforming a store’s action
    //func __<LocalAction>(

    // __ 메서드는 pullback 과 동작이 유사하다
    // ((LocalAction) -> Action) -> ((Store<_, Action>) -> Store<_, LocalAction>)
    // ((B) -> A) -> ((Store<A, _>) -> Store<B, _>)
    // ((B) -> A) -> (F<A>) -> F<B>)
    // pullback: ((A) -> B) -> (F<B>) -> F<A>)
    // public func pullback<LocalAction>(

    // pullback을 view로 명명
//    public func view<LocalAction>(
//        f: @escaping (LocalAction) -> Action
//    ) -> Store<Value, LocalAction> {
//        return Store<Value, LocalAction>(
//            initialValue: self.value,
//            reducer: { value, localAction in
//                self.send(f(localAction))
//                value = self.value
//            }
//        )
//    }

    // MARK: View Actions: Combining view functions
    // view(map)과 view(pullback) 결합
    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(self.value),
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
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
    _ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return }
        reducer(&globalValue[keyPath: value], localAction)
    }
}

// 여러개의 Reducer를 결합시키는 역할을 하는 combine 메서드
public func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {

    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
    }
}

// MARK: - Higher-order logging
public func logging<Value, Action>(
    _ reducer: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
    return { value, action in
        reducer(&value, action)
        print("Action: \(action)")
        print("Value:")
        dump(value)
        print("---")
    }
}
