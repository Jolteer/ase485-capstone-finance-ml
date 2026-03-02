# SmartSpend — AI-Powered Personal Finance Assistant

## Developer

- **Josh**

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

| Layer | Technology |
|-------|------------|
| **Mobile App** | Flutter 3 / Dart (Provider state management) |
| **Backend API** | Python 3.12 · FastAPI · Uvicorn |
| **Database** | PostgreSQL 16 |
| **Auth** | JWT (PyJWT) · bcrypt via Passlib |
| **Containers** | Docker Compose (API + DB + pgAdmin) |

---

## Features and Requirements

### Implemented Features

1. **User Authentication** — Secure JWT-based register / login flow with hashed passwords.
2. **Transaction Management** — Create, list (with category filter), and delete spending transactions.
3. **Budget Management** — Create, update, and delete per-category budgets with configurable periods.
4. **Goal Tracking** — Create, update, and delete savings goals with progress tracking.
5. **Savings Recommendations** — View ML-generated, personalized savings recommendations.
6. **Spending Visualization** — Dashboard with summary cards, category breakdowns, and spending charts.
7. **Analytics Screen** — Dedicated analytics view for deeper spending insights.
8. **Multi-Screen Navigation** — Bottom navigation across Home, Transactions, Budget, Goals, and Account tabs.
9. **Theming** — Light and dark mode support (follows system preference).
10. **Settings & Account** — Account management and application settings screens.

### Planned / In Progress

- ML-powered automatic transaction categorization.
- Budget adaptation that learns from new spending data over time.
- Push notifications when approaching or exceeding budget limits.
- Data import from external sources (CSV / bank feeds).

**Total: 10 features, 14 requirements**

### Non-Functional Requirements

- Cross-platform mobile application (Flutter/Dart — iOS, Android, Web).
- User passwords stored with bcrypt hashing; API secured with JWT bearer tokens.
- PostgreSQL data integrity enforced via foreign keys and indexes.
- The application should respond to user actions within 2 seconds.
- The ML model should process and categorize transactions with at least 80% accuracy.

---

## Project Structure

```
├── lib/                    # Flutter application source
│   ├── main.dart           # Entry point
│   ├── app.dart            # Root widget, providers, routing
│   ├── config/             # Theme, colors, constants, route definitions
│   ├── models/             # Dart data classes (User, Transaction, Budget, Goal, …)
│   ├── providers/          # ChangeNotifier state management (auth, transactions, budgets, goals)
│   ├── services/           # API client & per-resource service classes
│   ├── screens/            # UI screens (home, auth, transactions, budget, goals, analytics, …)
│   ├── widgets/            # Reusable UI components (SummaryCard, TransactionTile, …)
│   └── utils/              # Validators, error helpers, category utilities
├── backend/                # FastAPI backend
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── main.py         # FastAPI app, CORS, router mounts
│       ├── auth.py         # JWT creation & verification
│       ├── database.py     # psycopg2 connection pool, query/execute helpers
│       ├── schemas.py      # Pydantic request/response models
│       └── routers/        # auth, transactions, budgets, goals, recommendations
├── docker/                 # SQL init & seed scripts
│   ├── init.sql            # Schema creation (DDL)
│   └── seed.sql            # Sample data
├── docker-compose.yml      # PostgreSQL + FastAPI + pgAdmin
├── test/                   # Flutter unit & widget tests
├── integration_test/       # Flutter integration tests
└── docs/                   # Project documentation & presentations
```

---

## Data Model

Five core tables, all using UUID primary keys:

| Table | Key Columns |
|-------|-------------|
| **users** | `id`, `email`, `name`, `password`, `created_at` |
| **transactions** | `id`, `user_id` → users, `amount`, `category`, `description`, `date` |
| **budgets** | `id`, `user_id` → users, `category`, `limit_amount`, `period`, `created_at` |
| **goals** | `id`, `user_id` → users, `target_amount`, `target_date`, `description`, `progress` |
| **recommendations** | `id`, `user_id` → users, `category`, `title`, `description`, `potential_savings`, `created_at` |

