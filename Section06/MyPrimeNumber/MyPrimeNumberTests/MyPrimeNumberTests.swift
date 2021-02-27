//
//  MyPrimeNumberTests.swift
//  MyPrimeNumberTests
//
//  Created by Yebin Kim on 2021/02/22.
//

import XCTest
@testable import PrimeTime
import ComposableArchitecture
@testable import Counter
@testable import FavoritePrimes
@testable import PrimeModal

// MARK: Dependency Injection Made Composable - Current problems
class MyPrimeNumberTests: XCTestCase {
    
    func testIntegration() {
        Counter.Current = .mock
        FavoritePrimes.Current = .mock
    }
}
