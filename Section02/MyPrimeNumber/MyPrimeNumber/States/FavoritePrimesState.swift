//
//  FavoritePrimesState.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/11.
//

import Foundation

// MARK: Pulling back more reducers
// 변경의 여지가 있다는 점에서 struct가 더 활용성이 높다
// 네이밍을 강제할 수 있다는 점에서 혼란을 줄일 수 있다
// 튜플에 들어가는 개수가 많아지면 가독성이 떨어질 수 있다
// 튜플은 자동완성이 잘 안 된다
struct FavoritePrimesState {
    var favoritePrimes: [Int]
    var activityFeed: [AppState.Activity]
}

//typealias FavoritePrimesState = (favoritePrimes: [Int] , activityFeed: [AppState.Activity])
