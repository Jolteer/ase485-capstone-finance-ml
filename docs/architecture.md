# SmartSpend — Architecture Overview

## Purpose

SmartSpend is an AI-powered personal finance tracker that helps users with poor spending habits build better financial behaviors. It analyzes spending patterns, generates personalized budgets, tracks savings goals, and delivers ML-driven recommendations.

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter Client                          │
│                                                             │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Screens   │  │  Providers   │  │    Services      │  │
│  │  (11 views) │◄─│ (6 notifiers)│◄─│  (HTTP layer)    │  │
│  └─────────────┘  └──────────────┘  └────────┬─────────┘  │
│                                               │             │
│  ┌─────────────────────────────────────────┐  │             │
│  │   Local Storage                          │  │             │
│  │  flutter_secure_storage (JWT/user cache) │  │             │
│  │  shared_preferences (settings)          │  │             │
│  └─────────────────────────────────────────┘  │             │
└───────────────────────────────────────────────┼─────────────┘
                                                │ HTTP/REST
                                                │ (JWT Bearer)
┌───────────────────────────────────────────────┼─────────────┐
│                  Docker Compose                │             │
│                                               ▼             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           FastAPI Backend  (:8000)                  │   │
│  │                                                     │   │
│  │   /api/v1/auth          /api/v1/transactions        │   │
│  │   /api/v1/budgets       /api/v1/goals               │   │
│  │   /api/v1/recommendations                           │   │
│  │                                                     │   │
│  │   auth.py (JWT)   database.py (connection pool)     │   │
│  └───────────────────────────┬─────────────────────────┘   │
│                              │ psycopg2                     │
│  ┌───────────────────────────▼─────────────────────────┐   │
│  │           PostgreSQL 16  (:5432)                    │   │
│  │                                                     │   │
│  │   users  transactions  budgets  goals               │   │
│  │   recommendations                                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           pgAdmin  (:5050)   [optional]             │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Frontend — Flutter

| Layer                | Technology                  | Version        |
| -------------------- | --------------------------- | -------------- |
| UI Framework         | Flutter / Dart              | ≥ 3.10 / ≥ 3.0 |
| State Management     | Provider (`ChangeNotifier`) | ^6.1.2         |
| HTTP Client          | `http` package              | ^1.2.0         |
| Secure Storage       | `flutter_secure_storage`    | ^9.2.2         |
| Preferences          | `shared_preferences`        | ^2.3.3         |
| Internationalization | `intl`                      | ^0.19.0        |
| Testing              | `flutter_test` + `mocktail` | SDK + ^0.3.0   |

### Backend — Python

| Layer           | Technology     | Version                   |
| --------------- | -------------- | ------------------------- |
| Framework       | FastAPI        | latest (requirements.txt) |
| Server          | Uvicorn        | latest                    |
| Database Driver | psycopg2       | latest                    |
| Auth            | PyJWT + bcrypt | latest                    |
| Validation      | Pydantic v2    | latest                    |

### Infrastructure

| Component        | Technology             |
| ---------------- | ---------------------- |
| Database         | PostgreSQL 16 (Alpine) |
| Containerization | Docker Compose         |
| DB Admin         | pgAdmin 4              |

---

## Flutter Application Layers

### 1. Screens (`lib/screens/`)

11 screens organized by feature domain. Each screen reads state from one or more `Provider`s and dispatches actions back through them. Screens do not interact with services directly.

```
screens/
├── auth/          login, register
├── home/          dashboard shell (BottomNavigationBar + IndexedStack)
├── transactions/  list + add/edit
├── budget/        per-category budget overview
├── goals/         savings goal tracking
├── analytics/     spending breakdowns + period comparison
├── recommendations/  ML-driven suggestions
├── settings/      app preferences
└── account/       user profile
```

### 2. Providers (`lib/providers/`)

Six `ChangeNotifier` providers registered at the app root via `MultiProvider`. Each provider:

- Holds the authoritative in-memory state for its domain
- Exposes `isLoading` and `error` for UI feedback
- Accepts an optional `service` constructor parameter for test mock injection

```
AuthProvider          → authentication state + JWT lifecycle
TransactionProvider   → transaction list
BudgetProvider        → budget list
GoalProvider          → goals list
RecommendationProvider → recommendations list
SettingsProvider      → dark mode, locale, notifications, biometric
```

### 3. Services (`lib/services/`)

A thin HTTP wrapper layer. All network calls go through `ApiClient`, which:

- Injects `Authorization: Bearer <token>` on every authenticated request
- Enforces a 15-second timeout
- Normalizes server error responses into `Exception` instances with clean messages
- Persists and restores the JWT token via `FlutterSecureStorage`

