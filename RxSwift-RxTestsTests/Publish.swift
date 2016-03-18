import Foundation
import XCTest
import RxSwift
import RxTests

class RxSwiftRxTestPublish : XCTestCase {
    
    func testPublish() {
        
        // Arrange:
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(Int)
        var subscription: Disposable! = nil
        
        let observableA = scheduler.createHotObservable([
            next(10, 1), next(20, 2), next(30, 3), next(40, 4), next(50, 5),
            next(60, 6), next(70, 7), next(80, 8), next(90, 9), next(100, 10)
        ]).asObservable()
        
        // convert the hot observable into publish observable
        let publish = observableA.publish()
    
        // subscribe
        scheduler.scheduleAt(29) {
            subscription = publish.subscribe(observer)
        }
        
        // but not until you call connect does the stream emit events
        scheduler.scheduleAt(39) {
            publish.connect()
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
        XCTAssertEqual(results, [4, 5, 6, 7, 8, 9, 10])
    }
}