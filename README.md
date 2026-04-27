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

| Layer            | Technology                                                                        |
| ---------------- | --------------------------------------------------------------------------------- |
| **Mobile App**   | Flutter 3 / Dart (Provider state management)                                      |
| **Backend API**  | Python 3.12 · FastAPI · Uvicorn                                                   |
| **Database**     | PostgreSQL 16                                                                     |
| **Auth**         | JWT (PyJWT) · bcrypt via Passlib · `flutter_secure_storage` (persistent sessions) |
| **Persistence**  | `shared_preferences` (settings), `flutter_secure_storage` (token + user cache)    |
| **Containers**   | Docker Compose (API + DB + pgAdmin)                                               |
| **Validation**   | Pydantic v2                                                                       |
| **Test Mocking** | `mocktail` (Flutter unit tests)                                                   |

---

## Features and Requirements

### Implemented Features

#### Backend (Fully Functional)

1. **User Authentication** — Secure JWT-based register / login with bcrypt-hashed passwords and 24-hour token expiry.
2. **Transaction Management** — Create, list (with optional `?category=` filter ordered by date), and delete transactions per user.
3. **Budget Management** — Full CRUD for per-category budgets with configurable periods and partial updates.
4. **Goal Tracking** — Full CRUD for savings goals with numeric progress tracking ordered by target date.
5. **Savings Recommendations** — Read endpoint for personalized savings suggestions seeded from spending data.

#### Frontend (Flutter — Sprint 2 In Progress)

6. **11-Screen Navigation** — Complete screen set: Login, Register, Home/Dashboard, Transactions, Add Transaction, Budget, Goals, Analytics, Recommendations, Settings, and Account.
7. **Bottom Navigation** — 5-tab `BottomNavigationBar` with `IndexedStack` (Home, Transactions, Budget, Goals, Account).
8. **Spending Analytics** — Category breakdown progress bars, period selector (Week/Month/Year), month-over-month comparison view.
9. **Theming** — Material 3 light and dark mode (toggleable via Settings and persisted); theme mode wired reactively through `SettingsProvider` → `MaterialApp.themeMode`.
10. **Reusable Widget Library** — `SummaryCard`, `TransactionTile`, `GoalProgressCard`, `CategoryCard`, `LoadingOverlay`.
11. **Persistent Auth State** — `AuthProvider.tryRestore` reads JWT and cached user from `flutter_secure_storage` on startup; bypasses login screen if session is still valid.
12. **Persisted Settings** — `SettingsProvider` backed by `SharedPreferences`: dark mode, notification preference, biometric-login toggle, and currency locale (propagated to `Formatters` in real time).
13. **6-Provider Architecture** — `SettingsProvider`, `AuthProvider`, `TransactionProvider`, `BudgetProvider`, `GoalProvider`, and `RecommendationProvider` registered in `MultiProvider`; `ApiClient` singleton injected via `Provider`.

> **Current State:** The backend API is fully operational with 18 endpoints including 3 ML-powered endpoints. The Flutter frontend has all 11 screens connected to live API data with 6 providers. ML features (categorization, budget generation, recommendations), budget alerts, persistent auth, and persisted settings are all complete.

#### Sprint 2 Features (Delivered)

14. **ML Transaction Categorization** — TF-IDF + Naive Bayes pipeline (scikit-learn) auto-categorizes transactions from description text. Standalone `/ml/categorize` endpoint and integrated into POST `/transactions` when category is omitted. **Eight categories:** Food, Entertainment, Bills, Shopping, Transportation, Healthcare, Education, Other.
15. **ML Budget Generation** — Analyses transaction history per category and suggests monthly budgets with 10% buffer. POST `/ml/budgets/generate` replaces existing budgets with ML suggestions.
16. **ML Savings Recommendations** — Rule-based engine evaluating over-budget categories, spending spikes, missing budgets, and income ratio. POST `/ml/recommendations/generate` produces personalised tips.
17. **Budget Alerts** — Client-side alert system detecting budget usage at 80% (warning) and 100% (danger). Alert banners on Home dashboard, notification bell with badge count, and bottom-sheet detail view.
18. **Persistent Auth** — `AuthProvider.tryRestore` reads JWT and cached user from `flutter_secure_storage` on startup; bypasses login screen if session is valid.
19. **Persisted Settings** — `SettingsProvider` backed by `SharedPreferences`: dark mode, notifications, biometric toggle, currency locale.

