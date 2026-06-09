<div align="center">
  <img src="/Screenshots/AppIcon.png" width="300" style="border: 3px solid white; border-radius: 15px; vertical-align: middle; margin-right: 20px;">
  <h1 style="display: inline-block; vertical-align: middle;">Calculator</h1>
</div>

A SwiftUI calculator built to demonstrate a clean, testable iOS architecture end to end: an MVVM front end backed by SwiftData for local persistence, with each session synced to a Go + SQLite backend when the app moves to the background. The arithmetic is deliberately simple — the interesting work is in the separation of concerns, the protocol-driven service layer, and the accessibility and test coverage around it.

[![Unit Tests](https://github.com/OGSarah/Calculator/actions/workflows/tests.yml/badge.svg)](https://github.com/OGSarah/Calculator/actions/workflows/tests.yml)

> **CI note:** The suite is green locally on the Xcode 27 / iOS 27 beta toolchain. The GitHub Actions runners don't yet ship that toolchain, so the badge will stay red until they do. This is a portfolio project rather than a shipping app, so I'm leaving CI as-is rather than pinning to an older SDK.

## Screenshots:

Here are some screenshots showcasing the app's features:

<div align="center">
  <div style="border: 2px solid white; border-radius: 10px;">
    <img width="20%" src="https://github.com/OGSarah/Calculator/blob/6dac41a4bad70e4db09a69d2934354fb1d012871/Screenshots/calculatorscreen_dark.png">
    <img width="20%" src="https://github.com/OGSarah/Calculator/blob/6dac41a4bad70e4db09a69d2934354fb1d012871/Screenshots/calculatorscreen_light.png">
    <img width="20%" src="https://github.com/OGSarah/Calculator/blob/6dac41a4bad70e4db09a69d2934354fb1d012871/Screenshots/nosessionhistory_dark.png">
    <img width="20%" src="https://github.com/OGSarah/Calculator/blob/6dac41a4bad70e4db09a69d2934354fb1d012871/Screenshots/nosessionhistory_light.png">
  </div>
</div>

<br><br> 

<div align="center">
  <div style="border: 2px solid white; border-radius: 10px;">
    <img width="20%" src="https://github.com/OGSarah/Calculator/blob/6dac41a4bad70e4db09a69d2934354fb1d012871/Screenshots/sessionhistory_dark.png">
    <img width="20%" src="https://github.com/OGSarah/Calculator/blob/6dac41a4bad70e4db09a69d2934354fb1d012871/Screenshots/sessionhistory_light.png">
  </div>
</div>

## Key Features:
- Basic arithmetic (add, subtract, multiply, divide) with a running history line above the result.
- Per-session usage tracking — every operation increments a counter on the active session.
- Local persistence via SwiftData, so session history survives relaunches.
- Background sync: session data is POSTed to the Go backend the moment the app resigns active.
- Session history sheet listing the current and prior sessions, sorted by most recently updated.
- Full Dark Mode support and a Liquid Glass material treatment on the display and controls.
- Accessibility built in: VoiceOver labels/values/traits and Dynamic Type via `@ScaledMetric`.

## Technologies:
- Swift 6
- SwiftUI
- SwiftData (local persistence)
- Swift Testing framework (unit tests)
- XCTest + XCUIAutomation (UI tests)
- Go + Gin + SQLite (backend)

### Focus Areas:
- A protocol-driven service layer so the view model never talks to a concrete store.
- Testability — dependencies are injected, not reached for, so the unit tests run against a mock.
- Accessibility as a first-class concern rather than an afterthought.
- A clear network/persistence boundary, with the backend sync isolated to a single service method.

## Data Source:
Session state lives in two places. The source of truth on-device is a SwiftData `SessionEntity` store, keyed by a unique `sessionId` generated per launch. When the app backgrounds, the current session is serialized and sent to the Go backend, which persists it to a SQLite database (`Backend/calculator.db`). The two stores are kept in sync but the app remains fully functional offline — the backend is a sink, not a dependency.

## Architecture & Design Patterns:
The app follows MVVM with a protocol-backed service layer.

- **View** (`CalculatorView`, `SessionHistorySheetView`) — pure SwiftUI, no business logic. State is held in an `@Observable` view model.
- **ViewModel** (`CalculatorViewModel`) — owns display state and calculation logic, and translates user input into session mutations. It depends on a `SessionService` protocol, defaulting to `SwiftDataManager.shared` but accepting any conforming type via its initializer.
- **Service** (`SessionService` protocol → `SwiftDataManager`) — the only layer that knows about SwiftData or the network. Swapping the implementation (e.g. for tests) is a one-line change.
- **Model** (`SessionEntity`, `SessionData`) — a SwiftData `@Model` for persistence and a `Codable` value type for the wire format, kept separate so the API contract and the storage schema can evolve independently.

This is what makes the view model trivial to test in isolation — `MockSessionService` stands in for the real store with no SwiftData or networking involved.

### Testing
- **Unit tests** (Swift Testing) cover the view model's calculation and session-tracking logic against `MockSessionService`, plus the `SessionData` encoding contract.
- **UI tests** (XCUIAutomation) drive the calculator through real input sequences and assert on the display, using accessibility identifiers as the contract between view and test.
- **Accessibility tests** verify VoiceOver labels/traits and that the UI holds up under Dynamic Type.

### Continuous Integration
GitHub Actions runs the unit test suite on every push (`.github/workflows/tests.yml`). See the CI note at the top of this README for why the badge currently reflects the runner toolchain rather than the code.

### Trade-offs and Decisions:
- **Integer-only arithmetic.** The math is intentionally minimal — division truncates and there's no floating point. The focus of this project is architecture and data flow, not building a full scientific calculator.
- **New session per launch.** Per the project brief, a fresh `sessionId` is minted on each launch rather than resuming the last one. This keeps the usage-tracking semantics simple and unambiguous.
- **Backend is fire-and-forget on background.** Sync happens on `willResignActive` rather than after every keystroke, trading real-time accuracy for far less network chatter and battery cost.
- **`localhost` backend.** The app points at `http://localhost:3000`, so it runs on the Simulator only. In a real deployment this would be an injected, environment-specific base URL behind real auth.
- **Completion handlers over async/await in the service.** The networking still uses `URLSession` completion handlers; migrating this layer to async/await is the most worthwhile next refactor (see below).

## Requirements
- macOS 27
- Xcode 27
- iOS 27
- Go 1.21+

## Setup

### Backend:
1. Install Go (1.21+): `brew install go` (macOS)
2. Navigate to `cd Backend`
3. Run `go mod tidy` to install dependencies.
5. Run `go run *.go` to start the server on `http://localhost:3000`

### iOS App:
1. Open `Calculator.xcodeproj` in Xcode.
2. Under `Signing & Capabilities` change the Team value to your development team.
3. Build and run on the iOS simulator. (Cannot be run on a real device because of the server local ip address. In a production scenario, the server would be publically accessible. In a dev environment, the server would be internally accessible.)
4. Perform a calculation or two. 
5. Once you swipe the app so that it goes into the background, you will see a message in the Xcode debug console, in the terminal where you started the backend server, and the backend SQLite `Calculator.db` will be updated.
6. You can view past sessions by selecting the `View Session Data` in the app; it will show the current session and the previous sessions in descending order by last updated date.

## Deliverables

### Database Schema:

**Table:  sessions**

| Column          | Data Type | Attributes                | Description                                |
|-----------------|-----------|---------------------------|--------------------------------------------|
| session_id      | TEXT      | PRIMARY KEY               | Unique identifier for each session         |
| add_count       | INTEGER   | DEFAULT 0                 | Number of addition operations performed    |
| subtract_count  | INTEGER   | DEFAULT 0                 | Number of subtraction operations performed |
| multiply_count  | INTEGER   | DEFAULT 0                 | Number of multiplication operations performed |
| divide_count    | INTEGER   | DEFAULT 0                 | Number of division operations performed    |
| last_updated    | DATETIME  | DEFAULT CURRENT_TIMESTAMP | Timestamp of the last update               |

### API Documentation:

#### POST /api/session

**Request Body:**

```json
  {
      "sessionId": "string",
      "addCount": integer,
      "subtractCount": integer,
      "multiplyCount": integer,
      "divideCount": integer,
      "lastUpdated": "string"  // ISO 8601 format, e.g., "2025-02-27T12:00:00Z"
  }
```

**Sample Data**

``` json
{
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "addCount": 3,
    "subtractCount": 1,
    "multiplyCount": 2,
    "divideCount": 0,
    "lastUpdated": "2025-02-26T10:00:00Z"
}
```

## Front-end Technical Details
- Written in Swift
- iOS
- SwiftUI
- MVVM Architecture
- SwiftLint
- Persists data locally via SwiftData and sends each session’s data to the backend once the app is about to go into the background.
- Creates a new session each time the app launches.

## Back-end Technical Details
- Written in Go
- Uses the Gin web framework for HTTP routing.
- Stores data in an SQLite database located at Backend/calculator.db.
- Implements basic authentication with hardcoded credentials (only done for this sample project, not something that would be done in development or production environments), though not currently applied to routes.
- Provides two endpoints:
  - POST /api/session: Saves session data to the database
  - GET /api/sessions: Retrieves all stored sessions (this was for my testing purposes)

## Next steps / what I'd do with more time:
- Migrate the `SessionService` networking from `URLSession` completion handlers to async/await and make `postSessionDataToBackend` an `async throws` call.
- Add a retry/queue for failed background syncs so data isn't lost when the backend is unreachable.
- Add test coverage on the Go backend (handler and persistence tests).
- Drive the backend base URL and credentials from configuration rather than hardcoding them.

## License

Released under the [MIT License](LICENSE). © 2026 SarahUniverse
