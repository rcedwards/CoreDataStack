//
//  BatchOperationContextTests.swift
//  CoreDataStack
//
//  Created by Robert Edwards on 7/21/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import XCTest

import CoreData

class BatchOperationContextTests: XCTestCase {

    var stack: CoreDataStack!
    var operationContext: NSManagedObjectContext!

    var bookFetchRequest: NSFetchRequest {
        get {
            return NSFetchRequest(entityName: "Book")
        }
    }

    override func setUp() {
        super.setUp()

        let ex1 = expectationWithDescription("StackSetup")
        let ex2 = expectationWithDescription("MocSetup")

        stack = CoreDataStack(modelName: "TestModel", inBundle: NSBundle(forClass: CoreDataStackTests.self)) { (success, error) in
            XCTAssertTrue(success)
            ex1.fulfill()
        }

        stack.newBatchOperationContext() { (result) in
            switch result {
            case .Success(let context):
                self.operationContext = context
            case .Failure(let error):
                XCTFail(error.description)
            }
            ex2.fulfill()
        }

        waitForExpectationsWithTimeout(10, handler: nil)
    }

    override func tearDown() {
        // Delete all the inserted books
        if #available(iOS 9.0, *) {
            let resetReq = NSBatchDeleteRequest(fetchRequest: bookFetchRequest)
            try! stack.mainQueueContext.executeRequest(resetReq)
        } else {
            let books = try! stack.mainQueueContext.executeFetchRequest(bookFetchRequest) as! [Book]
            for book in books {
                stack.mainQueueContext.deleteObject(book)
            }
            stack.mainQueueContext.saveContext()
        }

        super.tearDown()
    }

    func testBatchOperation() {
        let operationMOC = self.operationContext
        operationMOC.performBlockAndWait() {
            for index in 1...10000 {
                if let newBook = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: operationMOC) as? Book {
                    newBook.title = "New Book: \(index)"
                } else {
                    XCTFail("Failed to create a new Book object in the context")
                }
            }

            XCTAssertTrue(operationMOC.hasChanges)
            try! operationMOC.save()
        }

        let mainMOC = stack.mainQueueContext

        do {
            if let books = try mainMOC.executeFetchRequest(bookFetchRequest) as? [Book] {
                XCTAssertEqual(books.count, 10000)
            } else {
                XCTFail("Unable to fetch inserted books from main moc")
            }
        } catch {
            XCTFail("Unable to fetch inserted books from main moc")
        }
    }
}
