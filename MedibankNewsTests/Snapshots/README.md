# Snapshot Tests

This directory contains snapshot tests for SwiftUI views using the [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library.

## Setup

### 1. Add SnapshotTesting Package

1. Open the project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the package URL: `https://github.com/pointfreeco/swift-snapshot-testing`
4. Select **Up to Next Major Version** and choose the latest version (or `1.15.0` or later)
5. Add the package to the **MedibankNewsTests** target

### 2. Configure Snapshot Testing

The snapshot tests will automatically:
- Generate reference images on first run
- Compare against reference images on subsequent runs
- Store snapshots in `__Snapshots__` directories next to test files

### 3. Running Snapshot Tests

- **Run all snapshot tests**: `Cmd + U` or Product → Test
- **Run specific test**: Click the diamond icon next to the test method
- **Record new snapshots**: Set `isRecording = true` in the test (see below)

### 4. Recording New Snapshots

When you first add snapshot tests or change the UI, you need to record new snapshots:

```swift
func testMyView() {
    isRecording = true  // Add this line
    let view = MyView()
    assertSnapshot(matching: view, as: .image)
}
```

Run the test once to generate snapshots, then remove `isRecording = true` and run again to verify.

## Test Coverage

### ArticleRowSnapshotTests
- ✅ Horizontal style with image
- ✅ Horizontal style without image
- ✅ Card style with image
- ✅ Card style without image
- ✅ Compact style
- ✅ Compact style with long title
- ✅ Saved state (horizontal style)
- ✅ Saved state (card style)

### ArticleListViewSnapshotTests
- ✅ Loading state
- ✅ Error state
- ✅ No sources selected state
- ✅ Empty articles state
- ✅ With articles loaded

### SavedArticlesListViewSnapshotTests
- ✅ Empty state
- ✅ With single article
- ✅ With multiple articles

### SourcesListViewSnapshotTests
- ✅ Loading state
- ✅ Error state
- ✅ Empty state
- ✅ With sources loaded

## Customization

### Snapshot Configuration

You can customize snapshot settings by modifying the `assertSnapshot` calls:

```swift
// Custom precision
assertSnapshot(matching: view, as: .image(precision: 0.98))

// Custom size
assertSnapshot(matching: view, as: .image(on: .iPhone13Pro))

// Custom traits
assertSnapshot(matching: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
```

### Device Sizes

Default snapshots use iPhone 13 size (375x667). To test different sizes:

```swift
assertSnapshot(matching: view, as: .image(on: .iPhone13ProMax))
assertSnapshot(matching: view, as: .image(on: .iPadPro12_9))
```

## Troubleshooting

### Snapshots Don't Match

If snapshots fail to match:
1. Check if the UI has intentionally changed
2. If intentional, record new snapshots with `isRecording = true`
3. If unintentional, investigate the visual difference

### Snapshots Not Generated

1. Ensure SnapshotTesting package is added to the test target
2. Check that `import SnapshotTesting` is present
3. Verify the test target can access the main app target

### CI/CD Considerations

For CI/CD pipelines:
- Commit the `__Snapshots__` directories to version control
- Ensure consistent simulator versions across environments
- Consider using `precise: false` for minor rendering differences

