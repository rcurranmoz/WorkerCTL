# WorkerCTL - File Structure Guide

This shows EXACTLY where each file goes when you create the Xcode project.

## Final Project Structure

After following the setup instructions, your Xcode project should look like this:

```
WorkerCTL/                          (Project folder - you create this location)
├── WorkerCTL.xcodeproj/            (Created by Xcode - DON'T TOUCH)
│   └── project.pbxproj
│
└── WorkerCTL/                      (Source folder - this is where files go)
    ├── WorkerCTLApp.swift          ← DRAG THIS FILE HERE
    ├── ContentView.swift           ← DRAG THIS FILE HERE
    ├── Models.swift                ← DRAG THIS FILE HERE
    ├── TaskclusterAPI.swift        ← DRAG THIS FILE HERE
    ├── WorkerListView.swift        ← DRAG THIS FILE HERE
    ├── WorkerDetailView.swift      ← DRAG THIS FILE HERE
    └── Assets.xcassets/            (Created by Xcode - keep this)
        └── AppIcon.appiconset/
            └── Contents.json
```

## Step-by-Step Visual Guide

### Step 1: Create Project in Xcode
When you create a new iOS App project named "WorkerCTL", Xcode creates:

```
WorkerCTL/
├── WorkerCTL.xcodeproj/
└── WorkerCTL/
    ├── WorkerCTLApp.swift          ← DELETE THIS (default one)
    ├── ContentView.swift           ← DELETE THIS (default one)
    └── Assets.xcassets/            ← KEEP THIS
```

### Step 2: Delete Default Files
After deleting the default files, you have:

```
WorkerCTL/
├── WorkerCTL.xcodeproj/
└── WorkerCTL/
    └── Assets.xcassets/            ← Only this remains
```

### Step 3: Add Our Files
Drag all 6 .swift files from the zip into the `WorkerCTL` folder in Xcode:

```
WorkerCTL/
├── WorkerCTL.xcodeproj/
└── WorkerCTL/                      ← Drop files HERE (in Xcode's left sidebar)
    ├── WorkerCTLApp.swift          ← File 1
    ├── ContentView.swift           ← File 2
    ├── Models.swift                ← File 3
    ├── TaskclusterAPI.swift        ← File 4
    ├── WorkerListView.swift        ← File 5
    ├── WorkerDetailView.swift      ← File 6
    └── Assets.xcassets/
```

## In Xcode's Left Sidebar (Project Navigator)

This is how it should look in Xcode after you're done:

```
▼ WorkerCTL                         (Blue project icon)
  ▼ WorkerCTL                       (Yellow folder icon)
      WorkerCTLApp.swift            (Swift file icon)
      ContentView.swift             (Swift file icon)
      Models.swift                  (Swift file icon)
      TaskclusterAPI.swift          (Swift file icon)
      WorkerListView.swift          (Swift file icon)
      WorkerDetailView.swift        (Swift file icon)
    ▼ Assets.xcassets              (Folder icon)
        AppIcon                     (App icon preview)
  ▶ Products                        (Folder)
      WorkerCTL.app                 (Will appear after build)
```

## Important Notes

### ✅ DO THIS:
1. **Drag files into Xcode's Project Navigator** (left sidebar)
2. When the dialog appears, CHECK ✅ "Copy items if needed"
3. Make sure "WorkerCTL" target is selected
4. All 6 files should be at the same level (siblings)

### ❌ DON'T DO THIS:
1. Don't put files in the .xcodeproj folder
2. Don't create subfolders for the Swift files
3. Don't drag into "Products" folder
4. Don't manually copy files in Finder without using Xcode

## How to Drag Files Into Xcode

**Visual Guide:**

```
Finder Window:                      Xcode Window:
┌──────────────────────┐           ┌────────────────────────┐
│ WorkerCTL-Files/     │           │ ▼ WorkerCTL           │
│  • WorkerCTLApp      │   ───→    │   ▼ WorkerCTL    ← DROP HERE
│  • ContentView       │  DRAG     │     Assets...         │
│  • Models           │           │                       │
│  • TaskclusterAPI   │           │                       │
│  • WorkerListView   │           │                       │
│  • WorkerDetailView │           │                       │
└──────────────────────┘           └────────────────────────┘
```

## File Order (Doesn't Matter)

The files can be in any order in Xcode. They'll probably sort alphabetically:
- Assets.xcassets
- ContentView.swift
- Models.swift
- TaskclusterAPI.swift
- WorkerCTLApp.swift
- WorkerDetailView.swift
- WorkerListView.swift

## Verification Checklist

After adding files, verify:

1. ✅ All 6 .swift files are visible in Project Navigator
2. ✅ Each file has the WorkerCTL target checked (click file, check right sidebar)
3. ✅ No red text or missing file warnings
4. ✅ Assets.xcassets is still there
5. ✅ You can click Cmd+B to build without errors

## Common Mistakes & How to Fix

### Mistake 1: Files not showing in Xcode
**Fix:** Drag them into Xcode's left sidebar, not into Finder

### Mistake 2: "WorkerCTL.app is damaged"
**Fix:** This is an old issue from the .xcodeproj file. You won't have this with manual setup.

### Mistake 3: Build errors saying "cannot find X"
**Fix:** Click each .swift file, look at right sidebar under "Target Membership", ensure "WorkerCTL" is checked

### Mistake 4: Files are in wrong location
**Fix:** Right-click file in Xcode → Delete → Remove Reference (not Move to Trash)
Then drag it in again with "Copy items if needed" checked

## Quick Test

After adding all files, press **Cmd+B** to build.

You should see:
```
✅ Build Succeeded
```

If you see errors, check the structure matches the diagram above.

## Need Help?

If your structure doesn't match, here's how to check in Finder:

```bash
cd ~/wherever-you-saved-WorkerCTL
ls -R
```

Should show:
```
./WorkerCTL:
WorkerCTLApp.swift
ContentView.swift
Models.swift
TaskclusterAPI.swift
WorkerListView.swift
WorkerDetailView.swift
Assets.xcassets

./WorkerCTL/Assets.xcassets:
AppIcon.appiconset
Contents.json
```

---

Follow this structure exactly and you'll have a working app! 🎯
