//
//  Observable+AggregateTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

class ObservableAggregateTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

extension ObservableAggregateTest {
    func test_AggregateWithSeed_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        
        let res = scheduler.start { xs.reduce(42, +) }
        
        let correctMessages = [
            next(250, 42),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeed_Return() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 24),
            completed(250)
            ])
        
        let res = scheduler.start { xs.reduce(42, +) }
        
        let correctMessages = [
            next(250, 42 + 24),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    func test_AggregateWithSeed_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError),
            ])
        
        let res = scheduler.start { xs.reduce(42, +) }
        
        let correctMessages: [Recorded<Int>] = [
            error(210, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 210)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeed_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs.reduce(42, +) }
        
        let correctMessages: [Recorded<Int>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeed_Range() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])
        
        let res = scheduler.start { xs.reduce(42, +) }
        
        let correctMessages: [Recorded<Int>] = [
            next(260, 42 + 0 + 1 + 2 + 3 + 4),
            completed(260)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 260)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeed_AccumulatorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])
        
        let res = scheduler.start {
            xs.reduce(42) { (a: Int, x: Int) throws -> Int in
                if x < 3 {
                    return a + x
                }
                else {
                    throw testError
                }
            }
        }
        
        let correctMessages: [Recorded<Int>] = [
            error(240, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 240)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            completed(250)
            ])
        
        let res = scheduler.start { xs.reduce(42, +) { $0 * 5 } }
        
        let correctMessages = [
            next(250, 42 * 5),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_Return() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 24),
            completed(250)
            ])
        
        let res = scheduler.start { xs.reduce(42, +, mapResult: { $0 * 5 }) }
        
        let correctMessages = [
            next(250, (42 + 24) * 5),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            error(210, testError),
            ])
        
        let res = scheduler.start { xs.reduce(42, +, mapResult: { $0 * 5 }) }
        
        let correctMessages: [Recorded<Int>] = [
            error(210, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 210)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
   
    func test_AggregateWithSeedAndResult_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start { xs.reduce(42, +, mapResult: { $0 * 5 }) }
        
        let correctMessages: [Recorded<Int>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_Range() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])
        
        let res = scheduler.start { xs.reduce(42, +, mapResult: { $0 * 5 }) }
        
        let correctMessages: [Recorded<Int>] = [
            next(260, (42 + 0 + 1 + 2 + 3 + 4) * 5),
            completed(260)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 260)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_AccumulatorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])
        
        let res = scheduler.start { xs.reduce(42, { a, x in if x < 3 { return a + x } else { throw testError } }, mapResult: { $0 * 5 }) }
        
        let correctMessages: [Recorded<Int>] = [
            error(240, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 240)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_AggregateWithSeedAndResult_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 3),
            next(250, 4),
            completed(260)
            ])
        
        let res = scheduler.start { xs.reduce(42, +, mapResult: { (_: Int) throws -> Int in throw testError }) }
        
        let correctMessages: [Recorded<Int>] = [
            error(260, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 260)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
}


// MARK: toArray
extension ObservableAggregateTest {
    
    func test_ToArrayWithSingleItem_Return() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: ColdObservable<Int> = scheduler.createColdObservable([
            next(10, 1),
            completed(20)
            ])

        let res = scheduler.start {
            return xs.toArray().map { EquatableArray($0) }
        }

        let correctMessages = [
            next(220, EquatableArray([1])),
            completed(220)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 220)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_ToArrayWithMultipleItems_Return() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: ColdObservable<Int> = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            next(30, 3),
            next(40, 4),
            completed(50)
            ])
        
        let res = scheduler.start {
            return xs.toArray().map { EquatableArray($0) }
        }
        
        let correctMessages = [
            next(250, EquatableArray([1,2,3,4])),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_ToArrayWithNoItems_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: ColdObservable<Int> = scheduler.createColdObservable([
            completed(50)
            ])
        
        let res = scheduler.start {
            return xs.toArray().map { EquatableArray($0) }
        }
        
        let correctMessages: [Recorded<EquatableArray<Int>>] = [
            next(250, EquatableArray([])),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_ToArrayWithSingleItem_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1)
            ])
        
        let res = scheduler.start {
            return xs.toArray().map { EquatableArray($0) }
        }
        
        let correctMessages: [Recorded<EquatableArray<Int>>] = [
        ]
        
        let correctSubscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_ToArrayWithImmediateError_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: ColdObservable<Int> = scheduler.createColdObservable([
            error(10, testError)
            ])
        
        let res = scheduler.start {
            return xs.toArray().map { EquatableArray($0) }
        }
        
        let correctMessages: [Recorded<EquatableArray<Int>>] = [
            error(210, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 210)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func test_ToArrayWithMultipleItems_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: ColdObservable<Int> = scheduler.createColdObservable([
            next(10, 1),
            next(20, 2),
            next(30, 3),
            next(40, 4),
            error(50, testError)
            ])
        
        let res = scheduler.start {
            return xs.toArray().map { EquatableArray($0) }
        }
        
        let correctMessages: [Recorded<EquatableArray<Int>>] = [
            error(250, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.messages, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
}