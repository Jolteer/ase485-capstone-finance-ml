# Individual Project - Josh Day

**Project:** SmartSpend

---

## Team Information

### Team Members

**Joshua Day** (Developer / Sole Contributor)

- **Role:** Full-stack development, ML engine, mobile UI, testing, deployment
- **Focus:** AI-driven budgeting, accessibility, and personalized financial guidance
- **Repository:** https://github.com/Jolteer/ase485-capstone-finance-ml
- **Final Presentation (PDF):** https://github.com/Jolteer/ase485-capstone-finance-ml/blob/main/docs/presentation/final_presentation.pdf
- **Demo Video:** https://www.youtube.com/watch?v=lO66pUXFjnU
- **Email:** dayj16@mymail.nku.edu

---

## Project Overview

### Project Description

SmartSpend is an AI-powered personal finance assistant that uses machine learning to categorize transactions, generate budgets, and recommend savings opportunities. The project combines a Flutter mobile app with a FastAPI + PostgreSQL backend and a scikit-learn ML engine to deliver personalized financial guidance in a single approachable experience.

My contribution to the project focuses on improving user outcomes through automation, accessibility, and behavior change — making budgeting feel less like data entry and more like guidance.

### Problem Domain

While budgeting apps are common, they often fail to actually help users change behavior and struggle with long-term engagement. Common challenges include:

- Users overwhelmed by manual categorization and data entry
- Generic advice that doesn't adapt to individual spending
- Hidden overspending users only notice after the fact

This project addresses these issues by emphasizing automation, personalization, and proactive feedback — making finance management easier for new users while rewarding consistent engagement.

---

## Features and Requirements

### Feature 1: ML Transaction Categorization

Predicts a category for any transaction from its description text using a TF-IDF + Multinomial Naive Bayes pipeline.

**Requirements:**

- Trained on 150+ labeled descriptions across 8 categories
- Returns a prediction with a confidence score
- Auto-applied when a transaction is added without a category
- Standalone endpoint `POST /ml/categorize`

**Acceptance Criteria:**

- Achieves at least 80% accuracy on test data
- Adds no perceptible delay when adding a transaction

### Feature 2: ML Budget Generation and Savings Recommendations

Provides one-tap tools that build budgets from real spending history and surface personalized savings tips, with proactive alerts as users approach their limits.

**Requirements:**

- Computes average monthly spend per category and adds a 10% buffer
- Evaluates 5 spending patterns: over-budget, spikes, missing budgets, high income ratio, top expense categories
- Alerts at 80% (warning) and 100% (danger) of any budget
- Endpoints `POST /ml/budgets/generate` and `POST /ml/recommendations/generate`

**Acceptance Criteria:**

- Generated budgets reflect actual spending patterns
- Recommendations are relevant to top spending categories
- Alerts trigger reliably as budget usage crosses thresholds

---

## GitHub Repository

### Main Repository

https://github.com/Jolteer/ase485-capstone-finance-ml

### Quick Links to Key Directories

- **Backend code:** `backend/`
- **Flutter app:** `mobile/`
- **Database schema:** `docker/init.sql`, `docker/seed.sql`
- **ML engine:** `backend/app/ml/`

---

## Documents

- Requirements
- System Architecture Diagram
- Data Model

## Presentations

- **Sprint 1 Presentation:** `docs/presentation/sprint1_presentation.md`
- **Sprint 2 Presentation:** `docs/presentation/sprint2_presentation.md`
- **Final Presentation:** `docs/presentation/final_presentation.md`
- **PDF Version of Slides:** `docs/presentation/final_presentation.pdf`

---

## Progress

### Milestones

- **Milestone 1:** Project setup, Docker, schema, Flutter & FastAPI scaffolding – **Completed**
- **Milestone 2:** Auth, CRUD endpoints, all 11 Flutter screens, analytics – **Completed**
- **Milestone 3:** ML engine — categorization, budget generation, recommendations – **Completed**
- **Milestone 4:** Budget alerts, full pytest suite, integration tests, polish – **Completed**

### Weekly Progress

