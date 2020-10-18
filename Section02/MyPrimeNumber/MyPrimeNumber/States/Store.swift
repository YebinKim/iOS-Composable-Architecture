//
//  Store.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import Foundation

// MARK: 글로벌 상태를 모델링하는 더 나은 방법
// 제네릭 타입으로 래퍼 클래스 생성
//final class Store<Value>: ObservableObject {
//
//    @Published var value: Value
//
//    init(initialValue: Value) {
//        self.value = initialValue
//    }
//}

// MARK: Ergonomics: Store 내부에서 Reducer 캡처
final class Store<Value, Action>: ObservableObject {

//    let reducer: (Value, Action) -> Value
    // MARK: Ergonomics: in-out Reducers
    let reducer: (inout Value, Action) -> Void

//    @Published var value: Value
    // 앱 상태를 변경하기 위해서는 반드시 Store를 통과하도록 강제할 수 있게 됨
    // send(_:)를 통해서만 상태 변경 가능
    @Published private(set) var value: Value

//    init(initialValue: Value, reducer: @escaping (Value, Action) -> Value) {
//        self.value = initialValue
//        self.reducer = reducer
//    }
    // MARK: Ergonomics: in-out Reducers
    init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.value = initialValue
        self.reducer = reducer
    }

//    func send(_ action: Action) {
//        self.value = self.reducer(self.value, action)
//    }
    // MARK: Ergonomics: in-out Reducers
    func send(_ action: Action) {
        self.reducer(&self.value, action)
    }
}
