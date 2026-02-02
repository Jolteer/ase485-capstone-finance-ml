---
marp: true
theme: default
paginate: true
---

# SmartSpend

## AI-Powered Personal Finance Assistant

### Project Plan Presentation (PPP)

Josh
ASE 485

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

**SmartSpend** 

- Analyzes spending data using ML to identify problem areas
- Generates personalized budgets based on actual behavior
- Provides actionable savings recommendations
- Tracks progress toward financial goals
- Alerts users when approaching budget limits

---

# Features and Requirements

| Feature                       | Requirements                          |
| ----------------------------- | ------------------------------------- |
| 1. User Authentication        | Secure sign up/login                  |
| 2. Transaction Input          | Manual entry, Import/upload data      |
| 3. Transaction Categorization | Auto-categorize using ML              |
| 4. Spending Visualization     | Category breakdowns, Time period view |
| 5. Budget Generation          | ML-generated personalized budgets     |

---

# Features and Requirements (cont.)

| Feature                    | Requirements                            |
| -------------------------- | --------------------------------------- |
| 6. Budget Adaptation       | Budgets adapt based on new data         |
| 7. Savings Recommendations | 3+ actionable suggestions, Personalized |
| 8. Goal Setting            | Create and manage financial goals       |
| 9. Progress Tracking       | Track goals, Visualize trends           |
| 10. Alerts & Notifications | Budget limit warnings                   |

**Total: 10 features, 14 requirements**

---

# Architecture

**Client Side:**

- Web Application (React)
- Mobile App (Flutter)

**Server Side (via REST API):**

- Server: FastAPI (Python) + ML Pipeline (Scikit-learn, pandas)
- Database: PostgreSQL
- Deployment: Docker containers

**Data Model:**

- User → Transactions → Budgets → Goals

---

# Burndown Metrics

| Metric       | Sprint 1 Target | Sprint 2 Target | Total |
| ------------ | --------------- | --------------- | ----- |
| Features     | 5 / 10          | 10 / 10         | 10    |
| Requirements | 7 / 14          | 14 / 14         | 14    |
| LoC          | ~1500           | ~4000           | ~4000 |
| Unit Tests   | ~15             | ~40             | ~40   |

---

# Sprint Plan

**Sprint 1 (Weeks 4-8)**

- Week 4: Project setup (Docker, database) + React/FastAPI foundation
- Week 5: User authentication + Transaction input
- Week 6: Import functionality + ML categorization model
- Week 7: Spending visualization + Dashboard UI
- Week 8: Testing, polish & Sprint 1 Presentation

---

# Sprint Plan (cont.)

**Sprint 2 (Weeks 9-15)**

- Week 9: Budget generation ML model
- Week 10: Budget adaptation system
- Week 11: Savings recommendations engine
- Week 12: Goal setting & progress tracking
- Week 13: Alerts & notifications system
- Week 14: Flutter mobile app development & integration
- Week 15: Testing, deployment, Final Presentation (4/27, 4/29)

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
- **Platforms:** Web + Mobile
- **Tech Stack:** React, Flutter/Dart, FastAPI, PostgreSQL, Scikit-learn
- **Scope:** 10 features, 14 requirements across 2 sprints
- **Learning with AI:** Sports betting analytics & stock market analysis
- **GitHub:** https://github.com/Jolteer/ase485-capstone-finance-ml

**Ready for questions!**
