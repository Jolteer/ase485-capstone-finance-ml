# Acceptance Tests

## Feature 1: Spending Analysis

### AT-1.1: User can input spending data

- **Given:** A logged-in user on the transaction input page
- **When:** The user enters a transaction amount, description, and category
- **Then:** The transaction is saved and appears in their transaction history

### AT-1.2: System categorizes transactions

- **Given:** A user inputs a transaction with description "Starbucks coffee"
- **When:** The system processes the transaction
- **Then:** The transaction is automatically categorized as "Food & Dining"

### AT-1.3: User views spending breakdown

- **Given:** A user with transaction history
- **When:** The user navigates to the dashboard
- **Then:** They see a breakdown of spending by category with percentages

---

## Feature 2: ML-Powered Budget Generation

### AT-2.1: Generate personalized budget

- **Given:** A user with at least 30 days of spending history
- **When:** The user requests a budget recommendation
- **Then:** The ML model generates a monthly budget with category limits

### AT-2.2: Budget adapts over time

- **Given:** A user with an existing ML-generated budget
- **When:** 30 more days of spending data is collected
- **Then:** The budget recommendations update to reflect new patterns

---

## Feature 3: Savings Recommendations

### AT-3.1: Receive personalized recommendations

- **Given:** A user with spending history
- **When:** The user views the recommendations page
- **Then:** At least 3 actionable savings recommendations are displayed

### AT-3.2: Recommendations are relevant

- **Given:** A user who spends heavily on dining out
- **When:** Recommendations are generated
- **Then:** At least one recommendation addresses dining spending

---

## Feature 4: Progress Tracking

### AT-4.1: Set financial goals

- **Given:** A logged-in user
- **When:** The user creates a goal with name, target amount, and deadline
- **Then:** The goal is saved and displayed on their dashboard

### AT-4.2: Visualize spending trends

- **Given:** A user with 3+ months of spending history
- **When:** The user views the trends page
- **Then:** A chart displays spending over time with category breakdown

---

## Feature 5: Alerts and Notifications

### AT-5.1: Budget limit warning

- **Given:** A user with a $200/month dining budget who has spent $180
- **When:** The user logs in or adds a new dining transaction
- **Then:** An alert warns they are approaching their dining limit
