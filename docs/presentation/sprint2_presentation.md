---
marp: true
theme: default
paginate: true
header: "Sprint 2 Final Presentation — SmartSpend"
footer: "Joshua Day | ASE 485 | Spring 2026"
---

# Sprint 2 Final Presentation

## SmartSpend

**By:** Joshua Day

---

## Recap — The Problem

**70% of Americans live paycheck-to-paycheck**

- Lack visibility into spending patterns
- Struggle to create realistic budgets
- Generic advice doesn't adapt to individual behaviour

## SmartSpend Solution

**AI-powered personal finance assistant** that learns from your spending and provides personalised guidance.

**Tech Stack:** Flutter + FastAPI + PostgreSQL + scikit-learn

---

## Sprint 2 Goals (set at end of Sprint 1)

1. Connect all Flutter screens to real-time API data
2. Persistent auth with secure token storage
3. ML auto-categorization of transactions
4. ML-driven budget generation
5. ML-powered savings recommendations
6. Budget alerts when approaching limits

---

## What Was Delivered

### ML Transaction Categorization

- TF-IDF + Multinomial Naive Bayes pipeline (scikit-learn)
- Trained on 150+ labelled descriptions across 8 categories
- Auto-categorizes when user omits category on new transactions
- Standalone `/ml/categorize` endpoint with confidence scores

### ML Budget Generation

- Analyses full transaction history per category
- Computes average monthly spend + 10% buffer
- `POST /ml/budgets/generate` replaces budgets with ML suggestions
- One-tap "Generate Budgets" button in the Flutter Budget screen

---

## What Was Delivered (cont.)

### ML Savings Recommendations

- Rule-based engine evaluating 5 spending patterns:
  - Over-budget categories
  - Month-over-month spending spikes (>20%)
  - Categories without budgets
  - High spending-to-income ratio (>80%)
  - Top expense category suggestions
- `POST /ml/recommendations/generate` with one-tap refresh in Flutter

### Budget Alerts

- Client-side alert computation (warning at 80%, danger at 100%)
- Alert banners on the Home dashboard
- Notification bell with badge count and bottom-sheet detail view
- Alert cards on the Budget overview screen

---

## Sprint 2 Weekly Progress

| Week   | Milestone                                                                                |
| ------ | ---------------------------------------------------------------------------------------- |
| **9**  | Persistent auth (secure storage), SettingsProvider, expanded test suite (25+ test files) |
| **10** | Live API wiring — all 11 screens connected to real providers/services                    |
| **11** | ML categorization engine, auto-categorize on transaction create                          |
| **12** | ML budget generation + ML recommendations engine                                         |
| **13** | Budget alerts (banners, notification bell, bottom sheet)                                 |
| **14** | Integration tests, backend pytest suite, UI polish, cleanup                              |
| **15** | Final testing, presentation, deployment prep                                             |

---

## Architecture Overview

```
Flutter App (11 screens)
  └── 6 Providers (ChangeNotifier + Provider)
       └── 6 Services (HTTP)
            └── ApiClient (JWT, timeout, offline handling)
                 └── FastAPI Backend (:8000)
                      ├── Auth (JWT + bcrypt)
                      ├── CRUD Routers (transactions, budgets, goals, recs)
                      ├── ML Router (/ml/categorize, /ml/budgets/generate,
                      │              /ml/recommendations/generate)
                      ├── ML Engine (scikit-learn pipeline)
                      └── PostgreSQL 16 (5 tables, UUID PKs, FK cascade)
```

---

## Sprint 2 Metrics

- **Total Lines of Code:** ~6,500+
- **Backend Endpoints:** 18 (15 CRUD + 3 ML)
- **Flutter Test Files:** 25+ (models, providers, services, widgets, utils)
- **Backend Test Files:** pytest suite for all endpoints
- **Features Delivered:** 6 / 6 Sprint 2 goals
- **Total Features:** 19 (13 Sprint 1 + 6 Sprint 2)

---

## Demo Highlights

1. **Login** as demo user → Home dashboard with budget alert banners
2. **Add Transaction** without selecting category → ML auto-categorizes
3. **Budget Screen** → Tap generate button → ML suggests budgets
4. **Recommendations** → Tap refresh → ML analyses and generates tips
5. **Notification Bell** → Badge shows alert count, bottom sheet lists details
6. **Dark Mode** → Toggle in Settings, persisted across restarts

---

## What Went Well

- ML integration was smoother than expected — scikit-learn pipeline is fast
- Provider architecture from Sprint 1 made wiring ML features straightforward
- Budget alerts add real user value with minimal additional code
- Test coverage stayed strong throughout Sprint 2

## What Was Challenging

- Designing the ML training corpus to cover enough transaction description variety
- Balancing rule-based vs ML approaches for recommendations
- Keeping the Docker image lean after adding scikit-learn + numpy

---

## Acceptance Criteria Status

| Criteria                                                    | Status                                     |
| ----------------------------------------------------------- | ------------------------------------------ |
| Users can input spending data and see it categorized        | Done — ML auto-categorization              |
| ML model generates budgets reflecting spending patterns     | Done — `/ml/budgets/generate`              |
| Savings recommendations relevant to top spending categories | Done — rule-based ML engine                |
| Alerts trigger when approaching budget limits               | Done — 80% warning, 100% danger            |
| ML categorization at least 80% accuracy                     | Met — NB + TF-IDF on representative corpus |
| API responds within 2 seconds                               | Met — typical response < 200ms             |

---

## Future Enhancements

- CSV / bank feed import for transaction data
- Firebase push notifications for real-time budget alerts
- Adaptive budgets that adjust month-to-month automatically
- Deep learning model for categorization (BERT embeddings)
- Multi-user household support

---

# Questions?

**Repository:** github.com/Jolteer/ase485-capstone-finance-ml
