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

- **Snapshots/**: Snapshot tests for SwiftUI views
  - `ArticleRowSnapshotTests.swift`: Snapshot tests for ArticleRow component
  - `ArticleListViewSnapshotTests.swift`: Snapshot tests for ArticleListView
  - `SavedArticlesListViewSnapshotTests.swift`: Snapshot tests for SavedArticlesListView
  - `SourcesListViewSnapshotTests.swift`: Snapshot tests for SourcesListView
  - See `Snapshots/README.md` for detailed documentation

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

## Snapshot Testing

This project includes snapshot tests using the [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library.

### Setup Snapshot Testing

1. Add the SnapshotTesting package (see `Snapshots/SETUP.md` for detailed instructions)
2. Run tests with `isRecording = true` to generate initial snapshots
3. Remove `isRecording = true` and run again to verify

### Snapshot Test Coverage

- ✅ ArticleRow (all styles: horizontal, card, compact)
- ✅ ArticleListView (loading, error, empty, and populated states)
- ✅ SavedArticlesListView (empty and populated states)
- ✅ SourcesListView (loading, error, empty, and populated states)

See `Snapshots/README.md` for more details.
