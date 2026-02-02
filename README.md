# SmartSpend - AI-Powered Personal Finance Assistant

## Developer

- **Josh** 

## Project Description

SmartSpend is a web and mobile application that uses artificial intelligence and machine learning to help individuals with poor spending habits build better financial behaviors. The app analyzes a user's spending data, identifies problem areas, generates personalized budgets, and provides actionable recommendations to help users save money over time.

## Problem Domain

Many people struggle with managing their finances effectively:

- They overspend in certain categories without realizing it.
- They fail to maintain a consistent budget over time.
- Existing budgeting apps require too much manual input and provide generic advice that doesn't adapt to individual behavior.
- Financial stress is one of the leading causes of anxiety, and people need tools that actively help them improve rather than just track numbers.

  SmartSpend solves this by using machine learning to learn from a user's spending patterns and provide personalized, adaptive budgeting guidance.

## Features and Requirements

### Features & Requirements

1. User Authentication:
   - Users can securely sign up and log in to their account.

2. Transaction Input:
   - Users can manually input spending transactions.
   - Users can import or upload spending data from external sources.

3. Transaction Categorization:
   - The system automatically categorizes transactions using ML (food, entertainment, bills, etc.).

4. Spending Visualization:
   - Users can view spending breakdowns by category.
   - Users can view spending breakdowns by time period (week, month, year).

5. Budget Generation:
   - The ML model generates a personalized budget based on the user's income and spending history.

6. Budget Adaptation:
   - Budgets adapt over time as the model learns from new spending data.

7. Savings Recommendations:
   - The system provides at least 3 actionable savings recommendations per analysis.
   - Recommendations are personalized based on the user's specific spending patterns.

8. Goal Setting:
   - Users can create and manage financial goals (e.g., save for vacation, pay off debt).

9. Progress Tracking:
   - Users can track progress toward their financial goals.
   - The app visualizes spending trends over time with charts and graphs.

10. Alerts and Notifications:

- Users receive alerts when approaching or exceeding budget limits in specific categories.

**Total: 10 features, 14 requirements**

Link: [docs/features/overall.md](docs/features/overall.md)

### Non-Functional Requirements

- Web and mobile applications (React web + Flutter/Dart mobile).
- User financial data is stored securely with encryption.
- The application should respond to user actions within 2 seconds.
- The ML model should process and categorize transactions with at least 80% accuracy.

## Data Model

The data model consists of four core entities:

- **User:** id, email, password_hash, name, created_at
- **Transaction:** id, user_id, amount, category, description, date
- **Budget:** id, user_id, category, limit_amount, period, created_at
- **Goal:** id, user_id, target_amount, target_date, description, progress

  Link: [docs/architecture/data_model.md](docs/architecture/data_model.md)

## Architecture

The application follows a client-server architecture:

**Client Side:**

- **Web Application:** React-based interface for user interaction and data visualization.
- **Mobile App:** Flutter/Dart native mobile application.

**Server Side (via REST API):**

- **Server:** FastAPI (Python) handling API requests, business logic, and ML model inference.
- **Database:** PostgreSQL for storing user profiles, transactions, and budget history.
- **ML Pipeline:** Scikit-learn and pandas for transaction categorization, spending pattern analysis, and budget generation.
- **Deployment:** Docker containers for consistent development and production environments.

  [Architecture diagram will be added here]

  Link: [docs/architecture/system_architecture.png](docs/architecture/system_architecture.png)

## Tests

### Acceptance Tests

- Verify that users can successfully input spending data and see it categorized.
- Verify that the ML model generates a budget that reflects the user's actual spending patterns.
- Verify that savings recommendations are relevant to the user's top spending categories.
- Verify that alerts trigger when a user approaches their budget limit.

  Link: [docs/requirements/acceptance_tests.md](docs/requirements/acceptance_tests.md)

### Integration Tests

- Test API endpoints to ensure frontend and backend communicate correctly.
- Test database operations for creating, reading, and updating transactions and budgets.
- Test ML pipeline integration with the backend API.

  Link: [tests/integration_tests/](tests/integration_tests/)

### E2E Tests

- Full user flow: sign up, import data, view analysis, receive budget, track progress.
- Full user flow: set a savings goal, receive recommendations, track progress over time.

## Project Documentation

- [Project Plan Presentation (PPP)](docs/presentation/ppp_smartspend.md)
- [Individual Contributions - Josh](individual/josh/progress.md)

## Schedule & Milestones

### Sprint 1 (Weeks 4-8)

- Week 4: Project setup (Docker, database) + React/FastAPI foundation
- Week 5: User authentication + Transaction input
- Week 6: Import functionality + ML categorization model
- Week 7: Spending visualization + Dashboard UI
- Week 8: Testing, polish & Sprint 1 Presentation

### Sprint 2 (Weeks 9-15)

- Week 9: Budget generation ML model
- Week 10: Budget adaptation system
- Week 11: Savings recommendations engine
- Week 12: Goal setting & progress tracking
- Week 13: Alerts & notifications system
- Week 14: Flutter mobile app development & integration
- Week 15: Testing, deployment, Final Presentation (4/27, 4/29)

  Link: [docs/plan/milestones.md](docs/plan/milestones.md)
