//
//  Store.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import Foundation

final class Store<Value, Action>: ObservableObject {

    let reducer: (inout Value, Action) -> Void
    @Published private(set) var value: Value

    init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.value = initialValue
        self.reducer = reducer
    }

    func send(_ action: Action) {
        self.reducer(&self.value, action)
    }
}
