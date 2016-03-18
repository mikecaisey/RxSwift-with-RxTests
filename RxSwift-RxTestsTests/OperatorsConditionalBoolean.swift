//
//  OperatorsConditionalBoolean.swift
//  RxSwift-RxTests
//
//  Created by Mike Caisey on 18/03/2016.
//  Copyright © 2016 Mike Caisey. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTests

class OperatorsConditionalBoolean : XCTestCase {
    
    // Not implemented by RxSwift yet
    func testAll() {}
    
    func testAmb() {
        
        // Arrange:
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String)
        var subscription: Disposable! = nil
        
        let observableA = scheduler.createHotObservable([
            next(100, "A"),next(150, "B"),next(200, "C")
            ]).asObservable()
        
        let observableB = scheduler.createHotObservable([
            next(99, "1"), next(200, "2"), next(300, "3")
            ]).asObservable()
        
        // Amb (short for ambiguous) given two or more source Observables, emit all
        // of the items from only the first of these Observables
        // to emit an item or notification
        // http://reactivex.io/documentation/operators/amb.html
        let amb = observableA.amb(observableB)
        
        // It's important to note that subscribing 100 means that observableA
        // is the winning stream as previous events are disregarded
        scheduler.scheduleAt(50) {
            subscription = amb.subscribe(observer)
        }
        
        scheduler.scheduleAt(400) {
            subscription.dispose()
        }
        
        // Act:
        scheduler.start()
        
        // Collect the events and times for asserting
        let results: [String] = observer.events.map { event in
            event.value.element!
        }
        
        // Assert:
        XCTAssertEqual(results, ["1", "2", "3"])
    }
    
    func testContains() {}
    func testDefaultIfEmpty() {}
    
    func testSkipUntil() {
        
        // Arrange:
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Int)
        var subscription: Disposable! = nil
        
        let observableA = scheduler.createHotObservable([
            next(10, 1), next(20, 2), next(30, 3), next(40, 4), next(50, 5),
            next(60, 6), next(70, 7), next(80, 8), next(90, 9), next(100, 10)
        ]).asObservable()
        
        let observableB = scheduler.createHotObservable([
            next(55, true), next(75, true)
        ]).asObservable()
        
        let skipUntil = observableA.skipUntil(observableB)
        
        // observableB will fire an event at time 55 allowing the events of 
        // observableA to flow through
        scheduler.scheduleAt(1) {
            subscription = skipUntil.subscribe(observer)
        }
        
        scheduler.scheduleAt(200) {
            subscription.dispose()
        }
        
        // Act:
        scheduler.start()
        
        // Collect the events for asserting
        let results: [Int] = observer.events.map { event in
            event.value.element!
        }
        
        // Assert:
        XCTAssertEqual(results, [6, 7, 8, 9, 10])
    }

}