Schema definition: [docker/init.sql](docker/init.sql)

---

## API Endpoints

All routes are mounted under `/api/v1`. Authenticated endpoints require a `Bearer <JWT>` header.

| Method | Path | Auth | Description |
|--------|------|:----:|-------------|
| `GET` | `/health` | — | Health check |
| `POST` | `/api/v1/auth/register` | — | Create account, receive JWT |
| `POST` | `/api/v1/auth/login` | — | Authenticate, receive JWT |
| `GET` | `/api/v1/transactions` | ✔ | List transactions (optional `?category=` filter) |
| `POST` | `/api/v1/transactions` | ✔ | Create a transaction |
| `DELETE` | `/api/v1/transactions/{id}` | ✔ | Delete a transaction |
| `GET` | `/api/v1/budgets` | ✔ | List budgets |
| `POST` | `/api/v1/budgets` | ✔ | Create a budget |
| `PUT` | `/api/v1/budgets/{id}` | ✔ | Update a budget |
| `DELETE` | `/api/v1/budgets/{id}` | ✔ | Delete a budget |
| `GET` | `/api/v1/goals` | ✔ | List goals |
| `POST` | `/api/v1/goals` | ✔ | Create a goal |
| `PUT` | `/api/v1/goals/{id}` | ✔ | Update a goal |
| `DELETE` | `/api/v1/goals/{id}` | ✔ | Delete a goal |
| `GET` | `/api/v1/recommendations` | ✔ | List recommendations |

Interactive API docs available at `http://localhost:8000/api/v1/docs` when the backend is running.

---

## Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.10
- **Docker** & **Docker Compose**
- A `.env` file in the project root (see below)

### Environment Variables

Create a `.env` file:

```env
POSTGRES_USER=smartspend
POSTGRES_PASSWORD=smartspend_dev
POSTGRES_DB=smartspend
JWT_SECRET=change-me-in-production
PGADMIN_EMAIL=admin@smartspend.dev
PGADMIN_PASSWORD=admin
```

### Run the Backend

```bash
docker compose up -d          # starts PostgreSQL, FastAPI, and pgAdmin
```

| Service | URL |
|---------|-----|
| API | http://localhost:8000 |
| API Docs | http://localhost:8000/api/v1/docs |
| pgAdmin | http://localhost:5050 |

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

- **Model tests** — serialization & defaults for `Transaction`, `Budget`, `Goal`, `Recommendation`, `User`.
- **Utility tests** — input validators, error helpers.
- **Widget tests** — `SummaryCard` rendering.

### Integration Tests (`integration_test/`)

- End-to-end app test covering navigation flow.

### Acceptance Criteria

- Verify that users can successfully input spending data and see it categorized.
- Verify that the ML model generates a budget that reflects the user's actual spending patterns.
- Verify that savings recommendations are relevant to the user's top spending categories.
- Verify that alerts trigger when a user approaches their budget limit.

---

## Schedule & Milestones

### Sprint 1 (Weeks 4–8)

- Week 4: Project setup (Docker, database) + FastAPI foundation
- Week 5: User authentication + Transaction input
- Week 6: Import functionality + ML categorization model
- Week 7: Spending visualization + Dashboard UI
- Week 8: Testing, polish & Sprint 1 Presentation

### Sprint 2 (Weeks 9–15)

- Week 9: Budget generation ML model
- Week 10: Budget adaptation system
- Week 11: Savings recommendations engine
- Week 12: Goal setting & progress tracking
- Week 13: Alerts & notifications system
- Week 14: Flutter mobile app development & integration
- Week 15: Testing, deployment, Final Presentation (4/27, 4/29)

---

## Project Documentation

- [Project Plan Presentation (PPP)](docs/presentation/ppp_smartspend.md)
