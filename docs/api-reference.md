# SmartSpend — API Reference

**Base URL:** `http://localhost:8000/api/v1`  
**Interactive docs:** `http://localhost:8000/api/v1/docs` (Swagger UI)  
**Auth:** JWT Bearer token — include `Authorization: Bearer <token>` on all protected endpoints.

---

## Health Check

### `GET /health`

Returns the API status. No authentication required.

**Response `200 OK`**

```json
{ "status": "ok" }
```

---

## Authentication

### `POST /api/v1/auth/register`

Register a new user account.

**Request body**

```json
{
  "name": "Jane Smith",
  "email": "jane@example.com",
  "password": "SecurePass123!"
}
```

| Field      | Type   | Constraints                                  |
| ---------- | ------ | -------------------------------------------- |
| `name`     | string | required, non-empty                          |
| `email`    | string | required, valid email format, must be unique |
| `password` | string | required, min 8 characters                   |

**Response `201 Created`**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "jane@example.com",
    "name": "Jane Smith",
    "createdAt": "2026-03-04T12:00:00Z"
  }
}
```

**Errors**

| Status | Condition                                |
| ------ | ---------------------------------------- |
| `400`  | Email already registered                 |
| `422`  | Validation error (missing/invalid field) |

---

### `POST /api/v1/auth/login`

Authenticate an existing user.

**Request body**

```json
{
  "email": "jane@example.com",
  "password": "SecurePass123!"
}
```

**Response `200 OK`**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "jane@example.com",
    "name": "Jane Smith",
    "createdAt": "2026-01-15T08:30:00Z"
  }
}
```

**Errors**

| Status | Condition           |
| ------ | ------------------- |
| `401`  | Invalid credentials |
| `422`  | Validation error    |

---

## Transactions

All transaction endpoints require authentication. Results are automatically scoped to the authenticated user.

### `GET /api/v1/transactions`

Fetch all transactions for the current user, ordered by date descending.

**Query parameters**

| Parameter  | Type              | Description                                                                                                                    |
| ---------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `category` | string (optional) | Filter by category. One of: `food`, `entertainment`, `bills`, `shopping`, `transportation`, `healthcare`, `education`, `other` |

**Response `200 OK`**

```json
[
  {
    "id": "abc123",
    "userId": "user456",
    "amount": -45.5,
    "category": "food",
    "description": "Grocery run",
    "date": "2026-03-03T18:00:00Z"
  }
]
```

**Amount convention:** Positive = income, Negative = expense.

---

### `POST /api/v1/transactions`

Create a new transaction.

**Request body**

```json
{
  "amount": -45.5,
  "category": "food",
  "description": "Grocery run",
  "date": "2026-03-03T18:00:00Z"
}
```

| Field         | Type              | Constraints                         |
| ------------- | ----------------- | ----------------------------------- |
| `amount`      | number            | required, non-zero                  |
| `category`    | string            | required, one of 8 valid categories |
| `description` | string            | required, non-empty                 |
| `date`        | ISO 8601 datetime | required                            |

**Response `201 Created`** — returns the created `Transaction` object.

**Errors**

| Status | Condition              |
| ------ | ---------------------- |
| `400`  | Invalid category value |
| `422`  | Validation error       |

---

### `DELETE /api/v1/transactions/{id}`

Delete a transaction by ID. Only the owning user can delete their own transactions.

**Path parameter:** `id` — UUID of the transaction.

**Response `204 No Content`**

**Errors**

| Status | Condition                                        |
| ------ | ------------------------------------------------ |
| `404`  | Transaction not found or belongs to another user |

---

## Budgets

### `GET /api/v1/budgets`

Fetch all budgets for the current user.

**Response `200 OK`**

```json
[
  {
    "id": "bgt001",
    "userId": "user456",
    "category": "food",
    "limitAmount": 500.0,
    "period": "monthly",
    "createdAt": "2026-01-01T00:00:00Z"
  }
]
```

**Valid `period` values:** `weekly`, `biweekly`, `monthly`, `yearly`

---

### `POST /api/v1/budgets`

Create a new budget.

**Request body**

```json
{
  "category": "food",
  "limitAmount": 500.0,
  "period": "monthly"
}
```

| Field         | Type   | Constraints                         |
| ------------- | ------ | ----------------------------------- |
| `category`    | string | required, one of 8 valid categories |
| `limitAmount` | number | required, must be > 0               |
| `period`      | string | required, one of 4 valid periods    |