Domain services (`AuthService`, `TransactionService`, etc.) map REST responses to typed Dart model objects and throw descriptive exceptions on failure.

### 4. Models (`lib/models/`)

Immutable value objects. All implement `==`, `hashCode`, `fromJson`, `toJson`, and `copyWith`. Business logic is kept in computed properties (`isExpense`, `progressPercent`, `daysRemaining`, etc.), not in providers or services.

### 5. View Models (`lib/viewmodels/`)

Lightweight UI-only composites derived from domain models — no JSON serialization, no persistence. Used to pre-compute display values (ratios, over-budget flags) before passing to widgets.

### 6. Widgets (`lib/widgets/`)

Five reusable, stateless UI components used across multiple screens:

| Widget             | Used On                                    |
| ------------------ | ------------------------------------------ |
| `SummaryCard`      | Home dashboard                             |
| `TransactionTile`  | Transaction list, home recent transactions |
| `GoalProgressCard` | Goals screen                               |
| `CategoryCard`     | Analytics, budget screen                   |
| `LoadingOverlay`   | Any screen during async operations         |

---

## Backend Structure

```
backend/app/
├── main.py         FastAPI app initialization, CORS, router mounting, /health
├── auth.py         JWT creation (24h expiry), HTTPBearer verification dependency
├── database.py     psycopg2 connection pool, typed query/execute helpers
├── schemas.py      Pydantic v2 request + response models
└── routers/
    ├── auth.py            POST /register, POST /login
    ├── transactions.py    GET/POST/DELETE /transactions
    ├── budgets.py         GET/POST/PUT/DELETE /budgets
    ├── goals.py           GET/POST/PUT/DELETE /goals
    └── recommendations.py GET /recommendations
```

Authentication middleware (`auth.py`) provides a `get_current_user` FastAPI dependency injected into every protected route. All routes automatically filter results to the authenticated user's data.

---

## Database Schema

Five tables with UUID primary keys and `ON DELETE CASCADE` foreign keys:

```
users
  id (UUID PK), email (UNIQUE), name, password (bcrypt), created_at

transactions
  id (UUID PK), user_id → users, amount, category, description, date

budgets
  id (UUID PK), user_id → users, category, limit_amount, period, created_at

goals
  id (UUID PK), user_id → users, target_amount, target_date, description, progress

recommendations
  id (UUID PK), user_id → users, category, title, description, potential_savings, created_at
```

Schema is initialized by `docker/init.sql`. Seed data for development is in `docker/seed.sql` (demo account: `demo@smartspend.dev` / `password123`).

---

## Authentication Flow

```
Register/Login
     │
     ▼
POST /api/v1/auth/register (or /login)
     │
     ▼  200 OK → { token: "eyJ...", user: { id, email, name, createdAt } }
     │
     ▼
ApiClient.setToken(token) → FlutterSecureStorage.write("auth_token")
AuthProvider.currentUser = User.fromJson(user)
     │
     ▼
Every subsequent request: Authorization: Bearer <token>
     │
     ▼
App restart: ApiClient.tryRestoreToken() reads token from secure storage
             AuthProvider.tryRestore() → still authenticated (no re-login)
```

---

## State Management Flow

```
User action (e.g., add transaction)
     │
     ▼
Screen calls provider.addTransaction(data)
     │
     ▼
Provider sets isLoading = true → notifyListeners()
     │
     ▼
Provider calls service.createTransaction(data)
     │
     ▼
Service calls apiClient.post('/transactions', body)
     │
     ├── Success → Provider updates list, clears error, isLoading = false
     │             notifyListeners() → screen rebuilds
     │
     └── Failure → Provider sets error message, isLoading = false
                   notifyListeners() → screen shows error
```

---

## Configuration

### Flutter (build-time)

Configured via `--dart-define` flags at build/run time. No `.env` file is read by Flutter.

| Define         | Default                        | Purpose              |
| -------------- | ------------------------------ | -------------------- |
| `API_BASE_URL` | `http://localhost:8000/api/v1` | Backend API base URL |

Example:

```bash
flutter run --dart-define=API_BASE_URL=https://api.myapp.com/api/v1
```

### Backend / Docker (runtime)

Configured via `.env` file (copied from `.env.example` by setup scripts):

| Variable            | Purpose                                       |
| ------------------- | --------------------------------------------- |
| `POSTGRES_USER`     | DB username                                   |
| `POSTGRES_PASSWORD` | DB password                                   |
| `POSTGRES_DB`       | DB name                                       |
| `JWT_SECRET`        | JWT signing secret (use a long random string) |
| `PGADMIN_EMAIL`     | pgAdmin login                                 |
| `PGADMIN_PASSWORD`  | pgAdmin password                              |
