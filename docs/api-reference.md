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
    "created_at": "2026-03-04T12:00:00Z"
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
    "created_at": "2026-01-15T08:30:00Z"
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

| Parameter  | Type              | Description                                                                                                  |
| ---------- | ----------------- | ------------------------------------------------------------------------------------------------------------ |
| `category` | string (optional) | Filter by category name (must match stored values, e.g. `Food` or `food` depending on how rows were created) |

**Response `200 OK`**

```json
[
  {
    "id": "abc123",
    "user_id": "user456",
    "amount": -45.5,
    "category": "Food",
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
  "category": "Food",
  "description": "Grocery run",
  "date": "2026-03-03T18:00:00Z"
}
```

| Field         | Type              | Constraints                                                             |
| ------------- | ----------------- | ----------------------------------------------------------------------- |
| `amount`      | number            | required, non-zero                                                      |
| `category`    | string            | optional; omit or use `""` to auto-categorize from `description` via ML |
| `description` | string            | optional in schema; provide text when relying on auto-categorization    |
| `date`        | ISO 8601 datetime | optional; server defaults to current time if omitted                    |

**Response `201 Created`** — returns the created transaction (`snake_case` keys: `id`, `user_id`, `amount`, `category`, `description`, `date`).

**Errors**

| Status | Condition        |
| ------ | ---------------- |
| `422`  | Validation error |

---

### `PUT /api/v1/transactions/{id}`

Partially update a transaction. Only include fields that should change.

**Path parameter:** `id` — transaction ID.

**Request body** (any subset of fields)

```json
{
  "amount": -50.0,
  "category": "Food",
  "description": "Grocery run (updated)",
  "date": "2026-03-04T12:00:00Z"
}
```

| Field         | Type              | Constraints |
| ------------- | ----------------- | ----------- |
| `amount`      | number            | optional    |
| `category`    | string            | optional    |
| `description` | string            | optional    |
| `date`        | ISO 8601 datetime | optional    |

**Response `200 OK`** — returns the updated transaction.

**Errors**

| Status | Condition                                          |
| ------ | -------------------------------------------------- |
| `400`  | Empty body (no fields to update)                   |
| `404`  | Transaction not found or not owned by current user |
| `422`  | Validation error                                   |

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
    "user_id": "user456",
    "category": "Food",
    "limit_amount": 500.0,
    "period": "monthly",
    "created_at": "2026-01-01T00:00:00Z"
  }
]
```

**Valid `period` values:** `weekly`, `biweekly`, `monthly`, `yearly` (stored as free-form text; app typically uses `monthly`).

---

### `POST /api/v1/budgets`

Create a new budget.

**Request body**

```json
{
  "category": "Food",
  "limit_amount": 500.0,
  "period": "monthly"
}
```

| Field          | Type   | Constraints                     |
| -------------- | ------ | ------------------------------- |
| `category`     | string | required                        |
| `limit_amount` | number | required, must be > 0           |
| `period`       | string | optional; defaults to `monthly` |

**Response `201 Created`** — returns the created `Budget` object.

---

### `PUT /api/v1/budgets/{id}`

Update an existing budget. All fields are optional (partial update).

**Path parameter:** `id` — UUID of the budget.

**Request body** (any subset of fields)

```json
{
  "limit_amount": 600.0,
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
    "user_id": "user456",
    "target_amount": 5000.0,
    "target_date": "2026-12-31T00:00:00Z",
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
  "target_amount": 5000.0,
  "target_date": "2026-12-31T00:00:00Z",
  "description": "Emergency fund",
  "progress": 0,
  "category": "emergency"
}
```

| Field           | Type              | Constraints                                        |
| --------------- | ----------------- | -------------------------------------------------- |
| `target_amount` | number            | required, ≥ 0                                      |
| `target_date`   | ISO 8601 datetime | required                                           |
| `description`   | string            | optional in schema; use non-empty text in practice |
| `progress`      | number            | optional; defaults to `0`                          |
| `category`      | string            | optional; defaults to `other` if omitted           |

**Response `201 Created`** — returns the created goal (`snake_case` keys including `category`).

---

### `PUT /api/v1/goals/{id}`

Update an existing goal. All fields are optional (partial update). Use this to update `progress` when funds are added.

**Path parameter:** `id` — UUID of the goal.

**Request body** (any subset of fields)

```json
{
  "progress": 1500.0,
  "category": "emergency"
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
    "user_id": "user456",
    "category": "Food",
    "title": "Reduce dining out",
    "description": "You spent 40% more on dining this month. Consider meal prepping to save ~$120/month.",
    "potential_savings": 120.0,
    "created_at": "2026-04-01T00:00:00Z"
  }
]
```

Recommendations are generated server-side based on the user's spending history and budget configuration. This endpoint is read-only; recommendations are not created or deleted by the client. Use **`POST /api/v1/ml/recommendations/generate`** to refresh stored recommendations.

---

## Machine learning (`/api/v1/ml`)

All ML routes require authentication.

### `POST /api/v1/ml/categorize`

Predict a spending category from free-text description (TF-IDF + Multinomial Naive Bayes).

**Request body**

```json
{
  "description": "Grocery Store"
}
```

**Response `200 OK`**

```json
{
  "category": "Food",
  "confidence": 0.9821
}
```

---

### `POST /api/v1/ml/budgets/generate`

Analyse the current user's transactions and replace all budgets with ML-generated monthly limits (with a built-in buffer over historical averages).

**Request body:** none.

**Response `200 OK`** — array of budget objects (`snake_case`), same shape as `GET /api/v1/budgets`.

**Errors**

| Status | Condition                                   |
| ------ | ------------------------------------------- |
| `400`  | No transactions, or not enough expense data |

---

### `POST /api/v1/ml/recommendations/generate`

Analyse transactions and budgets, delete existing recommendations for the user, and insert freshly generated ones (rule-based engine).

**Request body:** none.

**Response `200 OK`** — array of recommendation objects (`snake_case`), same shape as `GET /api/v1/recommendations`.

**Errors**

| Status | Condition       |
| ------ | --------------- |
| `400`  | No transactions |

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
