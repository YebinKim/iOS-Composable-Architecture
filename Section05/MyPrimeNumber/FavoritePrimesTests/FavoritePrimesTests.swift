//
//  FavoritePrimesTests.swift
//  FavoritePrimesTests
//
//  Created by Yebim Kim on 2021/01/17.
//

import XCTest
@testable import FavoritePrimes

// MARK: Testable State Management: Reducers - Testing favorite primes
class FavoritePrimesTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Current = .mock
    }

    func testDeleteFavoritePrimes() {
        var state = [2, 3, 5, 7]
        let effects = favoritePrimesReducer(state: &state,
                                            action: .removeFavoritePrimes([2]))
        
        XCTAssertEqual(state, [2, 3, 7])
        XCTAssert(effects.isEmpty)
    }

    // MARK: Testable State Management: Effects - Testing the favorite primes load effect
    func testSaveButtonTapped() {
        var didSave = false

        Current.fileClient.save = { _, data in
            .fireAndForget {
                didSave = true
            }
        }

        var state = [2, 3, 5, 7]
        let effects = favoritePrimesReducer(state: &state, action: .saveButtonTapped)

        XCTAssertEqual(state, [2, 3, 5, 7])
        XCTAssertEqual(effects.count, 1)

        _ = effects[0].sink { _ in XCTFail() }

        XCTAssert(didSave)
    }
    
    func testLoadFavoritePrimesFlow() {
        Current.fileClient.load = { _ in .sync { try! JSONEncoder().encode([2, 31]) } }

        var state = [2, 3, 5, 7]
        var effects = favoritePrimesReducer(state: &state, action: .loadButtonTapped)

        XCTAssertEqual(state, [2, 3, 5, 7])
        XCTAssertEqual(effects.count, 1)

        var nextAction: FavoritePrimesAction!
        let receivedCompletion = self.expectation(description: "receivedCompletion")
        _ = effects[0].sink(
            receiveCompletion: { _ in
                receivedCompletion.fulfill()
            },
            receiveValue: { action in
                XCTAssertEqual(action, .loadedFavoritePrimes([2, 31]))
                nextAction = action
            })
        self.wait(for: [receivedCompletion], timeout: 0)

        effects = favoritePrimesReducer(state: &state, action: nextAction)

        XCTAssertEqual(state, [2, 31])
        XCTAssert(effects.isEmpty)
    }
}
