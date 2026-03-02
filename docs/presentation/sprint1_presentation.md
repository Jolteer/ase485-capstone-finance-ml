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

- **Frontend:** Flutter (Android + Web)
- **Backend:** FastAPI (Python)
- **Database:** PostgreSQL
- **ML:** Scikit-learn for transaction categorization & budget generation
- **Deployment:** Docker containers

---

## Architecture Overview

```
┌─────────────────┐     REST API      ┌──────────────────┐
│  Flutter App     │ ◄──────────────► │  FastAPI Backend  │
│  (Android + Web) │                   │  (Python)         │
└─────────────────┘                   └────────┬─────────┘
                                               │
                                      ┌────────▼─────────┐
                                      │   PostgreSQL DB   │
                                      │   (via Docker)    │
                                      └──────────────────┘
```

---

## Sprint 1 Progress — Week by Week

| Week | What I Built |
|------|-------------|
| **4** | Project setup — GitHub repo, Docker (docker-compose + PostgreSQL), Flutter & FastAPI scaffolding |
| **5** | User authentication — JWT auth endpoints, login/signup screens, DB schema (init.sql, seed.sql) |
| **6** | Transaction management — CRUD API endpoints, Flutter UI for adding/viewing transactions |
| **7** | Dashboard & visualization — spending breakdowns by category, API services for budgets, goals, recommendations |
| **8** | Testing, bug fixes, UI polish (account, settings, analytics screens) |

---

## What's Working — Backend

- **FastAPI** server with 5 routers:
  - `/auth` — register & login with JWT tokens + bcrypt passwords
  - `/transactions` — full CRUD (create, list, filter by category, delete)
  - `/budgets` — full CRUD with partial updates
  - `/goals` — full CRUD for savings goals with progress tracking
  - `/recommendations` — read endpoint for ML-driven suggestions
- **PostgreSQL** with 4 tables: users, transactions, budgets, goals
- **Docker Compose** — one command spins up DB + API + pgAdmin

---

## What's Working — Frontend (Flutter)

- **9 screen modules:** Home, Auth, Transactions, Budget, Goals, Analytics, Recommendations, Account, Settings
- **Bottom navigation** with 5 tabs: Home, Transactions, Budget, Goals, Account
- **Service layer** — dedicated API client services for each entity
- **Spending analytics** — category breakdowns, period selector (week/month/year), month comparison
- **Reusable widgets** — summary cards, transaction tiles, goal progress cards, category cards

---

## Demo Highlights

- **Auth flow:** Register → Login → JWT stored → authenticated API calls
- **Transaction management:** Add transactions with amount, category, description, date → view list → delete
- **Dashboard:** Spending summary cards, recent transactions, quick navigation
- **Analytics:** Category breakdown bars, spending by period, month-over-month comparison
- **Budget & Goals:** Create/edit budgets per category, set savings goals with progress tracking

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

| Tool | How I Used It |
|------|--------------|
| **Claude / ChatGPT** | Tutor for sports betting & stock market concepts — explanations, follow-up Q&A |
| **GitHub Copilot** | Code assistance for Flutter widgets, FastAPI endpoints, SQL schemas |

**Philosophy:** Use AI to *explain and teach*, not just provide answers. Ask follow-up questions to build genuine understanding.

---

## Sprint 2 Plan

| Week | Goal |
|------|------|
| **9** | Budget generation ML model |
| **10** | Budget adaptation system |
| **11** | Savings recommendations engine |
| **12** | Goal setting & progress tracking enhancements |
| **13** | Alerts & notifications system |
| **14** | Flutter mobile app polish & integration testing |
| **15** | Final testing, deployment, Final Presentation |

**Deployment:** Android app + public web application via Docker

---

## Key Dates

- **Project submissions deadline:** 4/25/2026
- **Final Presentation:** 4/27/2026
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
