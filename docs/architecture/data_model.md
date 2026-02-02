# Data Model

## Overview

This document describes the data model for SmartSpend.

## Entities

### User

- `user_id` (PK)
- `email`
- `password_hash`
- `created_at`
- `updated_at`

### Transaction

- `transaction_id` (PK)
- `user_id` (FK)
- `amount`
- `category`
- `description`
- `date`
- `created_at`

### Budget

- `budget_id` (PK)
- `user_id` (FK)
- `category`
- `amount_limit`
- `period` (weekly/monthly)
- `created_at`
- `updated_at`

### Goal

- `goal_id` (PK)
- `user_id` (FK)
- `name`
- `target_amount`
- `current_amount`
- `deadline`
- `created_at`

### Recommendation

- `recommendation_id` (PK)
- `user_id` (FK)
- `message`
- `category`
- `potential_savings`
- `created_at`

## Entity Relationship Diagram

[Insert ER diagram here]
