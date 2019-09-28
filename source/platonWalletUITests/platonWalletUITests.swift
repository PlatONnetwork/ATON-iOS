//
//  platonWalletUITests.swift
//  platonWalletUITests
//
//  Created by Ned on 15/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import XCTest
import SwiftMonkey

class platonWalletUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments.append("--MonkeyPaws")
        app.launch()

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
//        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testMonkey() {
        let application = XCUIApplication()
        _ = application.descendants(matching: .any).element(boundBy: 0).frame
        let monkey = Monkey(frame: application.frame)
        monkey.addDefaultXCTestPrivateActions()
        monkey.addXCTestTapAlertAction(interval: 100, application: application)
        monkey.monkeyAround()
    }
    
    func testTransfer() {
        
        let app = XCUIApplication()
        let scrollViewsQuery = app.scrollViews
        let element = scrollViewsQuery.children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 1)
        element.children(matching: .other).element(boundBy: 0).children(matching: .button).element.tap()
        element.children(matching: .other).element(boundBy: 2).children(matching: .button).element.tap()
        
        let elementsQuery = scrollViewsQuery.otherElements
        let staticText = elementsQuery.staticTexts["发送"]
        staticText.tap()
        
        let element2 = scrollViewsQuery.children(matching: .other).element(boundBy: 3).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element2.tap()
        elementsQuery.collectionViews/*@START_MENU_TOKEN@*/.staticTexts["opi"]/*[[".cells.staticTexts[\"opi\"]",".staticTexts[\"opi\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        elementsQuery.staticTexts["接收"].tap()
        elementsQuery.staticTexts["0xA7074774f4E1e033c6cBd471Ec072f7734144A0c"].tap()
        staticText.tap()
        
        let textField = elementsQuery.textFields["输入钱包地址"]
        textField.tap()
        textField.tap()
        app/*@START_MENU_TOKEN@*/.menuItems["粘贴"]/*[[".menus.menuItems[\"粘贴\"]",".menuItems[\"粘贴\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        element2.tap()
        elementsQuery.textFields["输入发送数量"].tap()
        
        let key = app/*@START_MENU_TOKEN@*/.keys["删除"]/*[[".keyboards.keys[\"删除\"]",".keys[\"删除\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key.tap()
        key.tap()
        
        let key2 = app/*@START_MENU_TOKEN@*/.keys["1"]/*[[".keyboards.keys[\"1\"]",".keys[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key2.tap()
        key2.tap()
        element2.children(matching: .other).element(boundBy: 1).tap()
        element2.children(matching: .other).element(boundBy: 2).children(matching: .other).element.swipeUp()
        elementsQuery.buttons["下一步"].tap()
        app.buttons["发送"].tap()
        app/*@START_MENU_TOKEN@*/.keys["more"]/*[[".keyboards",".keys[\"更多，数字\"]",".keys[\"more\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        key2.tap()
        app/*@START_MENU_TOKEN@*/.keys["2"]/*[[".keyboards.keys[\"2\"]",".keys[\"2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let key3 = app/*@START_MENU_TOKEN@*/.keys["3"]/*[[".keyboards.keys[\"3\"]",".keys[\"3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key3.tap()
        key3.tap()
        app/*@START_MENU_TOKEN@*/.keys["4"]/*[[".keyboards.keys[\"4\"]",".keys[\"4\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.keys["5"]/*[[".keyboards.keys[\"5\"]",".keys[\"5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let key4 = app/*@START_MENU_TOKEN@*/.keys["6"]/*[[".keyboards.keys[\"6\"]",".keys[\"6\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key4.tap()
        key4.tap()
        app.buttons["确认"].tap()
        
    }
}
