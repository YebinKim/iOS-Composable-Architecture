//
//  Counter.swift
//  Counter
//
//  Created by Yebin Kim on 2020/11/01.
//
// MARK: Reducer 모듈화: Modularizing the counter reducer

// 앱 액션 모델
public enum CounterAction {
    case decreaseCount
    case increaseCount
}

// MARK: - Reducers
// 앱의 기능 별 로직을 구현한 Reducer
public func counterReducer(count: inout Int, action: CounterAction) -> Void {
    switch action {
    case .decreaseCount:
        count -= 1

    case .increaseCount:
        count += 1
    }
}
