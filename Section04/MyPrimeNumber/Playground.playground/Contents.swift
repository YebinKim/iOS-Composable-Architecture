import ComposableArchitecture
import SwiftUI
import PlaygroundSupport

//import FavoritePrimes
//
//// MARK: FavoritePrimesView: 소수 목록 표시 테스트
//PlaygroundPage.current.liveView = UIHostingController(
//    rootView: FavoritePrimesView(
//        store: Store<[Int], FavoritePrimesAction>(
////            initialValue: [],
//            initialValue: [2, 3, 5, 7, 11],
//            reducer: favoritePrimesReducer
//        )
//    )
//)

//import PrimeModal
//
//// MARK: IsPrimeModalView:
//PlaygroundPage.current.liveView = UIHostingController(
//    rootView: IsPrimeModalView(
//        store: Store<PrimeModalState, PrimeModalAction>(
////            initialValue: (0, []),
////            initialValue: (2, []),
//            initialValue: (2, [2, 3, 5]),
//            reducer: primeModalReducer
//        )
//    ).frame(width: 350, height: 670, alignment: .center)
//)

import Counter

PlaygroundPage.current.liveView = UIHostingController(
    rootView: CounterView(
        store: Store<CounterViewState, CounterViewAction>(
//            initialValue: (0, []),
            initialValue: (1_000_000, []),
            reducer: counterViewReducer
        )
    ).frame(width: 350, height: 670, alignment: .center)
)
