# SmartSpend — AI-Powered Personal Finance Assistant

## Developer

- **Joshua Day** — dayj16@mymail.nku.edu

## Project Description

SmartSpend is a cross-platform mobile application that uses artificial intelligence and machine learning to help individuals with poor spending habits build better financial behaviors. The app analyzes a user's spending data, identifies problem areas, generates personalized budgets, and provides actionable recommendations to help users save money over time.

## Problem Domain

Many people struggle with managing their finances effectively:

- They overspend in certain categories without realizing it.
- They fail to maintain a consistent budget over time.
- Existing budgeting apps require too much manual input and provide generic advice that doesn't adapt to individual behavior.
- Financial stress is one of the leading causes of anxiety, and people need tools that actively help them improve rather than just track numbers.

SmartSpend solves this by using machine learning to learn from a user's spending patterns and provide personalized, adaptive budgeting guidance.

---

## Tech Stack

| Layer           | Technology                                   |
| --------------- | -------------------------------------------- |
| **Mobile App**  | Flutter 3 / Dart (Provider state management) |
| **Backend API** | Python 3.12 · FastAPI · Uvicorn              |
| **Database**    | PostgreSQL 16                                |
| **Auth**        | JWT (PyJWT) · bcrypt via Passlib             |
| **Containers**  | Docker Compose (API + DB + pgAdmin)          |
| **Validation**  | Pydantic v2                                  |

---

## Features and Requirements

### Implemented Features

#### Backend (Fully Functional)

1. **User Authentication** — Secure JWT-based register / login with bcrypt-hashed passwords and 24-hour token expiry.
2. **Transaction Management** — Create, list (with optional `?category=` filter ordered by date), and delete transactions per user.
3. **Budget Management** — Full CRUD for per-category budgets with configurable periods and partial updates.
4. **Goal Tracking** — Full CRUD for savings goals with numeric progress tracking ordered by target date.
5. **Savings Recommendations** — Read endpoint for personalized savings suggestions seeded from spending data.

#### Frontend (Flutter — Fully Scaffolded)

6. **11-Screen Navigation** — Complete screen set: Login, Register, Home/Dashboard, Transactions, Add Transaction, Budget, Goals, Analytics, Recommendations, Settings, and Account.
7. **Bottom Navigation** — 5-tab `BottomNavigationBar` with `IndexedStack` (Home, Transactions, Budget, Goals, Account).
8. **Spending Analytics** — Category breakdown progress bars, period selector (Week/Month/Year), month-over-month comparison view.
9. **Theming** — Material 3 light and dark mode (follows system preference), seeded from a custom green color palette.
10. **Reusable Widget Library** — `SummaryCard`, `TransactionTile`, `GoalProgressCard`, `CategoryCard`, `LoadingOverlay`.

> **Current State:** The backend API is fully operational. The Flutter frontend is completely scaffolded with all screens, navigation, models, services, and providers in place. Most screens currently display rich sample data (`lib/data/sample_data.dart`) while provider-to-screen wiring is finalized in Sprint 2.

### Planned / In Progress

- Live provider integration (connecting all screens to real API data).
- ML-powered automatic transaction categorization.
- Budget adaptation that learns from new spending data over time.
- Push notifications when approaching or exceeding budget limits.
- Persistent auth state (secure token storage across app restarts).
- Data import from external sources (CSV / bank feeds).

**Total: 10 features, 14 requirements**

### Non-Functional Requirements

- Cross-platform mobile application (Flutter/Dart — iOS, Android, Web).
- User passwords stored with bcrypt hashing; API secured with JWT bearer tokens.
- PostgreSQL data integrity enforced via foreign keys and UUID primary keys.
- The application should respond to user actions within 2 seconds.
- The ML model should process and categorize transactions with at least 80% accuracy.

---

## Project Structure

