//
//  StressTests.swift
//  
//
//  Created by Asiel Cabrera Gonzalez on 1/16/22.
//

import XCTest
import Foundation
import FutureKit

class StressTests: XCTestCase {
    func testThenDataRace() {
        let e1 = expectation(description: "")

        // will crash if `on` doesn't protect handlers
        stressDataRace(expectation: e1, stressFunction: { future in
            future.on(success: { value in
                XCTAssertEqual("ok", value)
            })
            return
        }, succeed: { "ok" })

        waitForExpectations(timeout: 10, handler: nil)
    }
}

private func stressDataRace<Value: Equatable>(expectation e1: XCTestExpectation, iterations: Int = 1000, stressFactor: Int = 10, stressFunction: @escaping (Future<Value, Error>) -> Void, succeed: @escaping () -> Value) {
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "stress.test", attributes: .concurrent)

    for _ in 0..<iterations {
        let promise = Promise<Value, Error>()
        let future = promise.future

        DispatchQueue.concurrentPerform(iterations: stressFactor) { _ in
            stressFunction(future)
        }

        queue.async(group: group) {
            promise.succeed(value: succeed())
        }
    }

    // this works around a type complaint in swift/linux where it was refusing to
    // bind and invoke e1.fulfill with no parameters.
    func voidfulfill() -> Void {
        e1.fulfill()
    }

    group.notify(queue: queue, execute: voidfulfill)
}
