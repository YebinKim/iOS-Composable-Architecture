//
//  Logger.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/25.
//

import Foundation

// MARK: Higher-order logging
func logger<Value, Action>(
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
