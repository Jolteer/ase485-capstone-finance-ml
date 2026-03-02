---
marp: true
theme: default
paginate: true
header: "Sprint 1 Retrospective — SmartSpend"
footer: "Joshua Day | ASE 485 | Spring 2026"
---

# Sprint 1 Retrospective

## SmartSpend

**By:** Joshua Day

---

## The Problem

**70% of Americans live paycheck-to-paycheck**

- Lack visibility into spending patterns
- Struggle to create realistic budgets

## My Solution: SmartSpend

**AI-powered personal finance assistant that:**

- Automatically categorizes transactions using ML
- Generates personalized budgets from spending patterns
- Provides intelligent savings recommendations

**Built with:** Flutter + FastAPI + PostgreSQL + ML (scikit-learn)

---

## What Went Wrong

- Underestimated Flutter-FastAPI integration time
- Docker networking issues delayed DB connectivity
- JWT token refresh logic was tricky to implement
- Provider state management edge cases broke UI

---

## What Went Well

- Built full-stack architecture
- All 5 features completed on time
- Backend API is working and well-documented
- Flutter UI is polished with reusable components
- Good test coverage for core functionality

---

## Improvement Plan

- Spend more time testing how parts work together
- Add better error logs to find bugs faster
- Write down API details before building screens
- Use health checks in Docker to catch network problems

---

## Weekly Progress

| Week  | What I Built                                                                      |
| ----- | --------------------------------------------------------------------------------- |
| **1** | GitHub repo, Docker setup (PostgreSQL + pgAdmin),<br>Flutter & FastAPI init       |
| **2** | User auth — JWT endpoints, bcrypt passwords,<br>login/register screens, DB schema |
| **3** | Transactions — CRUD API,<br>transaction list & add-transaction screens            |
| **4** | Dashboard — budgets/goals/recommendations API<br>+ analytics screens              |
| **5** | Testing suite, bug fixes, UI polish across all screens                            |

---

## Sprint 1 Metrics

- **Lines of Code:** ~3,200
- **Tests:** 8 unit · 1 integration
- **Features:** 5 / 5 completed
- **Requirements:** 12 / 12 completed
- **Burndown:** 100%

---

## Sprint 2 Goals

- Make all app screens show real-time API data
- Keep users logged in with secure tokens
- Use ML to auto-categorize transactions
- Auto-generate budgets from spending
- Recommend ways to save money with ML
- Send alerts when budgets are close to limits

**Planned:** 6 features · 15 requirements

---

## Sprint 2 Timeline

| Week | Milestone                        |
| ---- | -------------------------------- |
| 1    | Connect Flutter UI to API        |
| 2    | Persistent auth, ML categorizing |
| 3    | ML budget generation             |
| 4    | ML savings suggestions           |
| 5    | Alerts, push notifications       |
| 6    | Polish, testing, deploy setup    |
| 7    | Final test & presentation        |

---

## AI-Assisted Learning Research

**Topics:**

1. **Stock Market Analysis** — Technical indicators and risk management
2. **Sports Betting Analytics** — Probability and expected value

**Approach:**

- Use AI to explain core concepts with worked examples
- Implement calculations in Python to verify understanding
- Build small tools to practice applying the concepts

---

## Stock Market Analysis — What I'm Learning

- How the stock market works
- Simple chart signals (like averages)
- Basic company stats
- Ways to avoid big losses

---

## Sports Betting Analytics — What I'm Learning

- How betting odds work
- How sportsbooks make money
- How to know if a bet is good or bad
- How to manage betting money
- Simple systems to predict games

---

# Questions?
