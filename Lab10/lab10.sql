-- 3.1 Setup
CREATE TABLE accounts (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE products (
    id      SERIAL PRIMARY KEY,
    shop    VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price   DECIMAL(10, 2) NOT NULL
);

-- Insert test data
INSERT INTO accounts (name, balance) VALUES
    ('Alice', 1000.00),
    ('Bob',   500.00),
    ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
    ('Joe''s Shop', 'Coke',  2.50),
    ('Joe''s Shop', 'Pepsi', 3.00);



-- 3.2 Task 1
BEGIN;

UPDATE accounts
SET balance = balance - 100.00
WHERE name = 'Alice';

UPDATE accounts
SET balance = balance + 100.00
WHERE name = 'Bob';

COMMIT;

-- Questions:
-- a) Alice's balance is 900 and Bob's is 600
-- b) Ensures atomicity: either whole process succeeds or none
-- c) Without transaction Alice would lose 100 but Bob wouldn't get +100



-- 3.3 Task 2
BEGIN;

UPDATE accounts
SET balance = balance - 500.00
WHERE name = 'Alice';

SELECT *
FROM accounts
WHERE name = 'Alice';

-- Oops! Wrong amount
ROLLBACK;

SELECT *
FROM accounts
WHERE name = 'Alice';

-- Questions:
-- a) 400
-- b) 900
-- c) Used when user cancels operation or error occurs



-- 3.4 Task 3
BEGIN;

UPDATE accounts
SET balance = balance - 100.00
WHERE name = 'Alice';

SAVEPOINT my_savepoint;

UPDATE accounts
SET balance = balance + 100.00
WHERE name = 'Bob';

-- Wrong target
ROLLBACK TO my_savepoint;

UPDATE accounts
SET balance = balance + 100.00
WHERE name = 'Wally';

COMMIT;

-- Questions:
-- a) Alice = 800, Bob = 600, Wally = 850
-- b) Yes, but undone by rollback to savepoint
-- c) SAVEPOINT allows partial rollback inside transaction



-- 3.5 Task 4
-- SCENARIO A — READ COMMITTED

-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT *
FROM products
WHERE shop = 'Joe''s Shop';

-- Wait for Terminal 2 to COMMIT
SELECT *
FROM products
WHERE shop = 'Joe''s Shop';

COMMIT;

-- Terminal 2
BEGIN;

DELETE
FROM products
WHERE shop = 'Joe''s Shop';

INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);

COMMIT;


-- SCENARIO B — SERIALIZABLE

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT *
FROM products
WHERE shop = 'Joe''s Shop';

-- Wait for changes
SELECT *
FROM products
WHERE shop = 'Joe''s Shop';

COMMIT;

-- Terminal 2
BEGIN;

DELETE
FROM products
WHERE shop = 'Joe''s Shop';

INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);

COMMIT;

-- Questions:
-- a) Terminal 1 sees old data, then new after commit
-- b) Terminal 1 sees snapshot unaffected by Terminal 2
-- c) READ COMMITTED → non-repeatable reads; SERIALIZABLE → full consistency



-- 3.6 Task 5
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT MAX(price), MIN(price)
FROM products
WHERE shop = 'Joe''s Shop';

-- Wait
SELECT MAX(price), MIN(price)
FROM products
WHERE shop = 'Joe''s Shop';

COMMIT;

-- Terminal 2
BEGIN;

INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Sprite', 4.00);

COMMIT;

-- Questions:
-- a) No
-- b) Phantom read = new rows appear between reads
-- c) Prevented by SERIALIZABLE



-- 3.7 Task 6
-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT *
FROM products
WHERE shop = 'Joe''s Shop';

SELECT *
FROM products
WHERE shop = 'Joe''s Shop';

SELECT *
FROM products
WHERE shop = 'Joe''s Shop';

COMMIT;

-- Terminal 2
BEGIN;

UPDATE products
SET price = 99.99
WHERE product = 'Fanta';

-- Wait
ROLLBACK;

-- Questions:
-- a) Yes, Terminal 1 reads dirty uncommitted data
-- b) Dirty read = reading uncommitted data
-- c) Unsafe because data might be rollbacked



-- 4.1
DO $$
DECLARE
    bob_balance NUMERIC(10, 2);
