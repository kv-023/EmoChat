//
//  EmoChatTests.swift
//  EmoChatTests
//
//  Created by Mykola Aleshchenko on 6/25/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import XCTest

let userEmail = "testEmail@test.com"

class UserTests: XCTestCase {
    
    var user = User(email: userEmail,
                     username: "TestName",
                     phoneNumber: "066-205-60-72",
                     firstName: "TestFirstName",
                     secondName: "TestLastName",
                     photoURL: nil,
                     uid: UUID().uuidString)
    
    var filePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        print("url path in the documentDirectory \(String(describing: url))")
        
        return (url!.appendingPathComponent("Data").path)
    }
    
    override func setUp() {
        super.setUp()
        
        NSKeyedArchiver.archiveRootObject(user, toFile: filePath)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let dataExists = FileManager.default.fileExists(atPath: filePath)
        if dataExists {
            try? FileManager.default.removeItem(atPath: filePath)
        }
    }
    
    func testDataSaving() {
        NSKeyedArchiver.archiveRootObject(user, toFile: filePath)
        let userData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? User
        XCTAssertFalse(userData == nil)
        
        //XCTFail("failed to save data") //failing deliberately if needed
    }
    
    func testDataReading() {
        if let userData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? User {
            user = userData
            XCTAssertTrue(user.email == userEmail)
            XCTAssertTrue(user.firstName != nil)
            XCTAssertTrue(user.phoneNumber != nil)
        } else {
            XCTFail("failed to read data")
        }
    }
    
    func testPhoneNumberValidation() {
        let regexPhonePattern = "^[+0-9]{0,13}$"
        let testPredicate = NSPredicate(format:"SELF MATCHES %@", regexPhonePattern)
        XCTAssertFalse(testPredicate.evaluate(with: user.phoneNumber))
    }
    
    func testPerformanceExample() {
        self.measure {
            self.testDataSaving()
            self.testDataReading()
        }
    }
}