### Planned / Future

- Data import from external sources (CSV / bank feeds).
- Firebase push notifications for real-time alerts.
- Adaptive budgets that adjust month-to-month automatically.
- Deep learning categorization (BERT embeddings).

**Total: 19 features, 20 requirements**

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
│   ├── app.dart            # Root widget, MultiProvider + auth-guard startup
│   ├── config/             # Theme, colors, constants, spacing, route definitions
│   │   ├── colors.dart     # AppColors (primary green, income/expense/warning)
│   │   ├── constants.dart  # AppConstants (apiBaseUrl, radius)
│   │   ├── spacing.dart    # AppSpacing — named pixel constants (xxs → xl)
│   │   ├── routes.dart     # AppRoutes — 11 named routes
│   │   └── theme.dart      # AppTheme — Material 3 light & dark ThemeData
│   ├── models/             # Immutable Dart data classes (fromJson, toJson, copyWith)
│   │   ├── user.dart
│   │   ├── transaction.dart
│   │   ├── budget.dart
│   │   ├── budget_item.dart        # ratio, isOverBudget, remainingAmount (budget + spend)
│   │   ├── category_breakdown.dart # analytics chart data
│   │   ├── goal.dart               # progressPercent, isCompleted, GoalCategory enum
│   │   └── recommendation.dart
│   ├── providers/          # ChangeNotifier state management (6 providers)
│   │   ├── settings_provider.dart  # SharedPreferences: dark mode, notifications, locale
│   │   ├── auth_provider.dart      # login, register, logout, tryRestore (secure storage)
│   │   ├── transaction_provider.dart
│   │   ├── budget_provider.dart
│   │   ├── goal_provider.dart
│   │   └── recommendation_provider.dart
│   ├── services/           # HTTP API client & per-resource service classes
│   │   ├── api_client.dart      # JWT-injecting HTTP wrapper, tryRestoreToken
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
│   │   ├── loading_overlay.dart
│   │   ├── budget_alert_banner.dart
│   │   └── notification_bell.dart
│   ├── utils/              # Formatters, validators, categories, helpers
│   │   ├── formatters.dart          # currency, date, percent (via intl); updateLocale
│   │   ├── validators.dart          # form field validators (email, password, amount)
│   │   ├── categories.dart          # 8 category constants, icon/color maps
│   │   ├── goal_helpers.dart        # GoalCategoryUi extension (icon per category)
│   │   ├── error_helpers.dart       # formatError strips "Exception: " prefix
│   │   ├── budget_helpers.dart      # budget alert / usage helpers
│   │   ├── spending_helpers.dart    # analytics / period spending helpers
│   │   └── provider_error_mixin.dart # shared provider error handling
├── backend/                # FastAPI backend
│   ├── Dockerfile          # python:3.12-slim, Uvicorn on port 8000
│   ├── requirements.txt
│   └── app/
│       ├── main.py         # FastAPI app, CORS middleware, router mounts, /health
│       ├── auth.py         # JWT creation & HTTPBearer verification dependency
│       ├── database.py     # psycopg2 connection pool, query/execute helpers
│       ├── schemas.py      # Pydantic v2 request/response models
│       ├── ml_engine.py    # ML: categorization, budget generation, recommendations
│       └── routers/        # auth, transactions, budgets, goals, recommendations, ml
├── docker/
│   ├── init.sql            # Schema DDL (5 tables, UUID PKs, FK cascade)
│   └── seed.sql            # Demo user + 30 transactions + budgets/goals/recommendations
├── docker-compose.yml      # PostgreSQL 16 + FastAPI + pgAdmin services
├── scripts/
│   ├── setup.ps1           # One-time new machine setup (PowerShell)
│   ├── setup.sh            # One-time new machine setup (bash / WSL / macOS)
│   ├── start.ps1           # Daily full-stack startup (PowerShell)
│   └── start.sh            # Daily full-stack startup (bash / WSL / macOS)
├── test/                   # Flutter unit & widget tests
│   ├── app_test.dart       # Root widget smoke test
│   ├── models/             # transaction, budget, goal, recommendation, user
│   ├── providers/          # auth, transaction, budget, goal providers
│   ├── services/           # api_client, auth, transaction, budget, goal, recommendation
│   ├── utils/              # validators, error_helpers, budget_helpers, spending_helpers
│   └── widgets/            # summary_card, transaction_tile, goal_progress_card,
│                           #   category_card, loading_overlay, budget_alert_banner
├── integration_test/       # Flutter integration test (full app smoke test)
└── docs/                   # Project documentation & presentations
    └── presentation/
        ├── sprint1_presentation.md
        └── sprint2_presentation.md
