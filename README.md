# MedibankNews

A modern iOS news application built with SwiftUI that provides users with top headlines from various news sources, source selection capabilities, and article saving functionality.

## Overview

MedibankNews is a native iOS application that fetches news articles from the NewsAPI and presents them in a clean, user-friendly interface. The app features a tab-based navigation system with three main sections: Headlines, Sources, and Saved Articles.

## Screenshots

The following screenshots showcase the main features of the MedibankNews app:

![Headlines Tab](ScreenShots/Simulator%20Screenshot%20-%20iPhone%2017%20-%202025-12-14%20at%2021.19.19.png)
*Headlines Tab - Displaying top news articles with dynamic row styles*

![Sources Tab](ScreenShots/Simulator%20Screenshot%20-%20iPhone%2017%20-%202025-12-14%20at%2021.19.29.png)
*Sources Tab - Managing news source preferences*

![Saved Articles Tab](ScreenShots/Simulator%20Screenshot%20-%20iPhone%2017%20-%202025-12-14%20at%2021.19.41.png)
*Saved Articles Tab - Viewing saved articles for later reading*

## App Icon

The MedibankNews app icon is programmatically generated using a Python script (`generate_icon.py`)

## Architecture

The application follows the **MVVM (Model-View-ViewModel)** architecture pattern, ensuring separation of concerns and testability:

- **Models**: Data structures (`Article`, `Article.Source`)
- **Views**: SwiftUI views that display the UI
- **ViewModels**: Business logic and state management (`NewsViewModel`, `SavedArticlesViewModel`)
- **Services**: Data layer for API calls and persistence (`NewsService`, `SavedArticlesService`)

## Pages Introduction

### 1. ArticleListView (Headlines Tab)

The main page displays top headlines from selected news sources. It features:

- **Dynamic Row Styles**: The first article is displayed in a prominent card style (`CardArticleRow`), while subsequent articles use a horizontal layout (`HorizontalArticleRow`)
- **Loading States**: Shows a progress indicator while fetching articles
- **Error Handling**: Displays user-friendly error messages when API calls fail
- **Empty States**: Provides helpful messages when no sources are selected or no articles are available
- **Refresh**: Manual refresh button in the navigation bar
- **Navigation**: Tapping an article navigates to the detail view

The view automatically filters articles based on selected sources and updates when source selection changes.

### 2. SourcesListView (Sources Tab)

Allows users to manage their news source preferences:

- **Source Selection**: Toggle sources on/off with a checkmark indicator
- **Organized Sections**: Sources are divided into "Selected Sources" and "Available Sources" sections
- **Source Information**: Displays source name and ID for each source
- **Automatic Updates**: When sources are selected, headlines automatically refresh
- **Persistence**: Selected sources are saved and restored across app launches
- **Default Selection**: Automatically selects the first 3 sources on first launch

The view loads sources from the NewsAPI and caches them locally for offline access.

### 3. SavedArticlesListView (Saved Tab)

Displays all articles that users have saved for later reading:

- **Compact Layout**: Uses `CompactArticleRow` for efficient space usage
- **Empty State**: Shows a helpful message when no articles are saved
- **Bulk Actions**: Trash button in the toolbar to clear all saved articles
- **Navigation**: Tapping an article opens the detail view
- **Real-time Updates**: Automatically reflects changes when articles are saved or removed

### 4. ArticleDetailView

The detail view for individual articles:

- **WebView Integration**: Displays the full article content using `WKWebView`
- **Save Functionality**: Heart button in the toolbar to save/unsave articles
- **Share Functionality**: Native share sheet integration
- **Navigation**: Inline navigation bar with article title

## Data Flow Introduction

The application uses a unidirectional data flow pattern:

### News Data Flow

1. **User Interaction** → User selects sources or triggers refresh
2. **ViewModel** → `NewsViewModel` receives the action
3. **Service Layer** → `NewsService` makes API calls to NewsAPI
4. **API Response** → Articles are decoded from JSON
5. **State Update** → ViewModel updates `@Published` properties
6. **View Update** → SwiftUI automatically updates the UI

### Source Selection Flow

1. **User Toggle** → User taps a source in `SourcesListView`
2. **ViewModel Update** → `NewsViewModel.toggleSourceSelection()` updates `selectedSources`
3. **Persistence** → Selected sources are saved to UserDefaults
4. **Auto-refresh** → Headlines automatically reload with new sources
5. **Filtering** → `filteredArticles` computed property filters articles by selected sources

### Saved Articles Flow

1. **User Action** → User taps save button on an article
2. **ViewModel** → `SavedArticlesViewModel.toggleSaveArticle()` is called
3. **Service Layer** → `SavedArticlesService` saves/removes article from UserDefaults
4. **State Sync** → ViewModel reloads saved articles list
5. **UI Update** → Heart icon updates and saved articles list refreshes

### Key Components

- **NewsViewModel**: Manages articles, sources, loading states, and source selection
- **SavedArticlesViewModel**: Manages saved articles state and operations
- **NewsService**: Handles API communication with NewsAPI, caching, and error handling
- **SavedArticlesService**: Manages persistence of saved articles using UserDefaults

## Persistence Introduction

The application uses **UserDefaults** for local data persistence with JSON encoding/decoding:

### 1. Saved Articles Persistence

- **Storage Key**: `"savedArticles"`
- **Format**: JSON-encoded array of `Article` objects
- **Location**: `SavedArticlesService`
- **Operations**: Save, remove, check if saved, get all saved articles
- **Encoding**: Uses `JSONEncoder` with ISO8601 date encoding strategy