- **Week 15 Presentation:** Final Presentation
- **Week 14 Presentation:** Backend pytest suite + integration tests
- **Week 13 Presentation:** Budget alerts
- **Week 12 Presentation:** ML budget generation + recommendations
- **Week 11 Presentation:** ML categorization engine
- **Week 8 Presentation:** Sprint 1 Presentation

---

## Technology Stack

- **Mobile App:** Flutter 3 / Dart with Provider state management
- **Backend API:** Python 3.12, FastAPI, Uvicorn
- **Database:** PostgreSQL 16
- **ML Engine:** scikit-learn (TF-IDF + Multinomial Naive Bayes)
- **Auth:** JWT (PyJWT) + bcrypt (Passlib)
- **Containers:** Docker Compose
- **Design Focus:** Automation, accessibility, personalized guidance

---

## Personal Contribution Summary

My work on SmartSpend centers on making personal finance management more automatic, personalized, and approachable. By focusing on ML-driven categorization, budget generation, and proactive alerts, this contribution improves both first-time user experience and long-term engagement.

### Automation That Removes Friction

The single biggest barrier to budgeting apps is data entry. Users churn out of finance tools when every transaction requires them to scroll through a long list of categories and tag it themselves. To address this, I built a TF-IDF + Multinomial Naive Bayes pipeline trained on 150+ labeled descriptions across 8 categories that runs automatically whenever a transaction is added without a category. The model returns both a predicted category and a confidence score in well under a second, so the categorization is invisible to the user — transactions just appear pre-tagged. The same model is also exposed through `POST /ml/categorize` so the mobile app can ask for predictions on demand (for example, while the user is still typing). On held-out test data the pipeline reaches over 80% accuracy, comfortably meeting the acceptance criteria, and it is the foundation everything else in the ML engine relies on.

### Personalization Driven by the User's Own Data

The second contribution turns SmartSpend from a logging tool into a guidance tool. The budget generator (`POST /ml/budgets/generate`) inspects each user's actual transaction history, computes the average monthly spend per category, and adds a 10% buffer to produce a starting budget that is grounded in real behavior instead of generic templates. The recommendations engine (`POST /ml/recommendations/generate`) layers on top of this by evaluating five different spending patterns — over-budget categories, spending spikes, missing budgets, high income ratios, and top expense categories — and surfacing tips that are specific to what the user is actually doing. Because the recommendations are derived from the user's own data, they stay relevant even as habits change month to month, which directly addresses the "generic advice" problem that drives users away from competing apps.

### Proactive Feedback Instead of After-the-Fact Surprises

Hidden overspending is one of the biggest reasons people lose trust in budgets. To prevent that, I added a budget alert system that triggers a warning at 80% of any budget and a danger alert at 100%. Combined with the dashboards built earlier in the project, this gives users a continuous sense of where they stand without having to dig for it. Alerts are tied to the same data that powers budgets and recommendations, so the entire experience stays internally consistent — the budget the ML engine generated, the spending the categorizer tagged, and the alert the system raises are all reading from the same source of truth.

### Engineering Quality and Reliability

Underneath the ML work, I also built and maintained the full pytest suite for the backend and the Flutter integration tests on the mobile side. This was important because the ML features only deliver value if the supporting CRUD, auth, and analytics endpoints stay correct as the codebase grows. The integration tests in particular protect the end-to-end flow that matters most to users: signing in, adding a transaction, watching it get auto-categorized, generating a budget, and seeing the resulting alerts. Holding myself to that quality bar as a sole contributor — across full-stack code, ML, mobile UI, testing, and deployment — was as much a part of the contribution as any individual feature.

### Outcome

Together, these pieces move SmartSpend toward the original goal: a budgeting experience that feels less like data entry and more like guidance. New users get value immediately because the app categorizes their spending and proposes a budget for them, and returning users keep getting value because recommendations and alerts continue to adapt to their behavior. Every acceptance criterion for both Feature 1 and Feature 2 was met, all four milestones were completed on schedule, and the project ships with a tested backend, a polished Flutter app, a working ML engine, and a proactive alerting system — delivered end-to-end as a single contributor.

---

**Last Updated:** May 1, 2026