BEGIN
    SELECT balance
    INTO bob_balance
    FROM accounts
    WHERE name = 'Bob'
    FOR UPDATE;

    IF bob_balance < 200 THEN
        RAISE EXCEPTION 'No sufficient funds';
    END IF;

    UPDATE accounts
    SET balance = balance - 200
    WHERE name = 'Bob';

    UPDATE accounts
    SET balance = balance + 200
    WHERE name = 'Wally';
END;
$$;

COMMIT;



-- 4.2
BEGIN;

INSERT INTO products (shop, product, price)
VALUES ('FixPrice', 'TestProduct123', 1.11);

SAVEPOINT my_savepoint1;

UPDATE products
SET price = price + 5
WHERE product = 'TestProduct123';

SAVEPOINT my_savepoint2;

DELETE
FROM products
WHERE product = 'TestProduct123';

ROLLBACK TO my_savepoint1;

COMMIT;

SELECT *
FROM products;



-- 4.3
INSERT INTO accounts (name, balance)
VALUES ('Test', 1000.00);

-- SCENARIO 1 — NO TRANSACTIONS
-- Terminal 1
SELECT balance FROM accounts WHERE name = 'Test';
UPDATE accounts SET balance = balance - 700 WHERE name = 'Test';

-- Terminal 2
SELECT balance FROM accounts WHERE name = 'Test';
UPDATE accounts SET balance = balance - 500 WHERE name = 'Test';
-- Final balance = –200 overdraft


-- SCENARIO 2 — READ COMMITTED
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT balance
FROM accounts
WHERE name = 'Test';

UPDATE accounts
SET balance = balance - 700
WHERE name = 'Test';

COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT balance
FROM accounts
WHERE name = 'Test';

UPDATE accounts
SET balance = balance - 500
WHERE name = 'Test';

COMMIT;


-- SCENARIO 3 — REPEATABLE READ
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT balance
FROM accounts
WHERE name = 'Test'
FOR UPDATE;

UPDATE accounts
SET balance = balance - 700
WHERE name = 'Test';

COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT balance
FROM accounts
WHERE name = 'Test'
FOR UPDATE;

UPDATE accounts
SET balance = balance - 500
WHERE name = 'Test';

COMMIT;


-- SCENARIO 4 — SERIALIZABLE
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT balance
FROM accounts
WHERE name = 'Test'
FOR UPDATE;

UPDATE accounts
SET balance = balance - 700
WHERE name = 'Test' AND balance >= 700;

COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT balance
FROM accounts
WHERE name = 'Test'
FOR UPDATE;

UPDATE accounts
SET balance = balance - 500
WHERE name = 'Test' AND balance >= 500;

COMMIT;



-- 4.4
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Coke', 1.00),
       ('Joe''s Shop', 'Coke', 4.00);

-- Sally
SELECT MAX(price)
FROM products
WHERE product = 'Coke';

-- Joe
UPDATE products
SET price = 1.50
WHERE product = 'Coke' AND price = 4.00;

DELETE
FROM products
WHERE product = 'Coke' AND price = 1.00;

-- Sally
SELECT MIN(price)
FROM products
WHERE product = 'Coke';

-- Fix
BEGIN;

UPDATE products
SET price = 1.50
WHERE product = 'Coke' AND price = 4.00;

DELETE
FROM products
WHERE product = 'Coke' AND price = 1.00;

COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT MAX(price)
FROM products
WHERE product = 'Coke';

SELECT MIN(price)
FROM products
WHERE product = 'Coke';

COMMIT;



-- 5. Questions
-- 1. Atomic – all or nothing.
--    Consistent – constraints preserved.
--    Isolated – appears sequential.
--    Durable – survives crashes.
--
-- 2. COMMIT → save changes.
--    ROLLBACK → undo changes.
--
-- 3. SAVEPOINT used to undo partial work.
--
-- 4. Isolation levels:
--    READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE.
--
-- 5. Dirty read → READ UNCOMMITTED.
--
-- 6. Non-repeatable read → same row returns different values.
--
-- 7. Phantom read → different row set.
--
-- 8. READ COMMITTED faster, fewer locks.
--
-- 9. Transactions prevent inconsistencies under concurrency.
--
-- 10. Crash → all uncommitted work discarded.