```

---

## Data Model

Five core tables, all using UUID primary keys and `ON DELETE CASCADE` foreign keys:

| Table               | Key Columns                                                                                    |
| ------------------- | ---------------------------------------------------------------------------------------------- |
| **users**           | `id`, `email` (UNIQUE), `name`, `password` (bcrypt), `created_at`                              |
| **transactions**    | `id`, `user_id` → users, `amount`, `category`, `description`, `date`                           |
| **budgets**         | `id`, `user_id` → users, `category`, `limit_amount`, `period`, `created_at`                    |
| **goals**           | `id`, `user_id` → users, `target_amount`, `target_date`, `description`, `progress`, `category` |
| **recommendations** | `id`, `user_id` → users, `category`, `title`, `description`, `potential_savings`, `created_at` |

Schema definition: [docker/init.sql](docker/init.sql) · Seed data: [docker/seed.sql](docker/seed.sql)

---

## API Endpoints

All routes are mounted under `/api/v1`. Authenticated endpoints require an `Authorization: Bearer <JWT>` header.

| Method   | Path                                  | Auth | Description                                             |
| -------- | ------------------------------------- | :--: | ------------------------------------------------------- |
| `GET`    | `/health`                             |  —   | Health check                                            |
| `POST`   | `/api/v1/auth/register`               |  —   | Create account, receive JWT + user                      |
| `POST`   | `/api/v1/auth/login`                  |  —   | Authenticate, receive JWT + user                        |
| `GET`    | `/api/v1/transactions`                |  ✔   | List transactions (optional `?category=` filter)        |
| `POST`   | `/api/v1/transactions`                |  ✔   | Create a transaction (auto-categorizes if no category)  |
| `PUT`    | `/api/v1/transactions/{id}`           |  ✔   | Partial-update a transaction                            |
| `DELETE` | `/api/v1/transactions/{id}`           |  ✔   | Delete a transaction                                    |
| `GET`    | `/api/v1/budgets`                     |  ✔   | List budgets                                            |
| `POST`   | `/api/v1/budgets`                     |  ✔   | Create a budget                                         |
| `PUT`    | `/api/v1/budgets/{id}`                |  ✔   | Partial-update a budget                                 |
| `DELETE` | `/api/v1/budgets/{id}`                |  ✔   | Delete a budget                                         |
| `GET`    | `/api/v1/goals`                       |  ✔   | List goals (ordered by target date)                     |
| `POST`   | `/api/v1/goals`                       |  ✔   | Create a goal                                           |
| `PUT`    | `/api/v1/goals/{id}`                  |  ✔   | Partial-update a goal                                   |
| `DELETE` | `/api/v1/goals/{id}`                  |  ✔   | Delete a goal                                           |
| `GET`    | `/api/v1/recommendations`             |  ✔   | List recommendations                                    |
| `POST`   | `/api/v1/ml/categorize`               |  ✔   | ML: predict category from description                   |
| `POST`   | `/api/v1/ml/budgets/generate`         |  ✔   | ML: generate budgets from transaction history           |
| `POST`   | `/api/v1/ml/recommendations/generate` |  ✔   | ML: generate savings recommendations from spending data |

Interactive API docs available at `http://localhost:8000/api/v1/docs` when the backend is running.

---

## Getting Started

### New Machine Setup (do this once per device)

**Step 1 — Install the two required tools** (everything else is handled by Docker):

| Tool                                                               | Download                                        |
| ------------------------------------------------------------------ | ----------------------------------------------- |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.10 | https://docs.flutter.dev/get-started/install    |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/)  | https://www.docker.com/products/docker-desktop/ |

**Step 2 — Run the setup script** from the repository root:

```powershell
# Windows (PowerShell)
.\scripts\setup.ps1
```

```bash
# macOS / Linux / WSL
./scripts/setup.sh
```

The setup script will:

