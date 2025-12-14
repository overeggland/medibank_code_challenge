# Unit Tests

This directory contains comprehensive unit tests for the MedibankNews app.

## Test Structure

- **Mocks/**: Mock implementations of services for testing
  - `MockNewsService.swift`: Mock implementation of `NewsServicing`
  - `MockSavedArticlesService.swift`: Mock implementation of `SavedArticlesServicing`

- **ViewModels/**: Tests for ViewModels
  - `NewsViewModelTests.swift`: Tests for `NewsViewModel`
  - `SavedArticlesViewModelTests.swift`: Tests for `SavedArticlesViewModel`

- **Services/**: Tests for services
  - `NewsServiceTests.swift`: Tests for `NewsService` and API integration
  - `SavedArticlesServiceTests.swift`: Tests for `SavedArticlesService` and persistence

## Setup

To run these tests, you need to:

1. **Create a Test Target in Xcode:**
   - Open the project in Xcode
   - Go to File → New → Target
   - Select "Unit Testing Bundle"
   - Name it "MedibankNewsTests"
   - Make sure it's set to test the "MedibankNews" target

2. **Add Test Files to Target:**
   - Select all test files in the `MedibankNewsTests` directory
   - In the File Inspector, ensure they're added to the "MedibankNewsTests" target

3. **Configure Test Target Settings:**
   - Set the test target's "Host Application" to "MedibankNews"
   - Ensure the test target can import the main target (use `@testable import MedibankNews`)

## Running Tests

- **Run all tests**: `Cmd + U` or Product → Test
- **Run specific test**: Click the diamond icon next to the test method
- **Run from command line**: `xcodebuild test -scheme MedibankNews -destination 'platform=iOS Simulator,name=iPhone 15'`

## Test Coverage

### NewsViewModelTests
- ✅ Initial state verification
- ✅ Successful article loading
- ✅ Error handling
- ✅ Parameter passing (country, category)
- ✅ Concurrent load prevention
- ✅ Sources computation and deduplication
- ✅ Error clearing on successful load

### SavedArticlesViewModelTests
- ✅ Initial state
- ✅ Save article functionality
- ✅ Remove article functionality
- ✅ Toggle save article
- ✅ Check if article is saved
- ✅ Load saved articles
- ✅ Error handling
- ✅ Multiple articles management
- ✅ Duplicate article prevention

### NewsServiceTests
- ✅ Fetch without API key (returns preview data)
- ✅ Successful API fetch
- ✅ Country and category parameters
- ✅ HTTP error handling
- ✅ Decoding error handling
- ✅ Invalid response handling
- ✅ Network error handling

### SavedArticlesServiceTests
- ✅ Save article functionality
- ✅ Save multiple articles
- ✅ Duplicate article prevention
- ✅ Remove article functionality
- ✅ Check if article is saved
- ✅ Get all saved articles
- ✅ Persistence across service instances
- ✅ Article encoding/decoding

## Notes

- Tests use mock services to avoid network calls and ensure fast, reliable test execution
- `SavedArticlesServiceTests` uses a separate UserDefaults suite to avoid interfering with app data
- All async tests use `@MainActor` annotation for ViewModel tests
- Tests follow the Arrange-Act-Assert pattern for clarity
