# SmartSpend - AI-Powered Personal Finance Assistant

## Team Members

- **Josh** - Developer, Designer, Tester, Project Manager (Individual Project)

## Project Description

SmartSpend is a web application that uses artificial intelligence and machine learning to help individuals with poor spending habits build better financial behaviors. The app analyzes a user's spending data, identifies problem areas, generates personalized budgets, and provides actionable recommendations to help users save money over time.

## Problem Domain

Many people struggle with managing their finances effectively:

- They overspend in certain categories without realizing it.
- They fail to maintain a consistent budget over time.
- Existing budgeting apps require too much manual input and provide generic advice that doesn't adapt to individual behavior.
- Financial stress is one of the leading causes of anxiety, and people need tools that actively help them improve rather than just track numbers.

  SmartSpend solves this by using machine learning to learn from a user's spending patterns and provide personalized, adaptive budgeting guidance.

## Goals

- Build a working ML-powered personal finance application
- Help users improve spending habits through personalized recommendations
- Demonstrate effective use of machine learning in a real-world application

## Features and Requirements

### Features & Requirements

1. Spending Analysis:
   - RQ1: Users can input or import their spending data.
   - RQ2: The system automatically categorizes transactions by type (food, entertainment, bills, etc.).
   - RQ3: Users can view spending breakdowns by category and time period.

2. ML-Powered Budget Generation:
   - RQ4: The ML model generates a personalized budget based on the user's income and spending history.
   - RQ5: Budgets adapt over time as the model learns from new spending data.

3. Savings Recommendations:
   - RQ6: The system provides at least 3 actionable savings recommendations per analysis.
   - RQ7: Recommendations are personalized based on the user's specific spending patterns.

4. Progress Tracking:
   - RQ8: Users can set financial goals and track progress toward them.
   - RQ9: The app visualizes spending trends over time with charts and graphs.

5. Alerts and Notifications:
   - RQ10: Users receive alerts when approaching or exceeding budget limits in specific categories.

We have 5 features and 10 requirements.

Link: [docs/features/overall.md](docs/features/overall.md)

### Non-Functional Requirements

- Web application built with React frontend and FastAPI backend.
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

- **Frontend:** React-based web interface for user interaction and data visualization.
- **Backend:** FastAPI (Python) server handling API requests, business logic, and ML model inference.
- **Database:** PostgreSQL for storing user profiles, transactions, and budget history.
- **ML Pipeline:** Scikit-learn and pandas for transaction categorization, spending pattern analysis, and budget generation.

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

## Schedule & Milestones

### Sprint 1 (Weeks 4-8): Prototype/MVP

- Set up project infrastructure (React frontend, FastAPI backend, PostgreSQL database).
- Implement user authentication and transaction data input.
- Build basic transaction categorization with ML model.
- Create initial dashboard with spending breakdown visualizations.

### Sprint 2 (Weeks 9-15): Full Implementation

- Implement ML-powered budget generation.
- Build savings recommendation engine.
- Add progress tracking and goal-setting features.
- Implement alerts and notifications.
- Comprehensive testing and bug fixes.

  Link: [docs/plan/milestones.md](docs/plan/milestones.md)
