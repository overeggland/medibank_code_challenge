# Snapshot Testing Setup Guide

## Quick Setup

### Step 1: Add SnapshotTesting Package

1. Open `MedibankNews.xcodeproj` in Xcode
2. Select the project in the navigator
3. Select the **MedibankNews** project (not target)
4. Go to the **Package Dependencies** tab
5. Click the **+** button
6. Enter: `https://github.com/pointfreeco/swift-snapshot-testing`
7. Click **Add Package**
8. Select **SnapshotTesting** library
9. Make sure to add it to the **MedibankNewsTests** target
10. Click **Add Package**

### Step 2: Verify Package is Added

After adding the package, you should see:
- `Package Dependencies` section in the project navigator
- `swift-snapshot-testing` package listed
- The package should be linked to `MedibankNewsTests` target

### Step 3: Build and Run Tests

1. Select the **MedibankNewsTests** scheme
2. Press `Cmd + B` to build
3. If build succeeds, you're ready to run snapshot tests!

## First Run - Recording Snapshots

When you first run snapshot tests, you need to record the initial snapshots:

1. Open any snapshot test file (e.g., `ArticleRowSnapshotTests.swift`)
2. Add `isRecording = true` at the beginning of a test method:

```swift
func testArticleRowHorizontalStyle() {
    isRecording = true  // Add this line
    let view = ArticleRow(...)
    assertSnapshot(matching: view, as: .image)
}
```

3. Run the test (it will generate snapshot images)
4. Remove `isRecording = true` 
5. Run the test again to verify it passes

## Troubleshooting

### "No such module 'SnapshotTesting'"

- Ensure the package is added to the **MedibankNewsTests** target
- Clean build folder: `Product → Clean Build Folder` (Shift + Cmd + K)
- Rebuild: `Product → Build` (Cmd + B)

### Snapshots Not Generated

- Check that `__Snapshots__` directories are created next to test files
- Ensure you have `isRecording = true` on first run
- Verify file permissions allow writing to the test directory

### Snapshots Fail to Match

- If UI intentionally changed: Record new snapshots with `isRecording = true`
- If UI unintentionally changed: Investigate the visual difference
- Check simulator version matches between recording and testing

## Package Version

Recommended version: **1.15.0** or later

You can check/update the version in:
- Project Settings → Package Dependencies → swift-snapshot-testing

