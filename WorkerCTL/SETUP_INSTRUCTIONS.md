# WorkerCTL - Manual Xcode Project Setup

**WorkerCTL** (Worker Control) - Monitor and manage your Taskcluster worker pools from iOS.

Since the Xcode project file had issues, here's how to create the project from scratch in Xcode. This takes about 2 minutes.

## Step 1: Create New Xcode Project

1. Open Xcode
2. Click "Create New Project"
3. Choose **iOS** → **App**
4. Click **Next**

## Step 2: Configure Project

Fill in these settings:
- **Product Name**: `WorkerCTL`
- **Team**: Select your team
- **Organization Identifier**: `com.mozilla` (or your own)
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: None (uncheck Core Data)
- **Include Tests**: Uncheck both boxes

Click **Next** and save it somewhere.

## Step 3: Delete Default Files

In the Project Navigator (left sidebar), **delete** these files (Move to Trash):
- `ContentView.swift` (the default one)
- `WorkerCTLApp.swift` (the default one - we have a better one)
- Any test folders if they were created

Keep:
- `Assets.xcassets`

## Step 4: Add Our Source Files

1. In Finder, locate the 6 Swift files in this folder:
   - `WorkerCTLApp.swift`
   - `ContentView.swift`
   - `Models.swift`
   - `TaskclusterAPI.swift`
   - `WorkerListView.swift`
   - `WorkerDetailView.swift`

2. Drag all 6 files into Xcode's Project Navigator
3. In the dialog that appears:
   - ✅ Check "Copy items if needed"
   - ✅ Make sure your target is selected
   - Click **Finish**

## Step 5: Build Settings (Optional but Recommended)

1. Click on the **WorkerCTL** project (blue icon at top of navigator)
2. Select your **target** (under TARGETS)
3. Go to **General** tab
4. Under **Deployment Info**:
   - Set **Minimum Deployments** to iOS 17.0
   - Select orientations you want
5. Under **Identity**:
   - Update **Bundle Identifier** if needed (e.g., `com.mozilla.WorkerCTL`)

## Step 6: Build and Run

1. Select a simulator or your device from the scheme selector (top toolbar)
2. Press **Cmd+R** or click the Play button
3. The app should build and launch!

## Troubleshooting

### "Cannot find type X in scope"
- Make sure all 6 Swift files are in your target
- Check the file inspector (right sidebar) and ensure "Target Membership" is checked

### "No such module 'SwiftUI'"
- Make sure you're targeting iOS 17.0 or later
- Clean build folder: Product → Clean Build Folder (Cmd+Shift+K)

### Build errors
- Try cleaning: Product → Clean Build Folder
- Restart Xcode
- Delete derived data: Xcode → Preferences → Locations → click arrow next to Derived Data, delete the WorkerCTL folder

## What You'll Get

A fully functional iOS app called **WorkerCTL** that:
- Lists Taskcluster worker pools
- Shows real-time worker status
- Filters and sorts workers
- Shows task details
- Links to Taskcluster web UI
- Eventually: quarantine/unquarantine workers (with auth)

## Next Steps

1. Run the app
2. Browse the default Mozilla worker pools
3. Pull down to refresh
4. Tap a worker to see details
5. Add your own worker pools with the + button

## Files Included

- **WorkerCTLApp.swift** - App entry point (@main)
- **ContentView.swift** - Main pool selection screen
- **Models.swift** - Data models for Worker, Task, etc.
- **TaskclusterAPI.swift** - API client for Taskcluster
- **WorkerListView.swift** - Worker list with filtering/sorting
- **WorkerDetailView.swift** - Detailed worker and task view

All files are complete and ready to use!

## App Icon (Optional)

Want to customize the app icon? 
1. Click on `Assets.xcassets` in Xcode
2. Click on `AppIcon`
3. Drag your icon images into the appropriate slots
4. Recommended: Use SF Symbols app to create an icon with "server.rack" or "terminal" symbol

---

This manual setup is actually cleaner than importing a pre-made Xcode project and gives you full control.

Enjoy **WorkerCTL** - your Taskcluster worker control center! 🚀
