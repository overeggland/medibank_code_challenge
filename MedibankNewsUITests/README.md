# UI Tests

This directory contains XCUITest tests for the MedibankNews app.

## Test Structure

- `MedibankNewsUITests.swift`: UI tests for user flows including:
  - Opening articles
  - Saving articles
  - Viewing saved articles
  - Navigation between tabs

## Setup

To add the UI test target to your Xcode project:

1. **Open the project in Xcode**
2. **Add UI Test Target:**
   - Go to File → New → Target
   - Select "UI Testing Bundle"
   - Name it "MedibankNewsUITests"
   - Make sure it's set to test the "MedibankNews" target
   - Click Finish

3. **Add Test Files to Target:**
   - Select `MedibankNewsUITests.swift` in the `MedibankNewsUITests` directory
   - In the File Inspector (right panel), ensure it's added to the "MedibankNewsUITests" target

4. **Configure Test Target Settings:**
   - Select the "MedibankNewsUITests" target in the project navigator
   - In the General tab, set the "Target to be Tested" to "MedibankNews"
   - Ensure the bundle identifier is set (e.g., `com.example.MedibankNewsUITests`)

## Running Tests

- **Run all UI tests**: `Cmd + U` or Product → Test
- **Run specific test**: Click the diamond icon next to the test method
- **Run from command line**: 
  ```bash
  xcodebuild test -scheme MedibankNews -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:MedibankNewsUITests
  ```

## Test Coverage

### Article Flow Tests
- ✅ `testArticleFlow_OpenSaveViewSaved`: Complete flow - open article → save → view saved
- ✅ `testSaveArticleFromListView`: Save article from the headlines list
- ✅ `testOpenArticleFromSavedList`: Open article from saved articles list
- ✅ `testUnsaveArticle`: Remove article from saved list
- ✅ `testTabNavigation`: Navigate between Headlines, Sources, and Saved tabs

## Accessibility Identifiers

The UI tests rely on accessibility identifiers added to UI elements:

- Article rows: `article_row_<short_id>` (short_id is an 8-digit hash of the article URL)
- Save buttons: `save_btn_<short_id>`
- Detail view save button: `save_detail_<short_id>`

The short_id is generated from a hash of the article URL to keep identifiers short and avoid issues with long URLs.
- Tab bar items: `headlines_tab`, `sources_tab`, `saved_tab`

These identifiers are automatically added to the UI elements in the view files.