- Verify Docker and Flutter are installed (with links if not)
- Copy `.env.example` → `.env` if no `.env` exists yet
- Run `flutter pub get` to pre-fetch packages

**Step 3 — Edit `.env`** and replace the `CHANGE_ME` placeholders (especially `JWT_SECRET`).

That's it. You're ready to run.

---

### Daily Dev Workflow

Start the full stack (database + API + Flutter app) with one command:

**Windows (PowerShell):**

```powershell
.\scripts\start.ps1                  # prompts if multiple devices
.\scripts\start.ps1 -Device chrome   # launch directly in Chrome
```

**macOS / Linux / WSL:**

```bash
./scripts/start.sh                   # prompts if multiple devices
./scripts/start.sh chrome            # launch directly in Chrome
```

The script starts Docker Compose, waits for the API to become healthy, then launches the Flutter app.

### Services

| Service            | URL                               |
| ------------------ | --------------------------------- |
| API                | http://localhost:8000             |
| API Docs (Swagger) | http://localhost:8000/api/v1/docs |
| pgAdmin            | http://localhost:5050             |

The seed script automatically creates a demo account:

- **Email:** `demo@smartspend.dev`
- **Password:** `password123`

### Run Tests

```bash
# Flutter unit & widget tests
flutter test

# Flutter integration tests
flutter test integration_test/
```

### Project Structure — Scripts

| Script                           | Purpose                        |
| -------------------------------- | ------------------------------ |
| `scripts/setup.ps1` / `setup.sh` | **One-time** new machine setup |
| `scripts/start.ps1` / `start.sh` | **Daily** full-stack startup   |

---

## Tests

### Flutter Unit & Widget Tests (`test/`)

- **App test** — `app_test.dart` verifies `SmartSpendApp` renders without crashing.
- **Model tests** — `fromJson`/`toJson` round-trips and computed properties for `Transaction`, `Budget`, `Goal`, `Recommendation`, and `User`.
- **Provider tests** — `AuthProvider`, `TransactionProvider`, `BudgetProvider`, and `GoalProvider` tested with `mocktail`-injected service mocks covering loading state, success, and error paths.
- **Service tests** — `ApiClient`, `AuthService`, `TransactionService`, `BudgetService`, `GoalService`, and `RecommendationService` tested against mocked HTTP responses.
- **Utility tests** — Form validators (email, password min-length, numeric amount), `formatError`, `budget_helpers`, and `spending_helpers`.
- **Widget tests** — `SummaryCard`, `TransactionTile`, `GoalProgressCard`, `CategoryCard`, `LoadingOverlay`, and `BudgetAlertBanner` render and behave correctly.

### Flutter Integration Tests (`integration_test/`)

- App launch tests — login screen renders, form fields present, navigation to register screen.
- Login form validation — empty email submit shows error.

### Backend Tests (`backend/tests/`)

- **ML Engine tests** — categorization accuracy across all 8 categories, confidence scores, budget generation from transaction history, recommendation generation rules.
- **API endpoint tests** — all CRUD endpoints (transactions, budgets, goals, recommendations) and ML endpoints (`/ml/categorize`, `/ml/budgets/generate`, `/ml/recommendations/generate`) tested with mocked database layer.

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

### Sprint 2 (Weeks 9–15) — Complete

- Week 9: Persistent auth (secure token storage), `SettingsProvider` (SharedPreferences), `RecommendationProvider`; expanded test suite (providers, services, all widgets)
- Week 10: Live provider integration — all Flutter screens connected to real API data
- Week 11: ML categorization engine (TF-IDF + Naive Bayes), auto-categorize on transaction create
- Week 12: ML budget generation + ML savings recommendations engine
- Week 13: Budget alerts (banners, notification bell with badge, bottom sheet details)
- Week 14: Backend pytest suite, integration tests, UI polish, cleanup
- Week 15: Final testing, deployment, Final Presentation (4/27, 4/29)

---

## Project Documentation

- [Sprint 1 Presentation](docs/presentation/sprint1_presentation.md)
- [Sprint 2 Final Presentation](docs/presentation/sprint2_presentation.md)
- **Repositories:**
  - Capstone Project: https://github.com/Jolteer/ase485-capstone-finance-ml
  - Learning with AI: https://github.com/Jolteer/ase485-learning-with-ai
