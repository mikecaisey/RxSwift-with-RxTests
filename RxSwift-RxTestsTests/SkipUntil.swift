import Foundation
import XCTest
import RxSwift
import RxTests

class RxSwiftRxTestSkipUntil : XCTestCase {
    
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