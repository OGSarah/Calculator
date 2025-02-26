# Calculator (currently WIP)

A simple SwiftUI calculator app that performs basic arithmetic operations and logs session data to a backend database.

## Setup

### iOS App
1. Open in Xcode
2. Ensure network permissions are enabled
3. Build and run

### Backend
1. Install Node.js
2. Run `npm install express sqlite3`
3. Run `node server.js`

## Requirements
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
