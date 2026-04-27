-- Extra demo data to showcase the recommendation engine.
-- Adds March 2026 (previous month) and April 2026 (current month) activity for
-- demo@smartspend.dev so the rule-based engine in app.ml_engine fires every rule:
--   * over-budget         (Food, Entertainment, Bills, Shopping, Transportation)
--   * spending spike      (most categories: April >> March)
--   * missing budget      (Healthcare budget removed below)
--   * high expense ratio  (April expenses > 80% of April income)
--
-- Re-runnable: removes any prior March/April 2026 rows for the demo user first.

BEGIN;

-- Clean slate for the months we are seeding so this script is idempotent.
DELETE FROM transactions
 WHERE user_id = 'demo-user-0001'
   AND date >= '2026-03-01T00:00:00Z'
   AND date <  '2026-05-01T00:00:00Z';

-- Drop the Healthcare budget so the "Set a budget" rule has a category to flag.
DELETE FROM budgets
 WHERE user_id = 'demo-user-0001'
   AND category = 'Healthcare';

-- ── March 2026 (previous month — kept low so April looks like a spike) ──────
INSERT INTO transactions (user_id, amount, category, description, date) VALUES
    ('demo-user-0001',  3200.00, 'Other',          'Salary Deposit',         '2026-03-15T08:00:00Z'),
    -- Food: $312.50
    ('demo-user-0001',   -85.00, 'Food',           'Grocery Store',          '2026-03-22T10:00:00Z'),
    ('demo-user-0001',   -42.00, 'Food',           'Italian restaurant',     '2026-03-18T19:30:00Z'),
    ('demo-user-0001',   -10.50, 'Food',           'Coffee shop',            '2026-03-17T08:30:00Z'),
    ('demo-user-0001',   -78.00, 'Food',           'Grocery Store',          '2026-03-12T11:00:00Z'),
    ('demo-user-0001',   -32.00, 'Food',           'Lunch at deli',          '2026-03-08T12:30:00Z'),
    ('demo-user-0001',   -65.00, 'Food',           'Grocery Store',          '2026-03-05T10:00:00Z'),
    -- Entertainment: $24.98 (just streaming)
    ('demo-user-0001',   -15.99, 'Entertainment',  'Netflix',                '2026-03-14T00:00:00Z'),
    ('demo-user-0001',    -8.99, 'Entertainment',  'Spotify',                '2026-03-14T00:00:00Z'),
    -- Bills: $465
    ('demo-user-0001',  -150.00, 'Bills',          'Car Insurance',          '2026-03-01T09:00:00Z'),
    ('demo-user-0001',   -55.00, 'Bills',          'Internet Bill',          '2026-03-05T09:00:00Z'),
    ('demo-user-0001',   -85.00, 'Bills',          'Phone Bill',             '2026-03-07T09:00:00Z'),
    ('demo-user-0001',  -125.00, 'Bills',          'Electric Bill',          '2026-03-10T09:00:00Z'),
    ('demo-user-0001',   -50.00, 'Bills',          'Streaming bundle',       '2026-03-15T09:00:00Z'),
    -- Shopping: $83
    ('demo-user-0001',   -45.00, 'Shopping',       'Target',                 '2026-03-12T13:00:00Z'),
    ('demo-user-0001',   -38.00, 'Shopping',       'Amazon order',           '2026-03-20T15:00:00Z'),
    -- Transportation: $120
    ('demo-user-0001',   -50.00, 'Transportation', 'Gas Station',            '2026-03-04T16:00:00Z'),
    ('demo-user-0001',   -45.00, 'Transportation', 'Gas Station',            '2026-03-14T15:00:00Z'),
    ('demo-user-0001',   -25.00, 'Transportation', 'Uber ride',              '2026-03-22T20:00:00Z'),
    -- Healthcare: $30
    ('demo-user-0001',   -30.00, 'Healthcare',     'Pharmacy',               '2026-03-10T11:00:00Z'),
    -- Education: $45
    ('demo-user-0001',   -45.00, 'Education',      'Online course',          '2026-03-08T16:30:00Z');