### 2. Selected Sources Persistence

- **Storage Key**: `"selectedSources"`
- **Format**: JSON-encoded array of `Article.Source` objects
- **Location**: `NewsViewModel`
- **Operations**: Automatically saved when selection changes, loaded on app launch
- **Validation**: Validates saved sources against current available sources

### 3. Cached Sources List Persistence

- **Storage Key**: `"savedEnglishSources"`
- **Format**: JSON-encoded array of `Article.Source` objects
- **Location**: `NewsService`
- **Purpose**: Provides offline access to sources list when API is unavailable
- **Update**: Automatically updated after successful API fetch

### Persistence Features

- **Automatic Saving**: Changes are persisted immediately
- **Error Handling**: Graceful fallback when encoding/decoding fails
- **Cache Validation**: Ensures persisted data matches current API data
- **Logging**: All cache operations are logged via `AppLogger` for debugging

## Test Introduction and Code Coverage

The project includes comprehensive test coverage across multiple layers:

### Test Structure

#### Unit Tests (`MedibankNewsTests`)

**ViewModels Tests:**
- `NewsViewModelTests`: Tests article loading, source management, error handling, filtering, and persistence
- `SavedArticlesViewModelTests`: Tests save/remove operations, toggle functionality, and state management

**Services Tests:**
- `NewsServiceTests`: Tests API integration, error handling, parameter passing, and caching
- `SavedArticlesServiceTests`: Tests persistence operations, duplicate prevention, and data integrity

**Mock Services:**
- `MockNewsService`: Provides controlled test data for ViewModel tests
- `MockSavedArticlesService`: Isolated test environment for saved articles functionality

### Test Coverage Areas

✅ **NewsViewModel**
- Initial state verification
- Successful article loading with various parameters
- Error handling and error clearing
- Source selection and filtering
- Concurrent load prevention
- Source persistence and restoration
- Default source selection

✅ **SavedArticlesViewModel**
- Initial state and loading
- Save and remove operations
- Toggle functionality
- Duplicate prevention
- Multiple articles management
- Error handling

✅ **NewsService**
- API fetch with valid responses
- Error handling (HTTP errors, decoding errors, network errors)
- Parameter passing (country, category, sources, pageSize)
- Caching and offline fallback
- Preview mode (empty API key)

✅ **SavedArticlesService**
- Save and remove operations
- Duplicate article prevention
- Persistence across service instances
- Article encoding/decoding
- Data integrity

### Test Best Practices

- Tests use mock services to avoid network dependencies
- Isolated test environments (separate UserDefaults suites)
- Async/await support with `@MainActor` for ViewModel tests
- Arrange-Act-Assert pattern for clarity
- Comprehensive error scenario coverage

## Snapshot Introduction

The project uses **SnapshotTesting** library for visual regression testing of SwiftUI views.

### Snapshot Test Coverage

**ArticleRow Components:**
- `ArticleRowSnapshotTests`: Tests all three row styles (Card, Horizontal, Compact)
- Covers states with/without images, saved/unsaved states, and edge cases (long titles)

**View States:**
- `ArticleListViewSnapshotTests`: Loading, error, empty, and populated states
- `SavedArticlesListViewSnapshotTests`: Empty and populated states
- `SourcesListViewSnapshotTests`: Loading, error, empty, and populated states

### Snapshot Testing Workflow

1. **Recording**: Set `isRecording = true` to generate initial snapshots
2. **Verification**: Remove `isRecording` and run tests to compare against reference images
3. **Storage**: Snapshots stored in `__Snapshots__` directories next to test files
4. **CI/CD**: Snapshots are committed to version control for consistent testing

### Setup

The SnapshotTesting package is added via Swift Package Manager. See `MedibankNewsTests/Snapshots/README.md` for detailed setup instructions.

## Technical Details

### Dependencies

- **SwiftUI**: Native iOS UI framework
- **Combine**: Reactive programming (via `@Published` properties)
- **URLSession**: Network requests
- **UserDefaults**: Local persistence
- **SnapshotTesting**: Visual regression testing (test target only)

### API Integration

- **NewsAPI**: Primary data source for articles and sources
- **Error Handling**: Comprehensive error handling with fallback to cached data
- **Caching**: Automatic caching of sources for offline access
- **Rate Limiting**: Respects API rate limits with intelligent request management

### Code Quality

- **Protocol-Oriented**: Services use protocols for testability
- **Dependency Injection**: ViewModels accept service dependencies
- **Logging**: Comprehensive logging via `AppLogger` utility
- **Accessibility**: Accessibility identifiers for UI testing
- **Error Messages**: User-friendly error messages throughout

## Project Structure

```
MedibankNews/
├── Models/              # Data models
├── Views/              # SwiftUI views
│   ├── CellStyles/     # Reusable article row components
├── ViewModels/         # Business logic and state management
├── Services/           # API and persistence services
├── Utils/              # Utility classes (Logger)
├── Resources/          # Assets and localizations
└── MedibankNewsTests/  # Unit and snapshot tests
    ├── Mocks/          # Mock service implementations
    ├── ViewModels/     # ViewModel tests
    ├── Services/       # Service tests
    └── Snapshots/      # Snapshot tests
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- NewsAPI key (configured in `NewsAPIConstants.swift`)

## Getting Started

1. Open `MedibankNews.xcodeproj` in Xcode
2. Build and run the project (Cmd + R)
3. The app will automatically fetch sources and load headlines
4. Select sources in the Sources tab to customize your feed
5. Save articles by tapping the heart icon

## License

This project is a coding challenge submission for Medibank.
