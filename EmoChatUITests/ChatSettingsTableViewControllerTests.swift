//
//  EmoChatUITests.swift
//  EmoChatUITests
//
//  Created by Mykola Aleshchenko on 6/25/17.
//  Copyright © 2017 SoftServe. All rights reserved.
//

import XCTest

class ChatSettingsTableViewControllerUITests: XCTestCase {
    
    let app = XCUIApplication()
    let window = XCUIApplication().windows.element(boundBy: 0)
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = true
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTableViewVisisbility() {
        let tableElement = app.tables.element
        XCTAssertTrue(tableElement.exists)
        XCTAssertTrue(window.frame.contains(tableElement.frame))
    }
    
    func testTableViewHeaders() {
        let tableElement = app.tables.element
        XCTAssertTrue(tableElement.otherElements["CHAT SETTINGS"].exists)
    }
    
    func testTableViewCells() {
        let tableElement = app.tables.element
        XCTAssertTrue(tableElement.cells.count > 0)
    }
    
    func testInviteUserCell() {
        let tableElement = app.tables.element
        let inviteUserCell = tableElement.cells.staticTexts["Invite User"]
        XCTAssertTrue(inviteUserCell.exists)
        inviteUserCell.tap()
        XCTAssertFalse(app.navigationBars["Users"].exists) //we're in different screen now, the title has changed
    }
    
    func testTableViewScroll() {
        //example for scrolling to the last cell
        //won't actually scroll, tableView is too small
        let tableElement = app.tables.element
        let lastCell = tableElement.cells.element(boundBy: tableElement.cells.count - 1)
        tableElement.scrollToElement(element: lastCell)
        
        let isCellVisible = window.frame.contains(lastCell.frame)
        XCTAssertTrue(isCellVisible)
    }
    
    func testRotation() {
        let device = XCUIDevice.shared()
        let tableElement = app.tables.element

        device.orientation = .landscapeLeft
        XCTAssertTrue(window.frame.contains(tableElement.frame))
        
        device.orientation = .portrait
        XCTAssertTrue(window.frame.contains(tableElement.frame))
    }
    
    func testLoginCell() {
        //getting element by its accessibility identifier set in storyboard
        let tableElement = app.tables.element[0]
        let cell = tableElement.cells["logoCell"]
        XCTAssertTrue(cell.exists)
    }
}

//MARK - auxiliary methods
extension XCUIElement {
    func scrollToElement(element: XCUIElement) {
        while !element.visible() {
            swipeUp()
        }
    }
    
    func visible() -> Bool {
        guard self.exists && !self.frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
}