-- ── April 2026 (current month — high spend across many categories) ─────────
INSERT INTO transactions (user_id, amount, category, description, date) VALUES
    ('demo-user-0001',  3200.00, 'Other',          'Salary Deposit',         '2026-04-15T08:00:00Z'),
    -- Food: ~$600 (over $500 budget, 92% spike vs March $312.50)
    ('demo-user-0001',   -85.40, 'Food',           'Grocery Store',          '2026-04-02T10:30:00Z'),
    ('demo-user-0001',   -54.99, 'Food',           'Italian restaurant',     '2026-04-04T19:30:00Z'),
    ('demo-user-0001',   -12.50, 'Food',           'Coffee shop',            '2026-04-06T08:15:00Z'),
    ('demo-user-0001',   -78.20, 'Food',           'Grocery Store',          '2026-04-09T10:00:00Z'),
    ('demo-user-0001',   -42.00, 'Food',           'Sushi takeout',          '2026-04-11T19:00:00Z'),
    ('demo-user-0001',    -8.99, 'Food',           'Coffee shop',            '2026-04-13T08:30:00Z'),
    ('demo-user-0001',   -68.50, 'Food',           'Grocery Store',          '2026-04-16T10:30:00Z'),
    ('demo-user-0001',   -55.00, 'Food',           'Steakhouse dinner',      '2026-04-18T20:00:00Z'),
    ('demo-user-0001',   -28.99, 'Food',           'Pizza delivery',         '2026-04-19T19:30:00Z'),
    ('demo-user-0001',   -15.50, 'Food',           'Brunch',                 '2026-04-21T11:00:00Z'),
    ('demo-user-0001',   -32.50, 'Food',           'Tacos lunch',            '2026-04-23T12:30:00Z'),
    ('demo-user-0001',   -88.40, 'Food',           'Grocery Store',          '2026-04-24T10:30:00Z'),
    ('demo-user-0001',   -29.00, 'Food',           'DoorDash dinner',        '2026-04-25T19:00:00Z'),
    -- Entertainment: ~$300 (over $200 budget, huge spike vs March $24.98)
    ('demo-user-0001',   -85.00, 'Entertainment',  'Concert tickets',        '2026-04-03T20:00:00Z'),
    ('demo-user-0001',   -48.00, 'Entertainment',  'Movie tickets',          '2026-04-08T19:00:00Z'),
    ('demo-user-0001',   -15.99, 'Entertainment',  'Netflix',                '2026-04-14T00:00:00Z'),
    ('demo-user-0001',    -8.99, 'Entertainment',  'Spotify',                '2026-04-14T00:00:00Z'),
    ('demo-user-0001',   -22.00, 'Entertainment',  'Bowling night',          '2026-04-17T21:00:00Z'),
    ('demo-user-0001',   -65.00, 'Entertainment',  'Theme park ticket',      '2026-04-20T11:00:00Z'),
    ('demo-user-0001',   -55.00, 'Entertainment',  'Live show',              '2026-04-22T20:00:00Z'),
    -- Bills: $620 (over $600 budget, spike vs March $465)
    ('demo-user-0001',  -150.00, 'Bills',          'Car Insurance',          '2026-04-01T09:00:00Z'),
    ('demo-user-0001',   -55.00, 'Bills',          'Internet Bill',          '2026-04-05T09:00:00Z'),
    ('demo-user-0001',   -90.00, 'Bills',          'Phone Bill',             '2026-04-07T09:00:00Z'),
    ('demo-user-0001',  -135.00, 'Bills',          'Electric Bill',          '2026-04-10T09:00:00Z'),
    ('demo-user-0001',   -75.00, 'Bills',          'Water Bill',             '2026-04-12T09:00:00Z'),
    ('demo-user-0001',   -65.00, 'Bills',          'Streaming bundle',       '2026-04-15T09:00:00Z'),
    ('demo-user-0001',   -50.00, 'Bills',          'Gym membership',         '2026-04-25T09:00:00Z'),
    -- Shopping: $700 (way over $300 budget, huge spike vs March $83)
    ('demo-user-0001',  -120.00, 'Shopping',       'Amazon order',           '2026-04-02T14:00:00Z'),
    ('demo-user-0001',  -180.00, 'Shopping',       'New running shoes',      '2026-04-06T15:30:00Z'),
    ('demo-user-0001',   -65.00, 'Shopping',       'Target',                 '2026-04-11T13:00:00Z'),
    ('demo-user-0001',  -150.00, 'Shopping',       'Spring wardrobe',        '2026-04-15T16:00:00Z'),
    ('demo-user-0001',   -95.00, 'Shopping',       'Home decor',             '2026-04-19T14:00:00Z'),
    ('demo-user-0001',   -50.00, 'Shopping',       'Amazon order',           '2026-04-22T13:00:00Z'),
    ('demo-user-0001',   -40.00, 'Shopping',       'Hardware store',         '2026-04-24T11:00:00Z'),
    -- Transportation: $215.50 (over $200 budget, spike vs March $120)
    ('demo-user-0001',   -55.00, 'Transportation', 'Gas Station',            '2026-04-04T16:00:00Z'),
    ('demo-user-0001',   -22.50, 'Transportation', 'Uber ride',              '2026-04-09T21:30:00Z'),
    ('demo-user-0001',   -50.00, 'Transportation', 'Gas Station',            '2026-04-14T15:30:00Z'),
    ('demo-user-0001',   -28.00, 'Transportation', 'Lyft ride',              '2026-04-18T22:00:00Z'),
    ('demo-user-0001',   -45.00, 'Transportation', 'Gas Station',            '2026-04-22T15:00:00Z'),
    ('demo-user-0001',   -15.00, 'Transportation', 'Parking garage',         '2026-04-26T13:00:00Z'),
    -- Healthcare: $193 (no budget — triggers "Set a budget" rule)
    ('demo-user-0001',  -120.00, 'Healthcare',     'Doctor visit',           '2026-04-08T10:00:00Z'),
    ('demo-user-0001',   -45.00, 'Healthcare',     'Pharmacy',               '2026-04-16T11:30:00Z'),
    ('demo-user-0001',   -28.00, 'Healthcare',     'Prescription refill',    '2026-04-23T14:00:00Z'),
    -- Education: $80 (within budget but spike vs March $45)
    ('demo-user-0001',   -50.00, 'Education',      'Online course',          '2026-04-12T16:30:00Z'),
    ('demo-user-0001',   -30.00, 'Education',      'Textbook',               '2026-04-20T11:00:00Z');

COMMIT;
