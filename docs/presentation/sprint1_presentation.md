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

## What Went Wrong:

- Underestimated time for Flutter-FastAPI integration
- Docker networking issues delayed database connectivity
- Struggled with JWT token refresh logic implementation
- Provider state management edge cases caused UI issues

---

## What Went Well:

- Successfully built full-stack architecture from scratch
- All Sprint 1 features completed on time
- Backend API endpoints are robust and well-documented
- Flutter UI is polished with reusable component library
- Testing suite provides good coverage for core functionality

---

## Analysis & Improvement Plan:

- Allocate more time for integration testing between layers
- Set up better error logging for provider state debugging
- Create more granular milestones for complex features
- Document API contracts before building frontend screens
- Use Docker health checks to catch networking issues early

---

## Weekly Progress Sprint 1

| Week  | What I Built                                                                          |
| ----- | ------------------------------------------------------------------------------------- |
| **1** | GitHub repo, Docker setup (PostgreSQL + pgAdmin),<br>Flutter & FastAPI initialization |
| **2** | User auth — JWT endpoints, bcrypt passwords,<br>login/register screens, DB schema     |
| **3** | Transactions — CRUD API,<br>transaction list & add-transaction screens                |
| **4** | Dashboard — budgets/goals/recommendations API<br>+ analytics screens                  |
| **5** | Testing suite, bug fixes, UI polish across all screens                                |

---

## Sprint 1 Metrics

- **Lines of Code:** 3,247
- **Tests:** Unit: 8 · Integration: 1
- **Features:** 5 / 5 completed
- **Requirements:** 12 / 12 completed
- **Feature burndown:** 100%
- **Requirement burndown:** 100%

---

## Sprint 2

---

## Individual Sprint 2 Goals/Features:

- Connect all Flutter screens to live API data
- Implement persistent authentication with secure token storage
- Build ML transaction categorization model (scikit-learn)
- Create budget generation ML model from spending patterns
- Develop savings recommendations engine with ML inference
- Add alerts & push notifications for budget warnings

---

## Individual Sprint 2 Metrics:

- **Number of features planned for this sprint:** 6
- **Number of requirements planned for this sprint:** 15

---

## Updated Timeline and Milestones:

| Week  | Milestone                                                                   |
| ----- | --------------------------------------------------------------------------- |
| **1** | Live provider integration —<br>connect all Flutter screens to real API data |
| **2** | Persistent auth (secure token storage)<br>+ ML transaction categorization   |
| **3** | Budget generation ML model<br>(learn spending patterns → generate budgets)  |
| **4** | Savings recommendations engine<br>(ML inference pipeline)                   |
| **5** | Alerts & push notifications<br>(budget limit warnings)                      |
| **6** | Flutter app polish, full integration testing,<br>deployment pipeline        |
| **7** | Final testing, deployment, Final Presentation                               |

---

## Key Dates

- **Live API integration complete:** Week 1
- **ML inference pipeline complete:** Week 4
- **Full integration testing:** Week 6
- **Final Presentation:** Week 7 — April 27 & 29, 2026

---

## AI-Assisted Learning Research

**Research Plan:**

1. **Stock Market Analysis** — Technical indicators and risk management
2. **Sports Betting Analytics** — Probability and expected value

**Approach:**

- Use AI to explain core concepts with worked examples
- Implement calculations in Python to verify understanding
- Build small tools to practice applying the concepts

---

## Stock Market Analysis — What I'm Learning

**Core Concepts:**

- Market mechanics (bid-ask spread, order types, slippage)
- Technical indicators (SMA, EMA, RSI)
- Key financial ratios (P/E, ROE, debt-to-equity)
- Risk management (1-2% rule, position sizing)

**Key Insight:**

The bid-ask spread is real money — a $0.10 spread on multiple trades adds up fast for day trading.

---

## Stock Market Analysis — What I'm Building

**Tools I'm Creating:**

- Python scripts to calculate SMA, EMA, RSI from scratch
- Stock price plotting with indicator overlays
- Simple day trading strategy backtester

**Goal:**

Verify my understanding by implementing the formulas and testing strategies on historical data.

---

## Sports Betting Analytics — What I'm Learning

**Core Concepts:**

- Odds formats (American, decimal) and implied probability
- The vig: Sportsbook profit margin built into odds
- Expected Value (EV): Average profit/loss per bet
- Why probabilities add to >100% in betting odds

**Key Insight:**

With -110 odds on both sides, you need 52.4% accuracy just to break even because of the vig.

---

## Sports Betting Analytics — What I'm Building

**Tools I'm Creating:**

- Odds-to-probability converter with vig calculation
- EV calculator to find value bets
- Simulation tool to test betting strategies over 1,000+ bets

**Goal:**

Understand if consistent profitability is mathematically possible and what edge is required to beat the vig.

---

# Questions?
