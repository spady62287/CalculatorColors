//
//  OperatorTests.swift
//  CalculatorColorsTests
//
//  Created by Daniel Spady on 2021-03-08.
//

import XCTest
import Combine

class OperatorTests: XCTestCase {
    
    var subscriptions = Set<AnyCancellable>()
    
    override func tearDownWithError() throws {
        subscriptions = []
    }
    
    func testCollect() {
        // Given
        let values = [0, 1, 2]
        let publisher = values.publisher

        // When
        publisher
            .collect()
            .sink(receiveValue: {
                // Then
                XCTAssert($0 == values, "Result was expected to be \(values) but was \($0)")})
            .store(in: &subscriptions)
    }

    func testFlatMapWithMax2Publishers() {
        // Given
        let intSubject1 = PassthroughSubject<Int, Never>()
        let intSubject2 = PassthroughSubject<Int, Never>()
        let intSubject3 = PassthroughSubject<Int, Never>()

        let publisher = CurrentValueSubject<PassthroughSubject<Int, Never>, Never>(intSubject1)
      
        let expected = [1, 2, 4]
        var results = [Int]()

        publisher
            .flatMap(maxPublishers: .max(2)) { $0 }
            .sink(receiveValue: {
                results.append($0)
            })
            .store(in: &subscriptions)

        // When
        intSubject1.send(1)

        publisher.send(intSubject2)
        intSubject2.send(2)

        publisher.send(intSubject3)
        intSubject3.send(3)
        intSubject2.send(4)

        publisher.send(completion: .finished)

        // Then
        XCTAssert(results == expected, "Results expected to be \(expected) but were \(results)")
    }

    func testTimerPublish() {
        // Given
        func normalized(_ ti: TimeInterval) -> TimeInterval {
            return Double(round(ti * 10) / 10)
        }

        let now = Date().timeIntervalSinceReferenceDate
        let expectation = self.expectation(description: #function)
        let expected = [0.5, 1, 1.5]
        var results = [TimeInterval]()

        let publisher = Timer
            .publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .prefix(3)

        // When
        publisher
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: {
                    results.append(
                        normalized($0.timeIntervalSinceReferenceDate - now)
                    )
                }
            )
            .store(in: &subscriptions)

        // Then
        waitForExpectations(timeout: 2, handler: nil)

        XCTAssert(results == expected,  "Results expected to be \(expected) but were \(results)")
    }

    func testShareReplay() {
        // Given
        let subject = PassthroughSubject<Int, Never>()
        let publisher = subject.shareReplay(capacity: 2)
        let expected = [0, 1, 2, 1, 2, 3, 3]
        var results = [Int]()

        // When
        publisher
            .sink(receiveValue: { results.append($0) })
            .store(in: &subscriptions)

        subject.send(0)
        subject.send(1)
        subject.send(2)

        publisher
            .sink(receiveValue: { results.append($0) })
            .store(in: &subscriptions)

        subject.send(3)

        XCTAssert(results == expected, "Results expected to be \(expected) but were \(results)")
    }
}
