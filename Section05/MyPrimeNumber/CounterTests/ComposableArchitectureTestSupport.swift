//
//  ComposableArchitectureTestSupport.swift
//  CounterTests
//
//  Created by Yebin Kim on 2021/02/01.
//

import Combine
import ComposableArchitecture
import XCTest

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

// MARK: Testable State Management: Ergonomics - Actions sent and actions received
enum StepType {
  case send
  case receive
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
