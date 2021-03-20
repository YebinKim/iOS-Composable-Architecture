//
//  CounterTests.swift
//  CounterTests
//
//  Created by Yebin Kim on 2021/01/16.
//

import XCTest
@testable import Counter

class CounterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Current = .mock
    }

    func testIncrButtonTapped() {
        assert(
            initialValue: CounterViewState(count: 2),
            reducer: counterViewReducer,
            steps:
            Step(.send, .counter(.increaseCount), { $0.count = 3 }),
            Step(.send, .counter(.increaseCount), { $0.count = 4 }),
            Step(.send, .counter(.decreaseCount), { $0.count = 3 })
        )
    }

    func testDecrButtonTapped() {
        var state = CounterViewState(count: 2)
        var expected = state
        let effects = counterViewReducer

        expected.count = 1
        XCTAssertEqual(state, expected)
        XCTAssertTrue(effects.isEmpty)
    }

    // MARK: Testable State Management: Reducers - Unhappy paths and integration tests
    func testNthPrimeButtonHappyFlow() {

        // MARK: Testable State Management: Ergonomics - Actions sent and actions received
        Current.nthPrime = { _ in .sync { 17 } }

        assert(
            initialValue: CounterViewState(
                alertNthPrime: nil,
                isNthPrimeButtonDisabled: false
            ),
            reducer: counterViewReducer,
            steps:
            Step(.send, .counter(.nthPrimeButtonTapped)) {
                $0.isNthPrimeButtonDisabled = true
            },
            Step(.receive, .counter(.nthPrimeResponse(17))) {
                $0.alertNthPrime = PrimeAlert(prime: 17)
                $0.isNthPrimeButtonDisabled = false
            },
            Step(.send, .counter(.alertDismissButtonTapped)) {
                $0.alertNthPrime = nil
            }
        )
    }

    func testNthPrimeButtonUnhappyFlow() {
        Current.nthPrime = { _ in .sync { nil } }

        assert(
            initialValue: CounterViewState(
                alertNthPrime: nil,
                count: 7,
                isNthPrimeButtonDisabled: false
            ),
            reducer: counterViewReducer,
            steps:
            Step(.send, .counter(.nthPrimeButtonTapped)) {
                $0.isNthPrimeButtonDisabled = true
            },
            Step(.receive, .counter(.nthPrimeResponse(n: 7, prime: nil))) {
                $0.isNthPrimeButtonDisabled = false
            }
        )
    }

    func testPrimeModal() {
        Current = .mock

        assert(
            initialValue: CounterViewState(
                count: 1,
                favoritePrimes: [3, 5]
            ),
            reducer: counterViewReducer,
            steps:
            Step(.send, .counter(.increaseCount)) {
                $0.count = 2
            },
            Step(.send, .primeModal(.saveFavoritePrimeTapped)) {
                $0.favoritePrimes = [3, 5, 2]
            },
            Step(.send, .primeModal(.removeFavoritePrimeTapped)) {
                $0.favoritePrimes = [3, 5]
            }
        )
    }
}
