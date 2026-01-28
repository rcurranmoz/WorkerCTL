# WorkerCTL - Taskcluster Worker Control

**Control your Taskcluster worker fleet from iOS.**

A beautiful native iOS app to monitor and manage your Taskcluster worker pools in real-time. Built specifically for Mozilla Firefox CI infrastructure, but works with any Taskcluster deployment.

## Features

- 📊 **Real-time Worker Monitoring** - View all workers in your pools with live status
- 🔍 **Advanced Filtering** - Filter by quarantine status, activity, search workers
- 📱 **Beautiful UI** - Clean, modern design optimized for iOS
- 🔄 **Pull to Refresh** - Easy updates with pull-to-refresh
- 📈 **Worker Stats** - See total, active, and quarantined worker counts at a glance
- 🔗 **Deep Links** - Tap to open workers and tasks in Taskcluster web UI
- 📋 **Task Details** - View latest task information for each worker
- ➕ **Custom Pools** - Add any worker pool from Taskcluster
- 🎯 **Zero Config** - Works immediately with Mozilla Firefox CI

## Quick Start

See **SETUP_INSTRUCTIONS.md** for the 2-minute setup guide.

**TL;DR:**
1. Create new iOS App project in Xcode named "WorkerCTL"
2. Drag the 6 .swift files into Xcode
3. Build and run!

## Screenshots

The app includes:
- **Pool List**: Browse all your worker pools
- **Worker List**: See all workers sorted by last active time with stats
- **Worker Details**: Detailed view of worker and task information
- **Filters**: Search, quarantine status, and activity filters

## Default Worker Pools

Pre-configured with Mozilla Firefox CI pools:

1. **M4 Mac mini** (`gecko-t-osx-1500-m4`)
   - Apple M4 macOS workers

2. **M1 Mac mini** (`gecko-t-osx-1400-r8`)
   - Apple M1 macOS workers

3. **Intel Mac** (`gecko-t-osx-1100`)
   - Intel macOS workers

Add more pools through the app's "Add Worker Pool" button.

## Architecture

### iOS App (SwiftUI)
- **WorkerCTLApp.swift** - App entry point
- **ContentView.swift** - Pool selection screen
- **WorkerListView.swift** - Worker list with filtering and sorting
- **WorkerDetailView.swift** - Detailed worker and task information
- **Models.swift** - Data models for workers and tasks
- **TaskclusterAPI.swift** - API client for Taskcluster

### Optional: Cloudflare Worker
For authenticated actions like quarantine/unquarantine:
- Proxies authenticated Taskcluster API requests
- Secure credential storage
- CORS handling for iOS app
- See `taskcluster-proxy` folder

## API Endpoints Used

### Public (No Auth Required) ✅ Works Now
- `GET /api/queue/v1/provisioners/{provisionerId}/worker-types/{workerType}/workers`
  - List all workers in a pool
  - Query params: `quarantined`, `limit`, `workerState`

- `GET /api/queue/v1/task/{taskId}/status`
  - Get task status and run information

### Authenticated (Via Cloudflare Worker) 🔐 Optional
- `PUT /workers/{provisionerId}/{workerType}/{workerId}/quarantine`
  - Quarantine or unquarantine a worker

## Customization

### Adding Worker Pools

In the app, tap "Add Worker Pool" and enter:
- Display Name (e.g., "Windows Workers")
- Description (e.g., "Windows 10 build workers")
- Provisioner ID (e.g., "releng-hardware")
- Worker Type (e.g., "gecko-t-win10")

### Change Taskcluster Instance

In `TaskclusterAPI.swift`, update:
```swift
private let taskclusterRootURL = "https://your-instance.com"
```

## Roadmap

- [ ] Push notifications for worker issues
- [ ] Historical data and charts
- [ ] Worker quarantine/unquarantine (requires auth setup)
- [ ] Queue depth monitoring
- [ ] Persistent worker pools (UserDefaults/CloudKit)
- [ ] iPad optimization with multi-column layout
- [ ] Dark mode optimization
- [ ] Export worker data
- [ ] Widgets for iOS home screen

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Tech Stack

- **SwiftUI** - Modern, declarative UI
- **Async/Await** - Clean asynchronous code
- **URLSession** - Native networking, zero dependencies
- **Codable** - Type-safe JSON parsing
- **No external dependencies** - Pure Swift/SwiftUI

## Authentication

The app uses **public Taskcluster API endpoints** which don't require authentication. This means it works immediately with zero setup.

For write operations (quarantining workers), you'll need to:
1. Deploy the Cloudflare Worker proxy
2. Set your Taskcluster credentials as secrets
3. Update the `baseURL` in TaskclusterAPI.swift

See the `taskcluster-proxy` folder for details.

## Contributing

This is a personal project for Mozilla Release Engineering, but improvements are welcome!

## Support

For issues with:
- **The app**: Check the code or create an issue
- **Taskcluster API**: See https://docs.taskcluster.net/
- **Firefox CI**: Contact Mozilla Release Engineering

## License

MIT License - feel free to use this for monitoring your Taskcluster workers!

---

Built with ❤️ for Mozilla Release Engineering

**WorkerCTL** - Take control of your worker fleet
