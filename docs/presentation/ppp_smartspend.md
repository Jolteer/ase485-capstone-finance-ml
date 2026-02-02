---
marp: true
theme: default
paginate: true
---

# SmartSpend

## AI-Powered Personal Finance Assistant

### Project Plan Presentation (PPP)

Josh
ASE 485 - Week 4

---

# Problem Domain

- Many people struggle with managing their finances effectively
- They overspend in certain categories without realizing it
- Existing budgeting apps require too much manual input
- Generic advice doesn't adapt to individual behavior
- Financial stress is a leading cause of anxiety

**Goal:** Use machine learning to learn from spending patterns and provide personalized, adaptive budgeting guidance

---

# Proposed Solution

**SmartSpend** — a web application that:

- Analyzes spending data using ML to identify problem areas
- Generates personalized budgets based on actual behavior
- Provides actionable savings recommendations
- Tracks progress toward financial goals
- Alerts users when approaching budget limits

---

# Features and Requirements

| Feature                    | Requirements                                            |
| -------------------------- | ------------------------------------------------------- |
| 1. Spending Analysis       | RQ1: Import data, RQ2: Auto-categorize, RQ3: Breakdowns |
| 2. ML Budget Generation    | RQ4: Personalized budgets, RQ5: Adaptive over time      |
| 3. Savings Recommendations | RQ6: 3+ suggestions, RQ7: Personalized                  |
| 4. Progress Tracking       | RQ8: Goal setting, RQ9: Trend visualizations            |
| 5. Alerts & Notifications  | RQ10: Budget limit warnings                             |

**Total: 5 features, 10 requirements**

---

# Architecture

- **Frontend:** React web interface
- **Backend:** FastAPI (Python)
- **Database:** PostgreSQL
- **ML Pipeline:** Scikit-learn, pandas

**Data Model:**

- User → Transactions → Budgets → Goals

---

# Burndown Metrics

| Metric       | Sprint 1 Target | Sprint 2 Target | Total |
| ------------ | --------------- | --------------- | ----- |
| Features     | 2 / 5           | 5 / 5           | 5     |
| Requirements | 4 / 10          | 10 / 10         | 10    |
| LoC          | ~1500           | ~4000           | ~4000 |
| Unit Tests   | ~15             | ~40             | ~40   |

---

# Sprint Plan

**Stage 2: Prototype/MVP (Weeks 4-8)**

- Week 4: PPP. Sprint 1 - 1
- Week 5: Sprint 1 - 2. React + FastAPI setup
- Week 6: Sprint 1 - 3. Transaction input & ML categorization
- Week 7: Sprint 1 - 4. Dashboard & visualizations
- Week 8: Sprint 1 Presentation. Budget generation model

**Stage 3: Project (Weeks 10-16)**

- Weeks 10-15: Sprint 2 (6 sprints). Full implementation
- Week 15: Project submissions deadline (4/26)
- Week 16: Final Presentation (4/27, 4/29)

---

# Learning with AI

## Topic 1: Sports Betting Analytics

- **Why:** Understand the math and statistics behind odds, expected value, and data-driven decision making
- **How:** Use Claude/ChatGPT as tutors, build Python scripts to simulate and analyze outcomes

## Topic 2: Stock Market Analysis

- **Why:** Learn fundamental and technical analysis for informed investing decisions
- **How:** Use AI to break down financial concepts, write scripts to pull and visualize stock data

---

# Summary

- **Project:** SmartSpend — ML-powered personal finance assistant
- **Tech Stack:** React, FastAPI, PostgreSQL, Scikit-learn
- **Scope:** 5 features, 10 requirements across 2 sprints
- **Learning with AI:** Sports betting analytics & stock market analysis
- **GitHub:** https://github.com/Jolteer/ase485-capstone-finance-ml

**Ready for questions!**