```
├── lib/                    # Flutter application source
│   ├── main.dart           # Entry point
│   ├── app.dart            # Root widget, MultiProvider setup, routing
│   ├── config/             # Theme, colors, constants, route definitions
│   │   ├── colors.dart     # AppColors (primary green, income/expense/warning)
│   │   ├── constants.dart  # AppConstants (apiBaseUrl, spacing, radius)
│   │   ├── routes.dart     # AppRoutes — 11 named routes
│   │   └── theme.dart      # AppTheme — Material 3 light & dark ThemeData
│   ├── models/             # Immutable Dart data classes (fromJson, toJson, copyWith)
│   │   ├── user.dart
│   │   ├── transaction.dart
│   │   ├── budget.dart
│   │   ├── goal.dart       # includes progressPercent, isCompleted, icon
│   │   ├── recommendation.dart
│   │   ├── budget_item.dart  # view model: spent/limit ratio, isOverBudget
│   │   └── category_breakdown.dart  # view model for analytics charts
│   ├── providers/          # ChangeNotifier state management
│   │   ├── auth_provider.dart
│   │   ├── transaction_provider.dart
│   │   ├── budget_provider.dart
│   │   └── goal_provider.dart
│   ├── services/           # HTTP API client & per-resource service classes
│   │   ├── api_client.dart      # JWT-injecting HTTP wrapper
│   │   ├── auth_service.dart
│   │   ├── transaction_service.dart
│   │   ├── budget_service.dart
│   │   ├── goal_service.dart
│   │   └── recommendation_service.dart
│   ├── screens/            # 11 UI screens
│   │   ├── auth/           # login, register
│   │   ├── home/           # dashboard + bottom nav host
│   │   ├── transactions/   # list view + add transaction form
│   │   ├── budget/         # per-category budget overview
│   │   ├── goals/          # savings goals with progress
│   │   ├── analytics/      # category breakdowns, period selector
│   │   ├── recommendations/  # AI-powered savings suggestions
│   │   ├── settings/       # app preferences & toggles
│   │   └── account/        # profile & navigation hub
│   ├── widgets/            # Reusable UI components
│   │   ├── summary_card.dart
│   │   ├── transaction_tile.dart
│   │   ├── goal_progress_card.dart
│   │   ├── category_card.dart
│   │   └── loading_overlay.dart
│   ├── utils/              # Formatters, validators, categories, error helpers
│   │   ├── formatters.dart      # currency, date, percent (via intl)
│   │   ├── validators.dart      # form field validators (email, password, amount)
│   │   ├── categories.dart      # 8 category constants, icon/color maps
│   │   └── error_helpers.dart   # formatError strips "Exception: " prefix
│   └── data/
│       └── sample_data.dart     # Static demo data used while provider wiring is in progress
├── backend/                # FastAPI backend
│   ├── Dockerfile          # python:3.12-slim, Uvicorn on port 8000
│   ├── requirements.txt
│   └── app/
│       ├── main.py         # FastAPI app, CORS middleware, router mounts, /health
│       ├── auth.py         # JWT creation & HTTPBearer verification dependency
│       ├── database.py     # psycopg2 connection pool, query/execute helpers
│       ├── schemas.py      # Pydantic v2 request/response models
│       └── routers/        # auth, transactions, budgets, goals, recommendations
├── docker/
│   ├── init.sql            # Schema DDL (5 tables, UUID PKs, FK cascade)
│   └── seed.sql            # Demo user + 30 transactions + budgets/goals/recommendations
├── docker-compose.yml      # PostgreSQL 16 + FastAPI + pgAdmin services
├── scripts/
│   ├── start.ps1           # One-command dev startup (PowerShell)
│   └── start.sh            # One-command dev startup (bash / WSL / macOS)
├── test/                   # Flutter unit & widget tests
│   ├── models/             # transaction, user, budget, goal, recommendation
│   ├── utils/              # validators, error_helpers
│   └── widgets/            # summary_card
├── integration_test/       # Flutter integration test (full app smoke test)
└── docs/                   # Project documentation & presentations
    └── presentation/
        └── sprint1_presentation.md
```

---

## Data Model

Five core tables, all using UUID primary keys and `ON DELETE CASCADE` foreign keys:

| Table               | Key Columns                                                                                    |
| ------------------- | ---------------------------------------------------------------------------------------------- |
| **users**           | `id`, `email` (UNIQUE), `name`, `password` (bcrypt), `created_at`                              |
| **transactions**    | `id`, `user_id` → users, `amount`, `category`, `description`, `date`                           |
| **budgets**         | `id`, `user_id` → users, `category`, `limit_amount`, `period`, `created_at`                    |
| **goals**           | `id`, `user_id` → users, `target_amount`, `target_date`, `description`, `progress`             |
| **recommendations** | `id`, `user_id` → users, `category`, `title`, `description`, `potential_savings`, `created_at` |

Schema definition: [docker/init.sql](docker/init.sql) · Seed data: [docker/seed.sql](docker/seed.sql)

---

## API Endpoints

All routes are mounted under `/api/v1`. Authenticated endpoints require an `Authorization: Bearer <JWT>` header.

