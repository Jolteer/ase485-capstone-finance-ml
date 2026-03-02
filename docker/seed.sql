-- SmartSpend seed data
-- Populates the database with a demo user and realistic sample data.
-- Password for demo user: password123
-- bcrypt hash generated with passlib (cost 12)

BEGIN;

-- ── Demo user ──────────────────────────────────────────────────────────
-- Delete existing demo user (cascade removes all related data)
DELETE FROM users WHERE email = 'demo@smartspend.dev';

INSERT INTO users (id, email, name, password) VALUES
    ('demo-user-0001', 'demo@smartspend.dev', 'Demo User',
     '$2b$12$v.4xVTRcfltX/8jDJ.2AU.iwkDwvePjSvKcM7a1eG2NmGK3yImWb2');

-- ── Transactions ───────────────────────────────────────────────────────
INSERT INTO transactions (user_id, amount, category, description, date) VALUES
    -- February 2026
    ('demo-user-0001', -85.40,   'Food',           'Grocery Store',           '2026-02-22T10:30:00Z'),
    ('demo-user-0001', -120.00,  'Bills',           'Electric Bill',           '2026-02-20T09:00:00Z'),
    ('demo-user-0001',  3200.00, 'Other',           'Salary Deposit',          '2026-02-15T08:00:00Z'),
    ('demo-user-0001', -15.99,   'Entertainment',   'Netflix',                 '2026-02-14T12:00:00Z'),
    ('demo-user-0001', -45.00,   'Transportation',  'Gas Station',             '2026-02-13T15:45:00Z'),
    ('demo-user-0001', -67.30,   'Shopping',        'Amazon Order',            '2026-02-12T14:20:00Z'),
    ('demo-user-0001', -24.50,   'Healthcare',      'Pharmacy',                '2026-02-10T11:00:00Z'),
    ('demo-user-0001', -49.99,   'Education',       'Online Course',           '2026-02-08T16:30:00Z'),
    -- More variety for richer analytics
    ('demo-user-0001', -42.15,   'Food',           'Restaurant dinner',       '2026-02-18T19:30:00Z'),
    ('demo-user-0001', -12.50,   'Food',           'Coffee shop',             '2026-02-17T08:15:00Z'),
    ('demo-user-0001', -8.99,    'Entertainment',   'Spotify',                 '2026-02-16T00:00:00Z'),
    ('demo-user-0001', -55.00,   'Bills',           'Internet Bill',           '2026-02-05T09:00:00Z'),
    ('demo-user-0001', -38.75,   'Shopping',        'Target',                  '2026-02-04T13:00:00Z'),
    ('demo-user-0001', -22.00,   'Transportation',  'Uber ride',               '2026-02-03T21:30:00Z'),
    ('demo-user-0001', -150.00,  'Bills',           'Car Insurance',           '2026-02-01T09:00:00Z'),
    -- January 2026
    ('demo-user-0001',  3200.00, 'Other',           'Salary Deposit',          '2026-01-15T08:00:00Z'),
    ('demo-user-0001', -92.30,   'Food',           'Grocery Store',           '2026-01-22T10:00:00Z'),
    ('demo-user-0001', -110.00,  'Bills',           'Electric Bill',           '2026-01-20T09:00:00Z'),
    ('demo-user-0001', -35.00,   'Entertainment',   'Movie tickets',           '2026-01-18T19:00:00Z'),
    ('demo-user-0001', -48.00,   'Transportation',  'Gas Station',             '2026-01-14T16:00:00Z'),
    ('demo-user-0001', -89.99,   'Shopping',        'New shoes',               '2026-01-12T14:00:00Z'),
    ('demo-user-0001', -30.00,   'Healthcare',      'Co-pay',                  '2026-01-10T10:00:00Z'),
    ('demo-user-0001', -55.00,   'Bills',           'Internet Bill',           '2026-01-05T09:00:00Z'),
    ('demo-user-0001', -150.00,  'Bills',           'Car Insurance',           '2026-01-01T09:00:00Z'),
    -- December 2025
    ('demo-user-0001',  3200.00, 'Other',           'Salary Deposit',          '2025-12-15T08:00:00Z'),
    ('demo-user-0001', -250.00,  'Shopping',        'Holiday gifts',           '2025-12-20T11:00:00Z'),
    ('demo-user-0001', -105.00,  'Food',           'Grocery Store',           '2025-12-18T10:30:00Z'),
    ('demo-user-0001', -65.00,   'Entertainment',   'Concert tickets',         '2025-12-12T20:00:00Z'),
    ('demo-user-0001', -125.00,  'Bills',           'Electric Bill',           '2025-12-10T09:00:00Z'),
    ('demo-user-0001', -40.00,   'Transportation',  'Gas Station',             '2025-12-08T15:00:00Z');

-- ── Budgets ────────────────────────────────────────────────────────────
INSERT INTO budgets (user_id, category, limit_amount, period) VALUES
    ('demo-user-0001', 'Food',           500,  'monthly'),
    ('demo-user-0001', 'Entertainment',  200,  'monthly'),
    ('demo-user-0001', 'Bills',          600,  'monthly'),
    ('demo-user-0001', 'Shopping',       300,  'monthly'),
    ('demo-user-0001', 'Transportation', 200,  'monthly'),
    ('demo-user-0001', 'Healthcare',     150,  'monthly'),
    ('demo-user-0001', 'Education',      100,  'monthly');

-- ── Goals ──────────────────────────────────────────────────────────────
INSERT INTO goals (user_id, target_amount, target_date, description, progress) VALUES
    ('demo-user-0001', 3000,  '2026-06-01T00:00:00Z', 'Vacation Fund',   1800),
    ('demo-user-0001', 50000, '2027-12-01T00:00:00Z', 'Down Payment',   12000),
    ('demo-user-0001', 5000,  '2026-01-01T00:00:00Z', 'Emergency Fund',  5000),
    ('demo-user-0001', 15000, '2027-03-01T00:00:00Z', 'New Car',         3200);

-- ── Recommendations ────────────────────────────────────────────────────
INSERT INTO recommendations (user_id, category, title, description, potential_savings) VALUES
    ('demo-user-0001', 'Food',
     'Reduce dining out',
     'You spent 30% more on restaurants this month compared to your average.',
     85),
    ('demo-user-0001', 'Entertainment',
     'Review subscriptions',
     'You have 3 subscriptions totaling $45/mo. Consider canceling unused ones.',
     15),
    ('demo-user-0001', 'Bills',
     'Lower utility costs',
     'Your electric bill is higher than similar households. Try off-peak usage.',
     30),
    ('demo-user-0001', 'Shopping',
     'Set a shopping limit',
     'Impulse purchases added up to $120 this month. A weekly cap could help.',
     60),
    ('demo-user-0001', 'Transportation',
     'Optimize commute',
     'Carpooling or public transit 2 days/week could save on gas.',
     40);

COMMIT;
