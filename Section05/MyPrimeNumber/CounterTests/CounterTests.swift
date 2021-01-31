//
//  CounterTests.swift
//  CounterTests
//
//  Created by Yebin Kim on 2021/01/16.
//

import XCTest
@testable import Counter
import ComposableArchitecture
import Combine

// MARK: Testable State Management: Ergonomics - The shape of a test
func assert<Value: Equatable, Action: Equatable>(
    initialValue: Value,
    reducer: Reducer<Value, Action>,
    // MARK: Testable State Management: Ergonomics - Improving test feedback
//    steps: (action: Action, update: (inout Value) -> Void)...,
    steps: Step<Value, Action>...,
    file: StaticString = #file,
    line: UInt = #line
) {
    var state = initialValue
    var effects: [Effect<Action>] = []
    var cancellables: [AnyCancellable] = []

    steps.forEach { step in
        var expected = state
//        _ = reducer(&state, step.action)

        // MARK: Testable State Management: Ergonomics - Actions sent and actions received
        switch step.type {
        case .send:
            // MARK: Testable State Management: Ergonomics - Assertion edge cases
            if !effects.isEmpty {
                XCTFail(
                    "Assertion failed to handle \(effects.count) pending effect(s)",
                    file: file,
                    line: line
                )
            }
            effects.append(contentsOf: reducer(&state, step.action))

        case .receive:
            // MARK: Testable State Management: Ergonomics - Assertion edge cases
            guard !effects.isEmpty else {
                XCTFail(
                    "No pending effects to receive from",
                    file: step.file,
                    line: step.line
                )
                break
            }
            let effect = effects.removeFirst()
            var action: Action!
            let receivedCompletion = XCTestExpectation(description: "receivedCompletion")
            cancellables.append(
                effect.sink(
                    receiveCompletion: { _ in
                        receivedCompletion.fulfill()
                    },
                    receiveValue: { action = $0 }
                )
            )
            if XCTWaiter.wait(for: [receivedCompletion], timeout: 0.01) != .completed {
                XCTFail("Timed out waiting for the effect to complete", file: step.file, line: step.line)
            }
            XCTAssertEqual(action, step.action, file: step.file, line: step.line)
            effects.append(contentsOf: reducer(&state, action))
        }

        step.update(&expected)
        XCTAssertEqual(state, expected, file: step.file, line: step.line)
    }
}

// MARK: Testable State Management: Ergonomics - Improving test feedback
struct Step<Value, Action> {
    let type: StepType
    let action: Action
    let update: (inout Value) -> Void
    let file: StaticString
    let line: UInt

    init(
        _ type: StepType,
        _ action: Action,
        file: StaticString = #file,
        line: UInt = #line,
        // MARK: Testable State Management: Ergonomics - Trailing closure ergonomics
        _ update: @escaping (inout Value) -> Void
    ) {
        self.type = type
        self.action = action
        self.update = update
        self.file = file
        self.line = line
    }
}

// MARK: Testable State Management: Ergonomics - Actions sent and actions received
enum StepType {
  case send
  case receive
}

// MARK: Testable State Management: Reducers - Testing the counter
class CounterTests: XCTestCase {

    // MARK: Testable State Management: Effects - Testing the counter effects
    override func setUp() {
        super.setUp()
        Current = .mock
    }

