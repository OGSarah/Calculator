<div align="center">
  <img src="https://raw.githubusercontent.com/Pearljam66/Calculator/31bc2d31db020d9ab031a3e43799d7beb084db0c/Calculator/Calculator/Assets.xcassets/AppIcon.appiconset/calculator_any.png" width="150" style="border: 3px solid white; border-radius: 15px; vertical-align: middle; margin-right: 20px;">
  <h1 style="display: inline-block; vertical-align: middle;">Calculator</h1>
</div>

A simple SwiftUI calculator app that performs basic arithmetic operations and logs session data to a backend database.

## Setup

### iOS App:
1. Open `Calculator.xcodeproj` in Xcode.
2. Under `Signing & Capabilities` change the Team value to your development team.
3. Build and run on the iOS simulator.

### Backend:
1. Install Go (1.21+): `brew install go` (macOS)
2. Navigate to `backend/`
3. Run `go mod tidy` to install dependencies
4. Run `go run main.go` to start the server on `http://localhost:3000`

## Requirements:
- Xcode 16.2
- iOS 17.0+
- Go 1.21+

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
  "operations": {
    "+": number,
    "-": number,
    "*": number,
    "/": number
  }
}
{
  "message": "Session data updated"
}
```

**Sample Data**

``` json
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "add_count": 3,
  "subtract_count": 1,
  "multiply_count": 2,
  "divide_count": 0,
  "last_updated": "2025-02-26 10:00:00"
```

## Front-end Technical Details
- iOS
- SwiftUI
- MVVM Architecture
- Swiftlint
- Persists data locally via CoreData and syncs with the backend

## Back-end Technical Details
- GO
- SQLite
- The backend stores data in `backend/calculator.db`




