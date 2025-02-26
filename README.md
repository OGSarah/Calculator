<div align="center">
  <img src="https://raw.githubusercontent.com/Pearljam66/Calculator/31bc2d31db020d9ab031a3e43799d7beb084db0c/Calculator/Calculator/Assets.xcassets/AppIcon.appiconset/calculator_any.png" width="150" style="border: 3px solid white; border-radius: 15px; vertical-align: middle; margin-right: 20px;">
  <h1 style="display: inline-block; vertical-align: middle;">Calculator</h1>
</div>

A simple SwiftUI calculator app that performs basic arithmetic operations and logs session data to a backend database.

## Setup

### iOS App:
1. Open in Xcode
2. Ensure network permissions are enabled
3. Build and run

### Backend:
1. Install Node.js
2. Run `npm install express sqlite3`
3. Run `node server.js`

## Requirements:
- Node.js v14+
- Xcode 16.2
- iOS 17.0+

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

## Back-end Technical Details
- GO
- Node.js
- SQLite




