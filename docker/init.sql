-- SmartSpend database schema
-- This file runs automatically when the PostgreSQL container is first created.

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── Users ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    email       TEXT UNIQUE NOT NULL,
    name        TEXT NOT NULL,
    password    TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Transactions ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transactions (
    id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount      DOUBLE PRECISION NOT NULL,
    category    TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    date        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_transactions_user  ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date  ON transactions(date);

-- ── Budgets ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS budgets (
    id            TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id       TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category      TEXT NOT NULL,
    limit_amount  DOUBLE PRECISION NOT NULL,
    period        TEXT NOT NULL DEFAULT 'monthly',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_budgets_user ON budgets(user_id);

-- ── Goals ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS goals (
    id              TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id         TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    target_amount   DOUBLE PRECISION NOT NULL,
    target_date     TIMESTAMPTZ NOT NULL,
    description     TEXT NOT NULL DEFAULT '',
    progress        DOUBLE PRECISION NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_goals_user ON goals(user_id);

-- ── Recommendations (ML-generated) ────────────────────────────────────
CREATE TABLE IF NOT EXISTS recommendations (
    id                TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id           TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category          TEXT NOT NULL,
    title             TEXT NOT NULL,
    description       TEXT NOT NULL DEFAULT '',
    potential_savings DOUBLE PRECISION NOT NULL DEFAULT 0,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_recommendations_user ON recommendations(user_id);
