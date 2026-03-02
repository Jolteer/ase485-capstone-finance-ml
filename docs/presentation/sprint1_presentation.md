---
marp: true
theme: default
paginate: true
header: "Sprint 1 Presentation — SmartSpend"
footer: "Joshua Day | ASE 485 | Spring 2026"
---

# SmartSpend

## AI-Powered Personal Finance Assistant

**Sprint 1 Presentation**

Joshua Day
ASE 485 — Spring 2026

---

## The Problem

- Financial stress is a leading cause of anxiety
- People overspend without realizing it
- Existing budgeting apps require too much manual input
- Generic advice doesn't adapt to individual behavior

**SmartSpend** uses machine learning to provide personalized, adaptive budgeting guidance.

---

## My Approach

Build a **full-stack application** that learns from spending patterns:

- **Frontend:** Flutter (iOS, Android, Web)
- **Backend:** FastAPI (Python 3.12)
- **Database:** PostgreSQL 16
- **ML:** Scikit-learn for transaction categorization & budget generation _(Sprint 2)_
- **Deployment:** Docker Compose containers

---

## Architecture Overview

```
┌──────────────────┐     REST API      ┌──────────────────┐
│   Flutter App    │ ◄──────────────► │  FastAPI Backend  │
│ (iOS/Android/Web)│                   │  (Python)         │
└──────────────────┘                   └────────┬─────────┘
                                                │
                                       ┌────────▼─────────┐
                                       │   PostgreSQL DB   │
                                       │   (via Docker)    │
                                       └──────────────────┘
```

**State management:** Flutter Provider pattern — `ApiClient → Services → Providers → Screens`

---

## Sprint 1 Progress — Week by Week

| Week  | What I Built                                                                                                      |
| ----- | ----------------------------------------------------------------------------------------------------------------- |
| **4** | Project setup — GitHub repo, Docker Compose (PostgreSQL + pgAdmin), Flutter & FastAPI scaffolding                 |
| **5** | User authentication — JWT endpoints, bcrypt passwords, login/register screens, DB schema (`init.sql`, `seed.sql`) |
| **6** | Transaction management — full CRUD API, Flutter transaction list & add-transaction screens                        |
| **7** | Dashboard & visualization — budgets/goals/recommendations API + services, analytics & spending breakdown screens  |
| **8** | Testing suite, bug fixes, UI polish (analytics, account, settings, recommendations screens)                       |

---

## What's Working — Backend

- **FastAPI** server with 5 routers:
  - `/auth` — register & login with JWT tokens + bcrypt password hashing
  - `/transactions` — full CRUD (create, list with `?category=` filter, delete)
  - `/budgets` — full CRUD with partial `PUT` updates
  - `/goals` — full CRUD, ordered by target date
  - `/recommendations` — read endpoint for AI-driven savings suggestions
- **PostgreSQL 16** with 5 tables: `users`, `transactions`, `budgets`, `goals`, `recommendations`
- **Docker Compose** — one command spins up DB + API + pgAdmin
- **Seed data** — demo account with 30 transactions across 3 months pre-loaded

---

## What's Working — Flutter Architecture

- **11 screens:** Login, Register, Home/Dashboard, Transactions, Add Transaction, Budget, Goals, Analytics, Recommendations, Settings, Account
- **Provider layer** — `AuthProvider`, `TransactionProvider`, `BudgetProvider`, `GoalProvider` (all wired to services)
- **Service layer** — `ApiClient` (JWT-injecting HTTP wrapper) + 5 dedicated service classes
- **7 data models** — `User`, `Transaction`, `Budget`, `Goal`, `Recommendation`, `BudgetItem`, `CategoryBreakdown`
- **5 reusable widgets** — `SummaryCard`, `TransactionTile`, `GoalProgressCard`, `CategoryCard`, `LoadingOverlay`

> Most screens currently display rich **sample data** while live provider-to-screen wiring is completed in Sprint 2.

---

## What's Working — Flutter Screens

- **Bottom navigation** — 5 tabs: Home, Transactions, Budget, Goals, Account
- **Dashboard** — summary cards (Balance, Spent, Income, Savings), recent transactions, quick-action buttons
- **Transactions** — category filter chips, scrollable transaction list, add-transaction form (amount, category, date, description)
- **Analytics** — category breakdown bars, period selector (Week/Month/Year), month-over-month comparison
- **Budget** — per-category spend vs. limit progress cards (red highlight when over budget)
- **Goals** — savings goals with icon, progress bar, target date, "Done" chip on completion
- **Recommendations** — AI-powered savings insight cards with estimated savings amounts

