# Distributing WorkerCTL to Your Team via TestFlight

TestFlight is Apple's official way to distribute apps to testers. Your coworkers **do NOT need developer accounts** - just regular Apple IDs!

## Quick Overview

1. You build and upload the app to App Store Connect
2. Add your coworkers as testers (using their email addresses)
3. They get an email invitation
4. They install TestFlight app (free)
5. They install WorkerCTL through TestFlight
6. Updates are automatic!

## Prerequisites

### You Need:
- ✅ Apple Developer Account ($99/year) - You probably have this already
- ✅ Mac with Xcode
- ✅ WorkerCTL project

### Your Coworkers Need:
- ✅ Just an Apple ID (free)
- ✅ iPhone or iPad (iOS 17+)
- ✅ That's it!

## Step-by-Step Guide

### Part 1: Set Up App Store Connect (One Time)

1. **Go to App Store Connect**
   - Visit https://appstoreconnect.apple.com
   - Sign in with your Apple Developer account

2. **Create the App**
   - Click "My Apps"
   - Click the "+" button
   - Select "New App"
   - Fill in:
     - **Platform**: iOS
     - **Name**: WorkerCTL
     - **Primary Language**: English
     - **Bundle ID**: Select the one from your Xcode project (e.g., `com.mozilla.WorkerCTL`)
     - **SKU**: `workerctl` (can be anything unique)
     - **User Access**: Full Access
   - Click "Create"

3. **Fill in Required App Information**
   - Go to the app you just created
   - Click "App Information" (left sidebar)
   - Fill in:
     - **Category**: Developer Tools (or Utilities)
     - **Content Rights**: Check the box
   - Save

### Part 2: Prepare Your App in Xcode

1. **Open WorkerCTL in Xcode**

2. **Select Your Team**
   - Click on the project (blue icon) in navigator
   - Under "Signing & Capabilities"
   - Select your team
   - Make sure "Automatically manage signing" is checked

3. **Set Version and Build Number**
   - Still in project settings
   - Under "General" tab
   - **Version**: 1.0 (semantic version)
   - **Build**: 1 (increment this for each upload)

4. **Create Archive**
   - In Xcode menu: **Product** → **Archive**
   - Wait for it to build (takes a few minutes)
   - The Organizer window will open automatically

### Part 3: Upload to App Store Connect

1. **In Xcode Organizer**
   - Your archive should appear in the list
   - Click **Distribute App**
   - Select **App Store Connect**
   - Click **Next**

2. **Distribution Options**
   - Select **Upload**
   - Click **Next**
   - Keep defaults (Automatically manage signing)
   - Click **Next**

3. **Review and Upload**
   - Review the summary
   - Click **Upload**
   - Wait for upload to complete (5-10 minutes)
   - You'll see "Upload Successful"

4. **Wait for Processing**
   - Go back to App Store Connect
   - Go to your app → TestFlight tab
   - Wait for "Processing" to change to "Ready to Test" (10-30 minutes)
   - You'll get an email when it's ready

### Part 4: Add Your Coworkers as Testers

1. **In App Store Connect**
   - Go to your app
   - Click **TestFlight** tab
   - Click **Internal Testing** (left sidebar)

