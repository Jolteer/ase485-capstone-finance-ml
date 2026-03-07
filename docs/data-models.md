# SmartSpend — Data Models

This document covers the domain models used across the Flutter client and the PostgreSQL database, including field definitions, enumerations, computed properties, and JSON serialization shapes.

---

## Domain Models (`lib/models/`)

All domain models are:

- **Immutable** — `const` constructors, all `final` fields
- **Equatable** — `==` and `hashCode` implemented via `Object.hash`
- **Serializable** — `fromJson(Map<String, dynamic>)` factory + `toJson()` method
- **Copyable** — `copyWith(...)` method for producing modified copies

---

### User

Represents an authenticated user account.

**Dart class:** `lib/models/user.dart`

| Field       | Type       | Description                |
| ----------- | ---------- | -------------------------- |
| `id`        | `String`   | UUID primary key           |
| `email`     | `String`   | Unique email address       |
| `name`      | `String`   | Display name               |
| `createdAt` | `DateTime` | Account creation timestamp |

**JSON shape**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "jane@example.com",
  "name": "Jane Smith",
  "createdAt": "2026-01-15T08:30:00Z"
}
```

---

### Transaction

Represents a single financial event (income or expense).

**Dart class:** `lib/models/transaction.dart`

| Field         | Type                  | Description                                              |
| ------------- | --------------------- | -------------------------------------------------------- |
| `id`          | `String`              | UUID primary key                                         |
| `userId`      | `String`              | Owner's user ID                                          |
| `amount`      | `double`              | Positive = income, Negative = expense. Must be non-zero. |
| `category`    | `TransactionCategory` | Spending category (see enum below)                       |
| `description` | `String`              | Human-readable label. Must be non-empty.                 |
| `date`        | `DateTime`            | When the transaction occurred                            |

**Computed properties**

| Property    | Type     | Description                       |
| ----------- | -------- | --------------------------------- |
| `isExpense` | `bool`   | `amount < 0`                      |
| `isIncome`  | `bool`   | `amount > 0`                      |
| `absAmount` | `double` | `amount.abs()` — display-friendly |

**Assertion:** `amount != 0` and `description` is non-empty (enforced in constructor).

**JSON shape**

```json
{
  "id": "txn001",
  "userId": "user456",
  "amount": -45.5,
  "category": "food",
  "description": "Grocery run",
  "date": "2026-03-03T18:00:00Z"
}
```

#### `TransactionCategory` enum

| Value            | Label             | Icon           | Color  |
| ---------------- | ----------------- | -------------- | ------ |
| `food`           | Food & Dining     | restaurant     | Green  |
| `entertainment`  | Entertainment     | movie          | Purple |
| `bills`          | Bills & Utilities | receipt_long   | Orange |
| `shopping`       | Shopping          | shopping_bag   | Blue   |
| `transportation` | Transportation    | directions_car | Teal   |
| `healthcare`     | Healthcare        | local_hospital | Red    |
| `education`      | Education         | school         | Indigo |
| `other`          | Other             | more_horiz     | Grey   |

UI extensions (icons and colors) are in `lib/utils/categories.dart`.

---

### Budget

Represents a spending limit for a single category over a defined period.

**Dart class:** `lib/models/budget.dart`

| Field         | Type                  | Description                            |
| ------------- | --------------------- | -------------------------------------- |
| `id`          | `String`              | UUID primary key                       |
| `userId`      | `String`              | Owner's user ID                        |
| `category`    | `TransactionCategory` | Category this budget applies to        |
| `limitAmount` | `double`              | Maximum allowed spending. Must be > 0. |
| `period`      | `BudgetPeriod`        | Recurrence period (see enum below)     |
| `createdAt`   | `DateTime`            | When the budget was created            |

**Assertion:** `limitAmount > 0`.

**JSON shape**

```json
{
  "id": "bgt001",
  "userId": "user456",
  "category": "food",
  "limitAmount": 500.0,
  "period": "monthly",
  "createdAt": "2026-01-01T00:00:00Z"
}
```

#### `BudgetPeriod` enum

| Value      | Label     |
| ---------- | --------- |
| `weekly`   | Weekly    |
| `biweekly` | Bi-Weekly |
| `monthly`  | Monthly   |
| `yearly`   | Yearly    |

---

### Goal

Represents a savings target with optional progress tracking.

**Dart class:** `lib/models/goal.dart`

| Field          | Type           | Description                                             |
| -------------- | -------------- | ------------------------------------------------------- |
| `id`           | `String`       | UUID primary key                                        |
| `userId`       | `String`       | Owner's user ID                                         |
| `targetAmount` | `double`       | Total savings target. Must be ≥ 0.                      |
| `targetDate`   | `DateTime`     | Deadline to reach the goal                              |
| `description`  | `String`       | Goal label (e.g., "Emergency Fund"). Must be non-empty. |
| `progress`     | `double`       | Amount saved so far. Must be ≥ 0.                       |
| `category`     | `GoalCategory` | Goal type (see enum below)                              |

**Computed properties**

| Property          | Type     | Description                                                              |
| ----------------- | -------- | ------------------------------------------------------------------------ |
| `progressPercent` | `double` | `progress / targetAmount` (can exceed 1.0 if over-saved)                 |
| `isCompleted`     | `bool`   | `progress >= targetAmount`                                               |
| `remainingAmount` | `double` | `max(0, targetAmount - progress)`                                        |
| `daysRemaining`   | `int`    | Calendar days until `targetDate` from today (can be negative if overdue) |

**JSON shape**

```json
{
  "id": "goal001",
  "userId": "user456",
  "targetAmount": 5000.0,
  "targetDate": "2026-12-31T00:00:00Z",
  "description": "Emergency fund",
  "progress": 1250.0,
  "category": "emergency"
}
```

#### `GoalCategory` enum

| Value       | Icon           |
| ----------- | -------------- |
| `vacation`  | flight_takeoff |
| `home`      | home           |
| `emergency` | security       |
| `car`       | directions_car |
| `other`     | flag           |

UI icons are in `lib/utils/goal_helpers.dart`.

---

### Recommendation

Represents an ML-generated savings suggestion.

**Dart class:** `lib/models/recommendation.dart`

| Field              | Type     | Description                                   |
| ------------------ | -------- | --------------------------------------------- |
| `id`               | `String` | UUID primary key                              |
| `category`         | `String` | Spending category this recommendation targets |
| `title`            | `String` | Short headline                                |
| `description`      | `String` | Full explanation and actionable advice        |
| `potentialSavings` | `double` | Estimated monthly savings if followed         |

**JSON shape**

```json
{
  "id": "rec001",
  "category": "food",
  "title": "Reduce dining out",
  "description": "You spent 40% more on dining this month. Consider meal prepping to save ~$120/month.",
  "potentialSavings": 120.0
}
```

---

## View Models (`lib/viewmodels/`)

View models are UI-only composites derived at presentation time from domain models. They have no JSON serialization and are never persisted.

### BudgetItem

Combines a `Budget` with its actual spending data for display in the budget screen.

**Dart class:** `lib/viewmodels/budget_item.dart`

| Field      | Type                  | Description                           |
| ---------- | --------------------- | ------------------------------------- |
| `category` | `TransactionCategory` | Budget category                       |
| `spent`    | `double`              | Actual spending in the current period |
| `limit`    | `double`              | Budget limit amount                   |

**Computed properties**

| Property          | Type     | Description                                                   |
| ----------------- | -------- | ------------------------------------------------------------- |
| `ratio`           | `double` | `(spent / limit).clamp(0.0, 1.0)` — for progress bar (0–100%) |
| `isOverBudget`    | `bool`   | `spent > limit`                                               |
| `remainingAmount` | `double` | `limit - spent` (negative if over budget)                     |

---

### CategoryBreakdown

Represents one category's share of total spending for analytics charts.

**Dart class:** `lib/viewmodels/category_breakdown.dart`

| Field      | Type     | Description                                          |
| ---------- | -------- | ---------------------------------------------------- |
| `category` | `String` | Category name                                        |
| `amount`   | `double` | Total spending in this category                      |
| `ratio`    | `double` | This category's fraction of total spending (0.0–1.0) |

---

## Database Schema

All tables use UUID primary keys (generated server-side) and `ON DELETE CASCADE` on foreign keys.

### `users`

```sql
CREATE TABLE users (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email      VARCHAR(255) UNIQUE NOT NULL,
  name       VARCHAR(255) NOT NULL,
  password   VARCHAR(255) NOT NULL,  -- bcrypt hash
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### `transactions`

```sql
CREATE TABLE transactions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount      DECIMAL(10, 2) NOT NULL,   -- positive=income, negative=expense
  category    VARCHAR(50) NOT NULL,
  description TEXT NOT NULL,
  date        TIMESTAMP WITH TIME ZONE NOT NULL
);
```

### `budgets`

```sql
CREATE TABLE budgets (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category     VARCHAR(50) NOT NULL,
  limit_amount DECIMAL(10, 2) NOT NULL,
  period       VARCHAR(20) NOT NULL,   -- weekly|biweekly|monthly|yearly
  created_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### `goals`

```sql
CREATE TABLE goals (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_amount DECIMAL(10, 2) NOT NULL,
  target_date   TIMESTAMP WITH TIME ZONE NOT NULL,
  description   TEXT NOT NULL,
  progress      DECIMAL(10, 2) DEFAULT 0,
  category      VARCHAR(50)
);
```

### `recommendations`

```sql
CREATE TABLE recommendations (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category          VARCHAR(50),
  title             VARCHAR(255) NOT NULL,
  description       TEXT NOT NULL,
  potential_savings DECIMAL(10, 2),
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## Field Mapping: API ↔ Flutter

JSON uses `snake_case` keys; Dart models use `camelCase` fields. The `fromJson` factories handle the conversion.

| JSON key            | Dart field         |
| ------------------- | ------------------ |
| `user_id`           | `userId`           |
| `limit_amount`      | `limitAmount`      |
| `target_amount`     | `targetAmount`     |
| `target_date`       | `targetDate`       |
| `created_at`        | `createdAt`        |
| `potential_savings` | `potentialSavings` |

All `DateTime` fields are parsed from ISO 8601 strings via `DateTime.parse()` and serialized back with `.toIso8601String()`.

---

## Validation Rules

### Client-side (`lib/utils/validators.dart`)

| Field            | Rule                            |
| ---------------- | ------------------------------- |
| Email            | Valid email format (`RegExp`)   |
| Password         | Minimum 8 characters            |
| Amount           | Parseable as `double`, non-zero |
| Required field   | Non-null, non-empty string      |
| Confirm password | Must match password field value |

### Model-level (`lib/models/`)

| Model                     | Assertion |
| ------------------------- | --------- |
| `Transaction.amount`      | `!= 0`    |
| `Transaction.description` | non-empty |
| `Budget.limitAmount`      | `> 0`     |
| `Goal.targetAmount`       | `>= 0`    |
| `Goal.progress`           | `>= 0`    |
| `Goal.description`        | non-empty |