---

## Testing

| Test Suite                        | Coverage                                           |
| --------------------------------- | -------------------------------------------------- |
| `models/transaction_test.dart`    | `fromJson` / `toJson` round-trip                   |
| `models/user_test.dart`           | Field mapping, `toJson`                            |
| `models/budget_test.dart`         | `fromJson` field mapping                           |
| `models/goal_test.dart`           | `progressPercent` calc, `isCompleted` logic        |
| `models/recommendation_test.dart` | `fromJson` / `toJson` round-trip                   |
| `utils/validators_test.dart`      | Email, password (min 8), amount validators         |
| `utils/error_helpers_test.dart`   | Strips `"Exception: "` prefix, handles edge cases  |
| `widgets/summary_card_test.dart`  | Renders title and value text correctly             |
| `integration_test/app_test.dart`  | Full app smoke test — app launches & title visible |

---

## Demo Highlights

- **Backend API** — live at `localhost:8000`, Swagger docs at `/api/v1/docs`
- **Auth endpoints** — register creates account & returns JWT; login verifies bcrypt hash & returns JWT
- **Transaction API** — POST/GET (with category filter)/DELETE all functional
- **Dashboard screen** — summary cards, recent transactions, quick-navigation buttons
- **Analytics screen** — category breakdown bars, period selector, month comparison
- **Budget & Goals screens** — per-category progress cards, goals with progress bars

---

## Learning with AI — Topic 1

### Sports Betting Analytics

Using AI (Claude, ChatGPT) as a **tutor** to learn:

- **Probability & odds** — how sportsbooks set lines
- **Expected value (EV)** — calculating whether a bet has positive EV
- **Statistical models** — Elo ratings, regression models for predictions
- **Bankroll management** — Kelly Criterion, unit sizing, risk management

**Approach:** Ask AI to explain concepts, then verify understanding through examples and discussion.

---

## Learning with AI — Topic 2

### Stock Market Analysis

Using AI as a **guided learning assistant** to understand:

- **Fundamental analysis** — reading income statements, balance sheets, P/E ratios
- **Technical analysis** — candlestick charts, RSI, moving averages, MACD
- **Portfolio diversification** — asset allocation and risk management
- **Trading strategies** — understanding market mechanics and order types

**Approach:** Break down complex financial concepts with AI, study real-world examples, deepen understanding iteratively.

---

## AI Tools Used

| Tool                | How I Used It                                                                             |
| ------------------- | ----------------------------------------------------------------------------------------- |
| **Claude / Cursor** | Code generation for Flutter widgets, FastAPI routers, SQL schemas; architecture decisions |
| **ChatGPT**         | Tutor for sports betting & stock market concepts — explanations, follow-up Q&A            |
| **GitHub Copilot**  | Inline completions for repetitive boilerplate (model classes, test assertions)            |

**Philosophy:** Use AI to _explain and teach_, not just provide answers. Ask follow-up questions to build genuine understanding.

---

## Sprint 2 Plan

| Week   | Goal                                                                         |
| ------ | ---------------------------------------------------------------------------- |
| **9**  | Live provider integration — connect all Flutter screens to real API data     |
| **10** | Persistent auth (secure token storage) + ML transaction categorization model |
| **11** | Budget generation ML model (learn spending patterns → generate budgets)      |
| **12** | Savings recommendations engine (ML inference pipeline)                       |
| **13** | Alerts & push notifications (budget limit warnings)                          |
| **14** | Flutter app polish, full integration testing, deployment pipeline            |
| **15** | Final testing, deployment, Final Presentation                                |

**Deployment target:** Android APK + public web app via Docker

---

## Key Dates

- **Project submissions deadline:** 4/25/2026
- **Final Presentation:** 4/27/2026 & 4/29/2026
- **HW4 Deployment deadline:** 5/1/2026

---

## Repositories

- **Capstone Project:** https://github.com/Jolteer/ase485-capstone-finance-ml
- **Learning with AI:** https://github.com/Jolteer/ase485-learning-with-ai

---

# Thank You — Questions?

**Joshua Day**
dayj16@mymail.nku.edu
ASE 485 — Spring 2026