2. **Create a Test Group** (if you haven't)
   - Click the "+" next to "Internal Testing"
   - Name it: "Mozilla Team" or "Release Eng"
   - Click **Create**

3. **Add Testers**
   - Click on your test group
   - Click **Testers** section
   - Click the "+" button
   - Enter email addresses (comma separated)
   - Click **Add**
   
   **Note**: For more than 100 testers, use "External Testing" instead of Internal

4. **Enable the Build**
   - In your test group
   - Under "Builds" section
   - Click the "+" next to your build
   - Select your build version
   - Add test notes (optional): "Initial release - monitor your worker pools!"
   - Click **Add**

### Part 5: Your Coworkers Install the App

They'll receive an email from TestFlight:

1. **Install TestFlight**
   - Open App Store on iPhone/iPad
   - Search "TestFlight"
   - Install it (it's free from Apple)

2. **Accept Invitation**
   - Open the email invitation
   - Tap "View in TestFlight"
   - Or tap the link in the email

3. **Install WorkerCTL**
   - TestFlight app opens
   - Tap "Accept"
   - Tap "Install"
   - Done!

## Updating the App

When you want to push an update:

1. **In Xcode**
   - Increment the **Build** number (1 → 2 → 3, etc.)
   - Keep **Version** same for minor updates (or bump for big changes)

2. **Archive and Upload**
   - Product → Archive
   - Distribute → Upload
   - Same process as before

3. **In App Store Connect**
   - Go to TestFlight
   - Once processed, click your test group
   - Click "+" next to the new build
   - Add test notes: "Fixed active status bug, improved UI"

4. **Your Team Gets Auto-Update**
   - They'll get a notification
   - Or it updates automatically
   - That's it!

## Tips & Best Practices

### Version Numbers
- **Version** (user-facing): 1.0, 1.1, 2.0
- **Build** (internal): 1, 2, 3, 4... (always increasing)
- Example progression:
  - Version 1.0 (Build 1) - Initial release
  - Version 1.0 (Build 2) - Bug fix
  - Version 1.1 (Build 3) - New feature
  - Version 2.0 (Build 4) - Major update

### Test Notes
Always include what changed:
- "Fixed active status detection"
- "Added new pool presets"
- "Improved dark mode colors"
- "Performance improvements"

### Internal vs External Testing
- **Internal Testing** (25 testers max)
  - Instant access
  - No Apple review
  - For your team only
  - Perfect for WorkerCTL!

- **External Testing** (10,000 testers max)
  - Apple reviews the build first (1-2 days)
  - For wider distribution
  - Only needed for big rollouts

### Managing Testers
- You can add/remove testers anytime
- Testers can opt out anytime
- You can see who installed the app
- You can see crash reports and feedback

## Troubleshooting

### "No Bundle ID available"
- Make sure you created the app in App Store Connect first
- Refresh Xcode's accounts (Preferences → Accounts → Download Manual Profiles)

### "Archive not showing in Organizer"
- Make sure you selected "Any iOS Device" (not a simulator) before archiving
- Clean build folder: Product → Clean Build Folder

### "Processing taking forever"
- Usually takes 10-30 minutes
- If longer than 2 hours, contact Apple Support
- You can upload a new build while one is processing

### Tester can't install
- Make sure they're using the email address you invited
- They need iOS 17+ (your app requirement)
- They need space on their device

### "Missing Compliance"
- For internal tools like this, select "No" for encryption
- Or provide export compliance documentation

## Cost

- **Apple Developer Account**: $99/year (you need this)
- **TestFlight**: FREE!
- **Testers**: FREE! (no account needed)
- **Updates**: FREE! (unlimited)

## Limits

- **Internal Testing**: 100 devices per tester, 25 internal testers
- **External Testing**: 10,000 external testers
- **Build Expiry**: Builds expire after 90 days (just upload a new one)
- **Builds**: Unlimited uploads

## Example: Adding Your First Coworker

```
1. You: Archive and upload WorkerCTL (Build 1)
2. You: Wait 15 mins for processing
3. You: Add coworker@mozilla.com to "Mozilla Team" group
4. Them: Gets email "You've been invited to test WorkerCTL"
5. Them: Installs TestFlight from App Store
6. Them: Opens email, taps "View in TestFlight"
7. Them: Taps "Install" in TestFlight
8. Them: WorkerCTL appears on their home screen!
9. You: Fix a bug, upload Build 2
10. Them: Gets notification, updates automatically
```

## Security Note

Since you're using **public Taskcluster APIs** with no authentication, there's no security concern with distributing this widely. The app is read-only and connects to public endpoints.

## Alternative: Ad Hoc Distribution

If you want to avoid TestFlight entirely (not recommended):

1. Collect device UDIDs from your coworkers
2. Register devices in Apple Developer portal
3. Create Ad Hoc provisioning profile
4. Build with that profile
5. Send .ipa file via email/Slack
6. They install via Xcode or iTunes

**Downside**: Much more manual, limits of 100 devices, no automatic updates

## Recommendation

**Use TestFlight!** It's:
- ✅ Free
- ✅ Easy
- ✅ Automatic updates
- ✅ Professional
- ✅ Official Apple solution
- ✅ No coworker setup needed

---

**Questions?** The hardest part is the first upload. After that, updates take 2 minutes!

Good luck! Your coworkers will love having WorkerCTL on their phones! 📱🚀