| Method   | Path                        | Auth | Description                                      |
| -------- | --------------------------- | :--: | ------------------------------------------------ |
| `GET`    | `/health`                   |  —   | Health check                                     |
| `POST`   | `/api/v1/auth/register`     |  —   | Create account, receive JWT + user               |
| `POST`   | `/api/v1/auth/login`        |  —   | Authenticate, receive JWT + user                 |
| `GET`    | `/api/v1/transactions`      |  ✔   | List transactions (optional `?category=` filter) |
| `POST`   | `/api/v1/transactions`      |  ✔   | Create a transaction                             |
| `DELETE` | `/api/v1/transactions/{id}` |  ✔   | Delete a transaction                             |
| `GET`    | `/api/v1/budgets`           |  ✔   | List budgets                                     |
| `POST`   | `/api/v1/budgets`           |  ✔   | Create a budget                                  |
| `PUT`    | `/api/v1/budgets/{id}`      |  ✔   | Partial-update a budget                          |
| `DELETE` | `/api/v1/budgets/{id}`      |  ✔   | Delete a budget                                  |
| `GET`    | `/api/v1/goals`             |  ✔   | List goals (ordered by target date)              |
| `POST`   | `/api/v1/goals`             |  ✔   | Create a goal                                    |
| `PUT`    | `/api/v1/goals/{id}`        |  ✔   | Partial-update a goal                            |
| `DELETE` | `/api/v1/goals/{id}`        |  ✔   | Delete a goal                                    |
| `GET`    | `/api/v1/recommendations`   |  ✔   | List recommendations                             |

Interactive API docs available at `http://localhost:8000/api/v1/docs` when the backend is running.

---

## Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.10
- **Docker** & **Docker Compose**
- A `.env` file in the project root (see below)

### Environment Variables

Create a `.env` file (see [`.env.example`](.env.example)):

```env
POSTGRES_USER=smartspend
POSTGRES_PASSWORD=smartspend_dev
POSTGRES_DB=smartspend
JWT_SECRET=change-me-in-production
PGADMIN_EMAIL=admin@smartspend.dev
PGADMIN_PASSWORD=admin
```

### Quick Start (one command)

Start the database, API, and Flutter app all at once:

**Windows (PowerShell):**

```powershell
.\scripts\start.ps1                  # prompts if multiple devices
.\scripts\start.ps1 -Device chrome   # launch directly in Chrome
```

**WSL / macOS / Linux:**

```bash
./scripts/start.sh                   # prompts if multiple devices
./scripts/start.sh chrome            # launch directly in Chrome
```

The script starts Docker Compose, waits for the API to become healthy, then runs `flutter pub get` and `flutter run`.

### Run the Backend

```bash
docker compose up -d          # starts PostgreSQL, FastAPI, and pgAdmin
```

| Service            | URL                               |
| ------------------ | --------------------------------- |
| API                | http://localhost:8000             |
| API Docs (Swagger) | http://localhost:8000/api/v1/docs |
| pgAdmin            | http://localhost:5050             |

The seed script automatically creates a demo account:

- **Email:** `demo@smartspend.dev`
- **Password:** `password123`

### Run the Flutter App

```bash
flutter pub get
flutter run                   # launches on connected device / emulator
```

### Run Tests

```bash
# Flutter unit & widget tests
flutter test

# Flutter integration tests
flutter test integration_test/
```

---

## Tests

### Unit & Widget Tests (`test/`)

- **Model tests** — `fromJson`/`toJson` round-trips and computed properties for `Transaction`, `Budget`, `Goal`, `Recommendation`, `User`.
- **Utility tests** — Form validators (email, password min-length, numeric amount) and `formatError` error string helper.
- **Widget tests** — `SummaryCard` renders title and value text correctly.

### Integration Tests (`integration_test/`)

- Full app smoke test — launches `SmartSpendApp`, verifies the app title renders. Extended E2E flow tests planned for Sprint 2.

### Acceptance Criteria

- Verify that users can successfully input spending data and see it categorized.
- Verify that the ML model generates a budget that reflects the user's actual spending patterns.
- Verify that savings recommendations are relevant to the user's top spending categories.
- Verify that alerts trigger when a user approaches their budget limit.

---

## Schedule & Milestones

### Sprint 1 (Weeks 4–8) — Complete

- Week 4: Project setup (GitHub, Docker, PostgreSQL schema, Flutter & FastAPI scaffolding)
- Week 5: User authentication (JWT endpoints, login/register screens, init.sql + seed.sql)
- Week 6: Transaction management (CRUD API, Flutter transaction list & add screens)
- Week 7: Dashboard & visualization (budget/goals/recommendations API, spending analytics screens)
- Week 8: Testing, bug fixes, UI polish (account, settings, analytics), Sprint 1 Presentation

### Sprint 2 (Weeks 9–15)

- Week 9: Live provider integration — connect all Flutter screens to real API data
- Week 10: Persistent auth state (secure token storage) + ML categorization model
- Week 11: Budget adaptation system (ML-driven budget generation)
- Week 12: Savings recommendations engine (ML inference pipeline)
- Week 13: Alerts & push notifications when approaching budget limits
- Week 14: Flutter app polish, full integration testing, deployment
- Week 15: Final testing, deployment, Final Presentation (4/27, 4/29)

---

## Project Documentation

- [Sprint 1 Presentation](docs/presentation/sprint1_presentation.md)
- **Repositories:**
  - Capstone Project: https://github.com/Jolteer/ase485-capstone-finance-ml
  - Learning with AI: https://github.com/Jolteer/ase485-learning-with-ai
