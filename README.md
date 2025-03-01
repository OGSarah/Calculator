<div align="center">
  <img src="https://raw.githubusercontent.com/Pearljam66/Calculator/31bc2d31db020d9ab031a3e43799d7beb084db0c/Calculator/Calculator/Assets.xcassets/AppIcon.appiconset/calculator_any.png" width="150" style="border: 3px solid white; border-radius: 15px; vertical-align: middle; margin-right: 20px;">
  <h1 style="display: inline-block; vertical-align: middle;">Calculator</h1>
</div>

A simple SwiftUI calculator app that performs basic arithmetic operations, logs session data to a Go server and SQLite database, and stores sessions locally on the iOS device using Core Data.

## Screenshots:

Here are some screenshots showcasing the app's features:

<div align="center">
  <div style="border: 2px solid white; border-radius: 10px;">
    <img width="20%" src="https://raw.githubusercontent.com/Pearljam66/Calculator/main/Screenshots/calculatorscreen_dark.png">
    <img width="20%" src="https://raw.githubusercontent.com/Pearljam66/Calculator/main/Screenshots/calculatorscreen_light.png">
    <img width="20%" src="https://raw.githubusercontent.com/Pearljam66/Calculator/main/Screenshots/nosessionhistory_dark.png">
    <img width="20%" src="https://raw.githubusercontent.com/Pearljam66/Calculator/main/Screenshots/nosessionhistory_light.png">
  </div>
</div>

<br><br> 

<div align="center">
  <div style="border: 2px solid white; border-radius: 10px;">
    <img width="20%" src="https://raw.githubusercontent.com/Pearljam66/Calculator/main/Screenshots/sessionhistory_dark.png">
    <img width="20%" src="https://raw.githubusercontent.com/Pearljam66/Calculator/main/Screenshots/sessionhistory_light.png">
  </div>
</div>

## Requirements
- macOS
- Xcode 16.2
- iOS 17.0+
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
- Persists data locally via Core Data and sends each session’s data to the backend once the app is about to go into the background.
- Creates a new session each time the app launches.

## Back-end Technical Details
- Written in Go
- Uses the Gin web framework for HTTP routing.
- Stores data in an SQLite database located at Backend/calculator.db.
- Implements basic authentication with hardcoded credentials (only done for this sample project, not something that would be done in development or production environments), though not currently applied to routes.
- Provides two endpoints:
  - POST /api/session: Saves session data to the database
  - GET /api/sessions: Retrieves all stored sessions



