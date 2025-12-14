//
//  MedibankNewsUITests.swift
//  MedibankNewsUITests
//
//  Created by Xavier Zhang on 14/12/2025.
//  Copyright © 2025 Your Org. All rights reserved.
//

import XCTest

final class MedibankNewsUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }

    // MARK: - Test Article Flow
    
    /// Test the complete flow: Open article > Save article > View saved articles
    @MainActor
    func testArticleFlow_OpenSaveViewSaved() throws {
        // Wait for the app to load articles
        let headlinesTab = app.tabBars.buttons["Headlines"]
        XCTAssertTrue(headlinesTab.waitForExistence(timeout: 5), "Headlines tab should exist")
        
        // Ensure we're on the Headlines tab
        if !headlinesTab.isSelected {
            headlinesTab.tap()
        }
        
        // Wait for articles to load
        let firstArticleRow = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'article_row_'")).firstMatch
        XCTAssertTrue(firstArticleRow.waitForExistence(timeout: 10), "Articles should load within 10 seconds")
        
        // Get the first article's identifier by removing the prefix
        let fullIdentifier = firstArticleRow.identifier
        guard fullIdentifier.hasPrefix("article_row_") else {
            XCTFail("Article row identifier format is incorrect: \(fullIdentifier)")
            return
        }
        let firstArticleIdentifier = String(fullIdentifier.dropFirst("article_row_".count))
        
        // Tap to open the article detail view
        firstArticleRow.tap()
        
        // Wait for the detail view to appear (check for the save button in detail view)
        let detailSaveButton = app.buttons["save_detail_\(firstArticleIdentifier)"]
        XCTAssertTrue(detailSaveButton.waitForExistence(timeout: 5), "Article detail view should appear")
        
        // Save the article from detail view
        detailSaveButton.tap()
        
        // Navigate back to the list
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists {
            backButton.tap()
        }
        
        // Navigate to Saved tab
        let savedTab = app.tabBars.buttons["Saved"]
        XCTAssertTrue(savedTab.waitForExistence(timeout: 2), "Saved tab should exist")
        savedTab.tap()
        
        // Verify the saved article appears in the saved list
        let savedArticleRow = app.buttons["article_row_\(firstArticleIdentifier)"]
        XCTAssertTrue(savedArticleRow.waitForExistence(timeout: 5), "Saved article should appear in saved list")
    }
    
    /// Test saving an article from the list view
    @MainActor
    func testSaveArticleFromListView() throws {
        // Wait for the app to load
        let headlinesTab = app.tabBars.buttons["Headlines"]
        XCTAssertTrue(headlinesTab.waitForExistence(timeout: 5), "Headlines tab should exist")
        
        if !headlinesTab.isSelected {
            headlinesTab.tap()
        }
        
        // Wait for articles to load
        let firstArticleRow = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'article_row_'")).firstMatch
        XCTAssertTrue(firstArticleRow.waitForExistence(timeout: 10), "Articles should load within 10 seconds")
        
        // Get the first article's identifier by removing the prefix
        let fullIdentifier = firstArticleRow.identifier
        guard fullIdentifier.hasPrefix("article_row_") else {
            XCTFail("Article row identifier format is incorrect: \(fullIdentifier)")
            return
        }
        let firstArticleIdentifier = String(fullIdentifier.dropFirst("article_row_".count))
        
        // Find and tap the save button for the first article
        let saveButton = app.buttons["save_btn_\(firstArticleIdentifier)"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2), "Save button should exist")
        
        // Save the article
        saveButton.tap()
        
        // Navigate to Saved tab
        let savedTab = app.tabBars.buttons["Saved"]
        XCTAssertTrue(savedTab.waitForExistence(timeout: 2), "Saved tab should exist")
        savedTab.tap()
        
        // Verify the saved article appears
        let savedArticleRow = app.buttons["article_row_\(firstArticleIdentifier)"]
        XCTAssertTrue(savedArticleRow.waitForExistence(timeout: 5), "Saved article should appear in saved list")
    }
    
    /// Test opening an article from the saved list
    @MainActor
    func testOpenArticleFromSavedList() throws {
        // First, save an article
        let headlinesTab = app.tabBars.buttons["Headlines"]
        XCTAssertTrue(headlinesTab.waitForExistence(timeout: 5), "Headlines tab should exist")
        
        if !headlinesTab.isSelected {
            headlinesTab.tap()
        }
        
        // Wait for articles to load
        let firstArticleRow = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'article_row_'")).firstMatch
        XCTAssertTrue(firstArticleRow.waitForExistence(timeout: 10), "Articles should load within 10 seconds")
        
        // Get the first article's identifier by removing the prefix
        let fullIdentifier = firstArticleRow.identifier
        guard fullIdentifier.hasPrefix("article_row_") else {
            XCTFail("Article row identifier format is incorrect: \(fullIdentifier)")
            return
        }
        let firstArticleIdentifier = String(fullIdentifier.dropFirst("article_row_".count))
        
        // Save the article
        let saveButton = app.buttons["save_btn_\(firstArticleIdentifier)"]
        if saveButton.waitForExistence(timeout: 2) {
            saveButton.tap()
        }
        
        // Navigate to Saved tab
        let savedTab = app.tabBars.buttons["Saved"]
        XCTAssertTrue(savedTab.waitForExistence(timeout: 2), "Saved tab should exist")
        savedTab.tap()
        
        // Wait for saved article to appear
        let savedArticleRow = app.buttons["article_row_\(firstArticleIdentifier)"]
        XCTAssertTrue(savedArticleRow.waitForExistence(timeout: 5), "Saved article should appear")
        
        // Tap to open the saved article
        savedArticleRow.tap()
        
        // Verify detail view appears
        let detailSaveButton = app.buttons["save_detail_\(firstArticleIdentifier)"]
        XCTAssertTrue(detailSaveButton.waitForExistence(timeout: 5), "Article detail view should appear")
    }
    
    /// Test unsaving an article
    @MainActor
    func testUnsaveArticle() throws {
        // First, save an article
        let headlinesTab = app.tabBars.buttons["Headlines"]
        XCTAssertTrue(headlinesTab.waitForExistence(timeout: 5), "Headlines tab should exist")
        
        if !headlinesTab.isSelected {
            headlinesTab.tap()
        }
        
        // Wait for articles to load
        let firstArticleRow = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'article_row_'")).firstMatch
        XCTAssertTrue(firstArticleRow.waitForExistence(timeout: 10), "Articles should load within 10 seconds")
        
        // Get the first article's identifier by removing the prefix
        let fullIdentifier = firstArticleRow.identifier
        guard fullIdentifier.hasPrefix("article_row_") else {
            XCTFail("Article row identifier format is incorrect: \(fullIdentifier)")
            return
        }
        let firstArticleIdentifier = String(fullIdentifier.dropFirst("article_row_".count))
        
        // Save the article
        let saveButton = app.buttons["save_btn_\(firstArticleIdentifier)"]
        if saveButton.waitForExistence(timeout: 2) {
            saveButton.tap()
        }
        
        // Navigate to Saved tab and verify it's there
        let savedTab = app.tabBars.buttons["Saved"]
        savedTab.tap()
        
        let savedArticleRow = app.buttons["article_row_\(firstArticleIdentifier)"]
        XCTAssertTrue(savedArticleRow.waitForExistence(timeout: 5), "Saved article should appear")
        
        // Unsave the article
        let unsaveButton = app.buttons["save_btn_\(firstArticleIdentifier)"]
        if unsaveButton.waitForExistence(timeout: 2) {
            unsaveButton.tap()
        }
        
        // Verify the article is removed from saved list
        // The article row should no longer exist or the empty state should appear
        let emptyState = app.staticTexts["No saved articles"]
        XCTAssertTrue(emptyState.waitForExistence(timeout: 3) || !savedArticleRow.exists, 
                     "Article should be removed from saved list")
    }
    
    /// Test navigation between tabs
    @MainActor
    func testTabNavigation() throws {
        // Test Headlines tab
        let headlinesTab = app.tabBars.buttons["Headlines"]
        XCTAssertTrue(headlinesTab.waitForExistence(timeout: 5), "Headlines tab should exist")
        headlinesTab.tap()
        XCTAssertTrue(headlinesTab.isSelected, "Headlines tab should be selected")
        
        // Test Sources tab
        let sourcesTab = app.tabBars.buttons["Sources"]
        XCTAssertTrue(sourcesTab.waitForExistence(timeout: 2), "Sources tab should exist")
        sourcesTab.tap()
        XCTAssertTrue(sourcesTab.isSelected, "Sources tab should be selected")
        
        // Test Saved tab
        let savedTab = app.tabBars.buttons["Saved"]
        XCTAssertTrue(savedTab.waitForExistence(timeout: 2), "Saved tab should exist")
        savedTab.tap()
        XCTAssertTrue(savedTab.isSelected, "Saved tab should be selected")
    }
}