    func testIncrButtonTapped() {
//        XCTAssertEqual(
//            state,
//            CounterViewState(
//                alertNthPrime: nil,
//                count: 3,
//                favoritePrimes: [3, 5],
//                isNthPrimeButtonDisabled: false
//            )
//        )

        // MARK: Testable State Management: Ergonomics - Simplifying testing state
//        var state = CounterViewState(count: 2)
//        var expected = state
//        let effects = counterViewReducer(&state,
//                                         .counter(.increaseCount))
//
//        expected.count = 3
//        XCTAssertEqual(state, expected)
//        XCTAssertTrue(effects.isEmpty)

        // MARK: Testable State Management: Ergonomics - The shape of a test
//        assert(
//            initialValue: CounterViewState(count: 2),
//            reducer: counterViewReducer,
//            steps:
//            (.counter(.increaseCount), { $0.count = 3 }),
//            (.counter(.increaseCount), { $0.count = 4 }),
//            (.counter(.decreaseCount), { $0.count = 3 })
//        )

        // MARK: Testable State Management: Ergonomics - Improving test feedback
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
        let effects = counterViewReducer(&state,
                                         .counter(.decreaseCount))

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
//        var state = CounterViewState(
//            alertNthPrime: nil,
//            isNthPrimeButtonDisabled: false
//        )
//        var expected = state
//        var effects = counterViewReducer(&state,
//                                         .counter(.nthPrimeButtonTapped))
//
//        expected.isNthPrimeButtonDisabled = true
//        XCTAssertEqual(state, expected)
//        XCTAssertEqual(effects.count, 1)
//
//        var nextAction: CounterViewAction!
//        let receivedCompletion = self.expectation(description: "receivedCompletion")
//        let cancellable = effects[0].sink(
//            receiveCompletion: { _ in
//                receivedCompletion.fulfill()
//            },
//            receiveValue: { action in
//                XCTAssertEqual(action, .counter(.nthPrimeResponse(17)))
//                nextAction = action
//            }
//        )
//        self.wait(for: [receivedCompletion], timeout: 0.01)
//
//        effects = counterViewReducer(&state,
//                                     nextAction)
//
//        expected.alertNthPrime = PrimeAlert(prime: 17)
//        expected.isNthPrimeButtonDisabled = false
//        XCTAssertEqual(state, expected)
//        XCTAssertTrue(effects.isEmpty)
//
//        effects = counterViewReducer(&state,
//                                     .counter(.alertDismissButtonTapped))
//
//        expected.alertNthPrime = nil
//        XCTAssertEqual(state, expected)
//        XCTAssertTrue(effects.isEmpty)
    }

    func testNthPrimeButtonUnhappyFlow() {
        Current.nthPrime = { _ in .sync { nil } }

        var state = CounterViewState(
            alertNthPrime: nil,
            count: 2,
            favoritePrimes: [3, 5],
            isNthPrimeButtonDisabled: false
        )

        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))

        XCTAssertEqual(
            state,
            CounterViewState(
                alertNthPrime: nil,
                count: 2,
                favoritePrimes: [3, 5],
                isNthPrimeButtonDisabled: true
            )
        )
        XCTAssertEqual(effects.count, 1)


        var nextAction: CounterViewAction!
        let receivedCompletion = self.expectation(description: "receivedCompletion")
        let cancellable = effects[0].sink(
            receiveCompletion: { _ in
                receivedCompletion.fulfill()
            },
            receiveValue: { action in
                XCTAssertEqual(action, .counter(.nthPrimeResponse(nil)))
                nextAction = action
            }
        )
        self.wait(for: [receivedCompletion], timeout: 0.01)

//    effects = counterViewReducer(&state, .counter(.nthPrimeResponse(nil)))
        effects = counterViewReducer(&state, nextAction)

        XCTAssertEqual(
            state,
            CounterViewState(
                alertNthPrime: nil,
                count: 2,
                favoritePrimes: [3, 5],
                isNthPrimeButtonDisabled: false
            )
        )
        XCTAssertTrue(effects.isEmpty)
    }

    func testPrimeModal() {
        var state = CounterViewState(
            alertNthPrime: nil,
            count: 2,
            favoritePrimes: [3, 5],
            isNthPrimeButtonDisabled: false
        )

        var effects = counterViewReducer(&state,
                                         .primeModal(.addFavoritePrime))

        XCTAssertEqual(
            state,
            CounterViewState(
                alertNthPrime: nil,
                count: 2,
                favoritePrimes: [3, 5, 2],
                isNthPrimeButtonDisabled: false
            )
        )
        XCTAssert(effects.isEmpty)

        effects = counterViewReducer(&state, .primeModal(.removeFavoritePrime))

        XCTAssertEqual(
            state,
            CounterViewState(
                alertNthPrime: nil,
                count: 2,
                favoritePrimes: [3, 5],
                isNthPrimeButtonDisabled: false
            )
        )
        XCTAssert(effects.isEmpty)
    }
}