**Response `201 Created`** — returns the created `Budget` object.

---

### `PUT /api/v1/budgets/{id}`

Update an existing budget. All fields are optional (partial update).

**Path parameter:** `id` — UUID of the budget.

**Request body** (any subset of fields)

```json
{
  "limitAmount": 600.0,
  "period": "monthly"
}
```

**Response `200 OK`** — returns the updated `Budget` object.

**Errors**

| Status | Condition        |
| ------ | ---------------- |
| `404`  | Budget not found |

---

### `DELETE /api/v1/budgets/{id}`

Delete a budget by ID.

**Response `204 No Content`**

**Errors**

| Status | Condition        |
| ------ | ---------------- |
| `404`  | Budget not found |

---

## Goals

### `GET /api/v1/goals`

Fetch all savings goals for the current user, ordered by target date.

**Response `200 OK`**

```json
[
  {
    "id": "goal001",
    "userId": "user456",
    "targetAmount": 5000.0,
    "targetDate": "2026-12-31T00:00:00Z",
    "description": "Emergency fund",
    "progress": 1250.0,
    "category": "emergency"
  }
]
```

**Valid `category` values:** `vacation`, `home`, `emergency`, `car`, `other`

---

### `POST /api/v1/goals`

Create a new savings goal.

**Request body**

```json
{
  "targetAmount": 5000.0,
  "targetDate": "2026-12-31T00:00:00Z",
  "description": "Emergency fund",
  "category": "emergency"
}
```

| Field          | Type              | Constraints                         |
| -------------- | ----------------- | ----------------------------------- |
| `targetAmount` | number            | required, ≥ 0                       |
| `targetDate`   | ISO 8601 datetime | required                            |
| `description`  | string            | required, non-empty                 |
| `category`     | string            | required, one of 5 valid categories |

**Response `201 Created`** — returns the created `Goal` object. `progress` defaults to `0`.

---

### `PUT /api/v1/goals/{id}`

Update an existing goal. All fields are optional (partial update). Use this to update `progress` when funds are added.

**Path parameter:** `id` — UUID of the goal.

**Request body** (any subset of fields)

```json
{
  "progress": 1500.0
}
```

**Response `200 OK`** — returns the updated `Goal` object.

**Errors**

| Status | Condition      |
| ------ | -------------- |
| `404`  | Goal not found |

---

### `DELETE /api/v1/goals/{id}`

Delete a goal by ID.

**Response `204 No Content`**

---

## Recommendations

### `GET /api/v1/recommendations`

Fetch ML-generated savings recommendations for the current user.

**Response `200 OK`**

```json
[
  {
    "id": "rec001",
    "category": "food",
    "title": "Reduce dining out",
    "description": "You spent 40% more on dining this month. Consider meal prepping to save ~$120/month.",
    "potentialSavings": 120.0
  }
]
```

Recommendations are generated server-side based on the user's spending history and budget configuration. This endpoint is read-only; recommendations are not created or deleted by the client.

---

## Error Responses

All errors follow a consistent JSON shape:

```json
{
  "detail": "Human-readable error message"
}
```

Validation errors (status `422`) return a list of field-level issues:

```json
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "value is not a valid email address",
      "type": "value_error.email"
    }
  ]
}
```

### Common HTTP Status Codes

| Code  | Meaning                                          |
| ----- | ------------------------------------------------ |
| `200` | OK — successful GET or PUT                       |
| `201` | Created — successful POST                        |
| `204` | No Content — successful DELETE                   |
| `400` | Bad Request — business rule violation            |
| `401` | Unauthorized — missing or invalid JWT token      |
| `404` | Not Found — resource doesn't exist               |
| `422` | Unprocessable Entity — schema validation failure |
| `500` | Internal Server Error — unhandled exception      |

---

## Token Lifecycle

- Tokens expire after **24 hours**.
- There is no refresh token endpoint; users must re-authenticate after expiry.
- The Flutter client stores the token in `FlutterSecureStorage` and restores it automatically on app restart (persistent login).
- On logout, the token is cleared from local storage client-side. There is no server-side token revocation.

---

## Development Notes

- Swagger UI is available at `http://localhost:8000/api/v1/docs` when the backend is running locally.
- The backend `GET` endpoints for transactions, budgets, goals, and recommendations all filter by the authenticated user ID at the SQL level — there is no risk of cross-user data leakage.
- The seed database includes a demo account (`demo@smartspend.dev` / `password123`) with 30 sample transactions, budgets, goals, and recommendations for testing.
