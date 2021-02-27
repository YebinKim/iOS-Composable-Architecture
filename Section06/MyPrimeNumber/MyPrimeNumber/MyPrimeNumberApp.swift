//
//  MyPrimeNumberApp.swift
//  MyPrimeNumber
//
//  Created by Yebin Kim on 2020/10/02.
//

import SwiftUI
import Counter
import ComposableArchitecture

@main
struct MyPrimeNumberApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialValue: AppState(), reducer: appReducer, environment:  AppEnvironment(fileClient: .live, nthPrime: Counter.nthPrime)))
        }
    }
}
