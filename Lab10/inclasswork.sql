-- Task 1
BEGIN;
UPDATE wallets SET balance = balance + 100.00 WHERE user_name
= 'Emma';
UPDATE wallets SET balance = balance - 50.00 WHERE user_name
= 'James';
ROLLBACK;

/*
 Emma balance = 500
 James balance = 300
 */



 -- Scenario B
BEGIN;
UPDATE tickets SET available = available - 5 WHERE event =
'Concert';
COMMIT;
UPDATE tickets SET available = available - 3 WHERE event =
'Concert';
ROLLBACK;

/*
    tickets = 95
 */


 -- Scenario C
BEGIN;
DELETE FROM wallets WHERE user_name = 'Sophie';
SAVEPOINT before_delete;
INSERT INTO wallets (user_name, balance) VALUES ('Sophie',
200.00);
ROLLBACK TO before_delete;
COMMIT;


/*
 Sophie does not exist on the tableds
 */


-- Task 2
/*
 2.1 - 100
 2.2 - 100
 2.3 - 90
 2.4 - Dirty read
 */

-- Task 3
/*
    3.1 - Yes, Durability
    3.2 - Yes, Consistency
    3.3 - Yes, Atomacity
    3.4 - Yes, Isolation
 */

-- Task 4
BEGIN;
UPDATE wallets SET balance = balance - 75.00
 WHERE user_name = 'Emma';
SAVEPOINT after_payment;
UPDATE tickets SET available = available - 1
 WHERE event = 'Theater';
COMMIT;



