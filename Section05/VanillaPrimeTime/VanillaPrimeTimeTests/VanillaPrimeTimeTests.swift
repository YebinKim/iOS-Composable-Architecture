//
//  VanillaPrimeTimeTests.swift
//  VanillaPrimeTimeTests
//
//  Created by Yebin Kim on 2021/02/08.
//

import XCTest
import SwiftUI
@testable import VanillaPrimeTime

// MARK: Testing vanilla SwiftUI
class VanillaPrimeTimeTests: XCTestCase {

    // MARK: Testing the prime modal
    func testIsPrimeModalView() {
        let view = IsPrimeModalView(
            activityFeed: Binding<[AppState.Activity]>(initialValue: []),
            count: 2,
            favoritePrimes: Binding<[Int]>(initialValue: [2, 3, 5])
        )

        view.removeFavoritePrime()

        XCTAssertEqual(view.favoritePrimes, [3, 5])

        view.saveFavoritePrime()

        XCTAssertEqual(view.favoritePrimes, [3, 5, 2])
    }

    func testCounterView() {
        let view = CounterView(state: AppState())

        view.incrementCount()

        XCTAssertEqual(view.state.count, 1)

        view.incrementCount()

        XCTAssertEqual(view.state.count, 2)

        view.decrementCount()

        XCTAssertEqual(view.state.count, 1)

        XCTAssertEqual(view.state.isNthPrimeButtonDisabled, false)

        view.nthPrimeButtonAction()

        XCTAssertEqual(view.state.isNthPrimeButtonDisabled, true)
    }
}

extension Binding {
    init(initialValue: Value) {
        var value = initialValue
        self.init(get: { value }, set: { value = $0 })
    }
}
