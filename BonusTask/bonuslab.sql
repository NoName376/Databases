DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS exchange_rates CASCADE;
DROP TABLE IF EXISTS audit_log CASCADE;

DROP TYPE IF EXISTS transaction_status;
DROP TYPE IF EXISTS transaction_type;



CREATE TYPE transaction_status AS ENUM ('pending','completed','failed','reversed');
CREATE TYPE transaction_type   AS ENUM ('transfer','deposit','withdrawal');



CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    iin CHAR(12) UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','blocked','frozen')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    daily_limit_kzt NUMERIC(18,2) NOT NULL
);
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(customer_id),
    account_number TEXT NOT NULL UNIQUE,
    currency TEXT NOT NULL CHECK (currency IN ('KZT','USD','EUR','RUB')),
    balance NUMERIC(18,2) NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    opened_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    closed_at TIMESTAMPTZ
);
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    from_account_id BIGINT REFERENCES accounts(account_id),
    to_account_id BIGINT REFERENCES accounts(account_id),
    amount NUMERIC(18,2) NOT NULL,
    currency TEXT NOT NULL CHECK(currency IN ('KZT','USD','EUR','RUB')),
    exchange_rate NUMERIC(18,6) NOT NULL,
    amount_kzt NUMERIC(18,2) NOT NULL,
    type transaction_type NOT NULL,
    status transaction_status NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ,
    description TEXT
);
CREATE TABLE exchange_rates (
    rate_id SERIAL PRIMARY KEY,
    from_currency TEXT NOT NULL CHECK(from_currency IN ('KZT','USD','EUR','RUB')),
    to_currency TEXT NOT NULL CHECK(to_currency IN ('KZT','USD','EUR','RUB')),
    rate NUMERIC(18,6) NOT NULL,
    valid_from TIMESTAMPTZ NOT NULL,
    valid_to TIMESTAMPTZ
);
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id BIGINT,
    action TEXT NOT NULL,
    old_values JSONB,
    new_values JSONB,
    changed_by TEXT,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    ip_address TEXT
);


-- Example Inserts
INSERT INTO customers (iin, full_name, phone, email, status, daily_limit_kzt)
VALUES
('010101010101','Aibek Kuralbaev','+77010000001','aibek@kbtu.kz','active', 2_000_000),
('020202020202','Abdulaziz Bakhramov','+77010000002','abdulaziz@kbtu.kz','active', 1_000_000),
('030303030303','Anuar Batyrbekov','+77010000003','anuar@kbtu.kz','active', 5_000_000),
('040404040404','Alina Karim','+77010000004','alina@kbtu.kz','blocked', 500_000),
('050505050505','Samat Erkin','+77010000005','samat@kbtu.kz','active', 1_500_000),
('060606060606','Dana Ruslan','+77010000006','dana@kbtu.kz','active', 800_000),
('070707070707','Ilyas Timur','+77010000007','ilyas@kbtu.kz','active', 3_000_000),
('080808080808','Miras Askar','+77010000008','miras@kbtu.kz','frozen', 1_000_000),
('090909090909','Aruzhan Serik','+77010000009','aruzhan@kbtu.kz','active', 2_500_000),
('101010101010','Nurasyl Bek','+77010000010','nurasyl@kbtu.kz','active', 4_000_000);

INSERT INTO accounts (customer_id, account_number, currency, balance, is_active)
VALUES
(1, 'KZ000000000000000001','KZT', 3_000_000, TRUE),
(1, 'KZ000000000000000002','USD', 5_000,     TRUE),
(2, 'KZ000000000000000003','KZT', 800_000,  TRUE),
(3, 'KZ000000000000000004','KZT', 10_000_000, TRUE),
(3, 'KZ000000000000000005','USD', 20_000,     TRUE),
(4, 'KZ000000000000000006','KZT', 100_000,  TRUE),
(5, 'KZ000000000000000007','EUR', 3_000,    TRUE),
(6, 'KZ000000000000000008','KZT', 600_000,  TRUE),
(7, 'KZ000000000000000009','RUB', 200_000,  TRUE),
(8, 'KZ000000000000000010','KZT', 400_000,  TRUE),
(9, 'KZ000000000000000011','KZT', 1_500_000, TRUE),
(10,'KZ000000000000000012','KZT', 7_000_000, TRUE);

INSERT INTO transactions
(from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, description)
VALUES
(1, 3, 150000, 'KZT', 1.0, 150000, 'transfer', 'completed', 'Refund'),
(4, 1, 500000, 'KZT', 1.0, 500000, 'transfer', 'completed', 'Refund'),
(2, NULL, 1000, 'USD', 470.0, 470000, 'withdrawal', 'pending', 'Refund'),
(NULL, 1, 200000, 'KZT', 1.0, 200000, 'deposit', 'completed', 'Cash deposit'),
(5, 7, 2000, 'USD', 470.0, 940000, 'transfer', 'failed', 'Limits exceeded'),
(8, 10, 150000, 'KZT', 1.0, 150000, 'transfer', 'completed', 'Payment'),
(11, 15, 50000, 'KZT', 1.0, 50000, 'transfer', 'reversed', 'Payment'),
(12, NULL, 500, 'USD', 470.0, 235000, 'withdrawal', 'completed', 'Cashout'),
(13, 1, 1000, 'EUR', 500.0, 500000, 'transfer', 'completed', 'EUR -> KZT'),
(14, NULL, 120000, 'KZT', 1.0, 120000, 'withdrawal', 'pending', 'Transfer'),
(15, 2, 50, 'RUB', 5.0, 250, 'transfer', 'completed', 'Transfer'),
(3, 5, 300000, 'KZT', 1.0, 300000, 'transfer', 'completed', 'Payment');


INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from, valid_to)
VALUES
('KZT','KZT',1.0, now() - INTERVAL '1 day', NULL),
('USD','KZT',470.0, now() - INTERVAL '1 day', NULL),
('EUR','KZT',500.0, now() - INTERVAL '1 day', NULL),
('RUB','KZT',5.0,   now() - INTERVAL '1 day', NULL),
('KZT','USD',1.0/470.0, now() - INTERVAL '1 day', NULL),
('KZT','EUR',1.0/500.0, now() - INTERVAL '1 day', NULL),
('KZT','RUB',1.0/5.0,   now() - INTERVAL '1 day', NULL),
('USD','EUR',470.0/500.0, now() - INTERVAL '1 day', NULL),
('EUR','USD',500.0/470.0, now() - INTERVAL '1 day', NULL),
('USD','RUB',470.0/5.0, now() - INTERVAL '1 day', NULL);

INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, changed_by, ip_address)
VALUES
('customers', 1, 'UPDATE', '{"status":"active"}', '{"status":"blocked"}', 'system', '127.0.0.1'),
('accounts', 4, 'UPDATE', '{"balance":10000000}', '{"balance":9500000}', 'system', '127.0.0.1'),
('transactions', 1, 'INSERT', NULL, '{"amount":150000}', 'system', '127.0.0.1'),
('accounts', 7, 'UPDATE', '{"is_active":true}', '{"is_active":false}', 'admin', '127.0.0.1'),
('customers', 4, 'UPDATE', '{"status":"blocked"}', '{"status":"active"}', 'admin', '127.0.0.1'),
('transactions', 5, 'UPDATE', '{"status":"pending"}', '{"status":"failed"}', 'system', '127.0.0.1'),
('exchange_rates', 3, 'UPDATE', '{"rate":500}', '{"rate":505}', 'system', '127.0.0.1'),
('accounts', 12, 'INSERT', NULL, '{"balance":7000000}', 'system', '127.0.0.1'),
('transactions', 7, 'UPDATE', '{"status":"completed"}', '{"status":"reversed"}', 'system', '127.0.0.1'),
('customers', 9, 'UPDATE', '{"phone":"+77010000009"}', '{"phone":"+77015555555"}', 'admin', '127.0.0.1');




-- Task 1
CREATE OR REPLACE FUNCTION process_transfer(
    p_from_account_number TEXT,
    p_to_account_number TEXT,
    p_amount NUMERIC(18,2),
    p_currency TEXT,
    p_description TEXT,
    p_changed_by TEXT DEFAULT 'system',
    p_ip_address TEXT DEFAULT '127.0.0.1',
    p_bypass_daily_limit BOOLEAN DEFAULT FALSE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_from_account accounts%ROWTYPE;
    v_to_account accounts%ROWTYPE;
    v_from_customer customers%ROWTYPE;
    v_to_customer customers%ROWTYPE;
    v_rate_to_kzt NUMERIC(18,6);
    v_rate_between NUMERIC(18,6);
    v_amount_kzt NUMERIC(18,2);
    v_today_total_kzt NUMERIC(18,2);
    v_tx_id BIGINT;
    v_error_code TEXT;
    v_error_message TEXT;
BEGIN
    IF p_amount IS NULL OR p_amount <= 0 THEN
        v_error_code := 'INVALID_AMOUNT';
        v_error_message := 'Amount must be positive';
        INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
        VALUES(
            'transactions',
            NULL,
            'FAILED_TRANSFER',
            NULL,
            jsonb_build_object(
                'from_account_number', p_from_account_number,
                'to_account_number', p_to_account_number,
                'amount', p_amount,
                'currency', p_currency,
                'reason', v_error_message
            ),
            p_changed_by,
            p_ip_address
        );
        RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
    END IF;

    SELECT *
    INTO v_from_account
    FROM accounts
    WHERE account_number = p_from_account_number
    FOR UPDATE;

    IF NOT FOUND THEN
        v_error_code := 'FROM_ACCOUNT_NOT_FOUND';
        v_error_message := 'Source account not found';
        INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
        VALUES(
            'accounts',
            NULL,
            'FAILED_TRANSFER',
            NULL,
            jsonb_build_object(
                'from_account_number', p_from_account_number,
                'reason', v_error_message
            ),
            p_changed_by,
            p_ip_address
        );
        RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
    END IF;

    SELECT *
    INTO v_to_account
    FROM accounts
    WHERE account_number = p_to_account_number
    FOR UPDATE;

    IF NOT FOUND THEN
        v_error_code := 'TO_ACCOUNT_NOT_FOUND';
        v_error_message := 'Destination account not found';
        INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
        VALUES(
            'accounts',
            NULL,
            'FAILED_TRANSFER',
            NULL,
            jsonb_build_object(
                'to_account_number', p_to_account_number,
                'reason', v_error_message
            ),
            p_changed_by,
            p_ip_address
        );
        RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
    END IF;

    IF NOT v_from_account.is_active THEN
        v_error_code := 'FROM_ACCOUNT_INACTIVE';
        v_error_message := 'Source account is not active';
        INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
        VALUES(
            'accounts',
            v_from_account.account_id,
            'FAILED_TRANSFER',
            to_jsonb(v_from_account),
            jsonb_build_object('reason', v_error_message),
            p_changed_by,
            p_ip_address
        );
        RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
    END IF;

    IF NOT v_to_account.is_active THEN
        v_error_code := 'TO_ACCOUNT_INACTIVE';
        v_error_message := 'Destination account is not active';
        INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
        VALUES(
            'accounts',
            v_to_account.account_id,
            'FAILED_TRANSFER',
            to_jsonb(v_to_account),
            jsonb_build_object('reason', v_error_message),
            p_changed_by,
            p_ip_address
        );
        RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
    END IF;

    IF v_from_account.currency <> p_currency THEN
        v_error_code := 'CURRENCY_MISMATCH';
        v_error_message := 'Currency does not match source account currency';
        INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
        VALUES(
            'transactions',
            NULL,
            'FAILED_TRANSFER',
            NULL,
            jsonb_build_object(
                'from_account_number', p_from_account_number,
                'account_currency', v_from_account.currency,
                'request_currency', p_currency,
                'reason', v_error_message
            ),
            p_changed_by,
            p_ip_address
        );
        RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
    END IF;

    SELECT *
    INTO v_from_customer
    FROM customers
    WHERE customer_id = v_from_account.customer_id
    FOR UPDATE;

    SELECT *
    INTO v_to_customer
    FROM customers
    WHERE customer_id = v_to_account.customer_id;

    IF v_from_customer.status <> 'active' THEN
        v_error_code := 'CUSTOMER_NOT_ACTIVE';
        v_error_message := 'Sender customer status is not active';
        INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
        VALUES(
            'customers',
            v_from_customer.customer_id,
            'FAILED_TRANSFER',
            to_jsonb(v_from_customer),
            jsonb_build_object('reason', v_error_message),
            p_changed_by,
            p_ip_address
        );
        RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
    END IF;

    IF v_from_account.balance < p_amount THEN
        v_error_code := 'INSUFFICIENT_FUNDS';
        v_error_message := 'Insufficient funds';
        INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
        VALUES(
            'accounts',
            v_from_account.account_id,
            'FAILED_TRANSFER',
            to_jsonb(v_from_account),
            jsonb_build_object(
                'requested_amount', p_amount,
                'reason', v_error_message
            ),
            p_changed_by,
            p_ip_address
        );
        RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
    END IF;

    SELECT rate
    INTO v_rate_to_kzt
    FROM exchange_rates
    WHERE from_currency = v_from_account.currency
      AND to_currency = 'KZT'
      AND valid_from <= now()
      AND (valid_to IS NULL OR valid_to > now())
    ORDER BY valid_from DESC
    LIMIT 1;

    IF v_rate_to_kzt IS NULL THEN
        v_error_code := 'NO_RATE_TO_KZT';
        v_error_message := 'No FX rate to KZT';
        INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
        VALUES(
            'exchange_rates',
            NULL,
            'FAILED_TRANSFER',
            NULL,
            jsonb_build_object(
                'from_currency', v_from_account.currency,
                'to_currency', 'KZT',
                'reason', v_error_message
            ),
            p_changed_by,
            p_ip_address
        );
        RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
    END IF;

    v_amount_kzt := round(p_amount * v_rate_to_kzt, 2);

    IF NOT p_bypass_daily_limit THEN
        SELECT COALESCE(SUM(amount_kzt),0)
        INTO v_today_total_kzt
        FROM transactions t
        JOIN accounts a ON a.account_id = t.from_account_id
        WHERE a.customer_id = v_from_customer.customer_id
          AND t.created_at::date = now()::date
          AND t.status IN ('pending','completed');

        IF v_today_total_kzt + v_amount_kzt > v_from_customer.daily_limit_kzt THEN
            v_error_code := 'DAILY_LIMIT_EXCEEDED';
            v_error_message := 'Daily limit exceeded';
            INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
            VALUES(
                'customers',
                v_from_customer.customer_id,
                'FAILED_TRANSFER',
                to_jsonb(v_from_customer),
                jsonb_build_object(
                    'today_total_kzt', v_today_total_kzt,
                    'new_amount_kzt', v_amount_kzt,
                    'limit_kzt', v_from_customer.daily_limit_kzt,
                    'reason', v_error_message
                ),
                p_changed_by,
                p_ip_address
            );
            RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
        END IF;
    END IF;

    IF v_from_account.currency = v_to_account.currency THEN
        v_rate_between := 1.0;
    ELSE
        SELECT rate
        INTO v_rate_between
        FROM exchange_rates
        WHERE from_currency = v_from_account.currency
          AND to_currency = v_to_account.currency
          AND valid_from <= now()
          AND (valid_to IS NULL OR valid_to > now())
        ORDER BY valid_from DESC
        LIMIT 1;

        IF v_rate_between IS NULL THEN
            v_error_code := 'NO_RATE_BETWEEN_ACCOUNTS';
            v_error_message := 'No FX rate between account currencies';
            INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
            VALUES(
                'exchange_rates',
                NULL,
                'FAILED_TRANSFER',
                NULL,
                jsonb_build_object(
                    'from_currency', v_from_account.currency,
                    'to_currency', v_to_account.currency,
                    'reason', v_error_message
                ),
                p_changed_by,
                p_ip_address
            );
            RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
        END IF;
    END IF;

    BEGIN
        UPDATE accounts
        SET balance = balance - p_amount
        WHERE account_id = v_from_account.account_id;

        UPDATE accounts
        SET balance = balance + p_amount * v_rate_between
        WHERE account_id = v_to_account.account_id;

        INSERT INTO transactions(
            from_account_id,
            to_account_id,
            amount,
            currency,
            exchange_rate,
            amount_kzt,
            type,
            status,
            created_at,
            description
        )
        VALUES(
            v_from_account.account_id,
            v_to_account.account_id,
            p_amount,
            v_from_account.currency,
            v_rate_to_kzt,
            v_amount_kzt,
            'transfer',
            'completed',
            now(),
            p_description
        )
        RETURNING transaction_id
        INTO v_tx_id;

        INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
        VALUES(
            'transactions',
            v_tx_id,
            'INSERT',
            NULL,
            jsonb_build_object(
                'from_account_id', v_from_account.account_id,
                'to_account_id', v_to_account.account_id,
                'amount', p_amount,
                'currency', v_from_account.currency,
                'amount_kzt', v_amount_kzt,
                'description', p_description
            ),
            p_changed_by,
            p_ip_address
        );

        RETURN jsonb_build_object(
            'status','OK',
            'code','SUCCESS',
            'message','Transfer completed',
            'transaction_id',v_tx_id,
            'amount_kzt',v_amount_kzt
        );
    EXCEPTION
        WHEN OTHERS THEN
            v_error_code := 'TRANSFER_ERROR';
            v_error_message := SQLERRM;
            INSERT INTO audit_log(table_name, record_id, action, old_values, new_values, changed_by, ip_address)
            VALUES(
                'transactions',
                v_tx_id,
                'FAILED_TRANSFER',
                NULL,
                jsonb_build_object(
                    'from_account_id', v_from_account.account_id,
                    'to_account_id', v_to_account.account_id,
                    'amount', p_amount,
                    'currency', v_from_account.currency,
                    'reason', v_error_message
                ),
                p_changed_by,
                p_ip_address
            );
            RETURN jsonb_build_object('status','ERROR','code',v_error_code,'message',v_error_message);
    END;
END;
$$;



-- Task 2
CREATE OR REPLACE VIEW customer_balance_summary AS
WITH latest_rates AS (
    SELECT
        from_currency,
        to_currency,
        rate,
        row_number() OVER(
            PARTITION BY from_currency, to_currency
            ORDER BY valid_from DESC
        ) AS rn
    FROM exchange_rates
    WHERE to_currency = 'KZT'
      AND valid_from <= now()
      AND (valid_to IS NULL OR valid_to > now())
),
account_balances AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.status,
        c.daily_limit_kzt,
        a.account_id,
        a.account_number,
        a.currency,
        a.balance,
        a.is_active,
        a.opened_at,
        a.closed_at,
        (a.balance * COALESCE(r.rate,1.0))::NUMERIC(18,2) AS balance_kzt
    FROM customers c
    JOIN accounts a ON a.customer_id = c.customer_id
    LEFT JOIN latest_rates r
        ON r.from_currency = a.currency
       AND r.to_currency = 'KZT'
       AND r.rn = 1
),
customer_totals AS (
    SELECT
        customer_id,
        SUM(balance_kzt) AS total_balance_kzt
    FROM account_balances
    GROUP BY customer_id
)
SELECT
    ab.customer_id,
    ab.full_name,
    ab.status,
    ab.account_id,
    ab.account_number,
    ab.currency,
    ab.balance,
    ab.balance_kzt,
    ct.total_balance_kzt,
    ab.daily_limit_kzt,
    CASE
        WHEN ab.daily_limit_kzt IS NULL OR ab.daily_limit_kzt = 0 THEN NULL
        ELSE round(ct.total_balance_kzt / ab.daily_limit_kzt * 100, 2)
    END AS daily_limit_utilization_pct,
    rank() OVER(ORDER BY ct.total_balance_kzt DESC) AS balance_rank
FROM account_balances ab
JOIN customer_totals ct ON ct.customer_id = ab.customer_id;



CREATE OR REPLACE VIEW daily_transaction_report AS
WITH daily AS (
    SELECT
        date_trunc('day', created_at)::date AS tx_date,
        type,
        SUM(amount_kzt) AS total_amount_kzt,
        COUNT(*) AS tx_count,
        AVG(amount_kzt) AS avg_amount_kzt
    FROM transactions
    GROUP BY date_trunc('day', created_at)::date, type
),
daily_with_lag AS (
    SELECT
        d.*,
        lag(d.total_amount_kzt) OVER(
            PARTITION BY d.type
            ORDER BY d.tx_date
        ) AS prev_day_amount_kzt
    FROM daily d
)
SELECT
    tx_date,
    type,
    total_amount_kzt,
    tx_count,
    avg_amount_kzt,
    SUM(total_amount_kzt) OVER(ORDER BY tx_date) AS running_total_amount_kzt,
    SUM(tx_count) OVER(ORDER BY tx_date) AS running_total_tx_count,
    prev_day_amount_kzt,
    CASE
        WHEN prev_day_amount_kzt IS NULL OR prev_day_amount_kzt = 0 THEN NULL
        ELSE round(
            (total_amount_kzt - prev_day_amount_kzt) / prev_day_amount_kzt * 100,
            2
        )
    END AS day_over_day_growth_pct
FROM daily_with_lag;



CREATE OR REPLACE VIEW suspicious_activity_view
WITH (security_barrier = true)
AS
WITH latest_rates AS (
    SELECT
        from_currency,
        to_currency,
        rate,
        row_number() OVER(
            PARTITION BY from_currency, to_currency
            ORDER BY valid_from DESC
        ) AS rn
    FROM exchange_rates
    WHERE to_currency = 'KZT'
      AND valid_from <= now()
      AND (valid_to IS NULL OR valid_to > now())
),
tx AS (
    SELECT
        t.transaction_id,
        t.from_account_id,
        t.to_account_id,
        t.amount,
        t.currency,
        t.amount_kzt,
        t.type,
        t.status,
        t.created_at,
        t.description,
        a_from.customer_id AS from_customer_id,
        a_to.customer_id AS to_customer_id,
        c_from.full_name AS from_customer_name,
        c_to.full_name AS to_customer_name,
        COALESCE(
            t.amount_kzt,
            (t.amount * COALESCE(r.rate,1.0))
        )::NUMERIC(18,2) AS normalized_amount_kzt
    FROM transactions t
    LEFT JOIN accounts a_from ON a_from.account_id = t.from_account_id
    LEFT JOIN accounts a_to ON a_to.account_id = t.to_account_id
    LEFT JOIN customers c_from ON c_from.customer_id = a_from.customer_id
    LEFT JOIN customers c_to ON c_to.customer_id = a_to.customer_id
    LEFT JOIN latest_rates r
        ON r.from_currency = t.currency
       AND r.to_currency = 'KZT'
       AND r.rn = 1
),
tx_flags AS (
    SELECT
        tx.*,
        (normalized_amount_kzt > 5000000)::BOOLEAN AS flag_large_amount,
        COUNT(*) OVER(
            PARTITION BY from_customer_id, date_trunc('hour', created_at)
        ) AS tx_per_hour,
        lag(created_at) OVER(
            PARTITION BY from_customer_id
            ORDER BY created_at
        ) AS prev_tx_time
    FROM tx
),
tx_suspicious AS (
    SELECT
        *,
        (tx_per_hour > 10)::BOOLEAN AS flag_many_per_hour,
        (created_at - prev_tx_time < INTERVAL '1 minute')::BOOLEAN AS flag_rapid_sequence
    FROM tx_flags
)
SELECT
    transaction_id,
    from_account_id,
    to_account_id,
    from_customer_id,
    to_customer_id,
    from_customer_name,
    to_customer_name,
    amount,
    currency,
    normalized_amount_kzt AS amount_kzt,
    type,
    status,
    created_at,
    description,
    flag_large_amount,
    flag_many_per_hour,
    flag_rapid_sequence
FROM tx_suspicious
WHERE flag_large_amount
   OR flag_many_per_hour
   OR flag_rapid_sequence;



-- Task 3
CREATE INDEX idx_transactions_from_status_created_at
ON transactions(from_account_id, status, created_at);

CREATE INDEX idx_accounts_account_number_hash
ON accounts USING hash(account_number);

CREATE INDEX idx_accounts_active_only
ON accounts(customer_id, currency)
WHERE is_active;

CREATE INDEX idx_customers_email_ci
ON customers((lower(email)));

CREATE INDEX idx_audit_log_old_values_gin
ON audit_log USING gin(old_values);

CREATE INDEX idx_audit_log_new_values_gin
ON audit_log USING gin(new_values);

CREATE INDEX idx_transactions_report_covering
ON transactions(created_at, type)
INCLUDE(amount_kzt, status);


-- Explain analyze
-- idx_transactions_from_status_created_at
EXPLAIN ANALYZE
SELECT transaction_id, from_account_id, to_account_id, amount, currency, status, created_at
FROM transactions
WHERE from_account_id = 1 AND status IN ('pending','completed') AND created_at >= now() - INTERVAL '30 days';

-- idx_accounts_account_number_hash
EXPLAIN ANALYZE
SELECT account_id, customer_id, account_number, currency, balance, is_active
FROM accounts
WHERE account_number = 'KZ000000000000000001';

-- idx_accounts_active_only
EXPLAIN ANALYZE
SELECT account_id, customer_id, account_number, currency, balance
FROM accounts
WHERE customer_id = 1 AND currency = 'KZT' AND is_active = TRUE;

-- idx_customers_email_ci
EXPLAIN ANALYZE
SELECT customer_id, iin, full_name, email, status
FROM customers
WHERE lower(email) = lower('aibek@kbtu.kz');

-- idx_audit_log_old_values_gin
EXPLAIN ANALYZE
SELECT log_id, table_name, old_values, new_values, changed_at
FROM audit_log
WHERE old_values @> '{"status":"active"}';

-- idx_audit_log_new_values_gin
EXPLAIN ANALYZE
SELECT log_id, table_name, old_values, new_values, changed_at
FROM audit_log
WHERE new_values @> '{"status":"blocked"}';

-- idx_transactions_report_covering
EXPLAIN ANALYZE
SELECT created_at, type, amount_kzt, status
FROM transactions
WHERE created_at >= now() - INTERVAL '30 days';



-- Task 4

CREATE OR REPLACE FUNCTION process_salary_batch(
    p_company_account_number TEXT,
    p_payments JSONB,
    p_changed_by TEXT DEFAULT 'salary_batch',
    p_ip_address TEXT DEFAULT '127.0.0.1'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_company_account accounts%ROWTYPE;
    v_company_customer customers%ROWTYPE;
    v_company_rate_kzt NUMERIC(18,6);
    v_total_batch_kzt NUMERIC(18,2) := 0;
    v_elem JSONB;
    v_iin TEXT;
    v_amount NUMERIC(18,2);
    v_descr TEXT;
    v_employee_customer customers%ROWTYPE;
    v_employee_account accounts%ROWTYPE;
    v_success_count INT := 0;
    v_failed_count INT := 0;
    v_failed_details JSONB := '[]'::JSONB;
    v_result JSONB;
BEGIN
    PERFORM pg_advisory_lock(hashtext(p_company_account_number));

    SELECT *
    INTO v_company_account
    FROM accounts
    WHERE account_number = p_company_account_number
    FOR UPDATE;

    IF NOT FOUND THEN
        PERFORM pg_advisory_unlock(hashtext(p_company_account_number));
        RETURN jsonb_build_object(
            'status','ERROR',
            'code','COMPANY_ACCOUNT_NOT_FOUND',
            'message','Company account not found'
        );
    END IF;

    SELECT *
    INTO v_company_customer
    FROM customers
    WHERE customer_id = v_company_account.customer_id
    FOR UPDATE;

    SELECT rate
    INTO v_company_rate_kzt
    FROM exchange_rates
    WHERE from_currency = v_company_account.currency
      AND to_currency = 'KZT'
      AND valid_from <= now()
      AND (valid_to IS NULL OR valid_to > now())
    ORDER BY valid_from DESC
    LIMIT 1;

    IF v_company_rate_kzt IS NULL THEN
        PERFORM pg_advisory_unlock(hashtext(p_company_account_number));
        RETURN jsonb_build_object(
            'status','ERROR',
            'code','NO_COMPANY_RATE_TO_KZT',
            'message','No FX rate from company currency to KZT'
        );
    END IF;

    FOR v_elem IN SELECT jsonb_array_elements(p_payments)
    LOOP
        v_amount := (v_elem->>'amount')::NUMERIC(18,2);
        IF v_amount IS NULL OR v_amount <= 0 THEN
            v_failed_count := v_failed_count + 1;
            v_failed_details := v_failed_details || jsonb_build_object(
                'iin', v_elem->>'iin',
                'code','INVALID_AMOUNT',
                'message','Salary amount must be positive'
            );
        ELSE
            v_total_batch_kzt := v_total_batch_kzt + round(v_amount * v_company_rate_kzt, 2);
        END IF;
    END LOOP;

    IF v_company_account.balance < (v_total_batch_kzt / v_company_rate_kzt) THEN
        PERFORM pg_advisory_unlock(hashtext(p_company_account_number));
        RETURN jsonb_build_object(
            'status','ERROR',
            'code','INSUFFICIENT_COMPANY_FUNDS',
            'message','Company balance is not sufficient',
            'required_kzt',v_total_batch_kzt
        );
    END IF;

    FOR v_elem IN SELECT jsonb_array_elements(p_payments)
    LOOP
        v_iin := v_elem->>'iin';
        v_amount := (v_elem->>'amount')::NUMERIC(18,2);
        v_descr := COALESCE(v_elem->>'description','Salary payment');

        IF v_amount IS NULL OR v_amount <= 0 THEN
            CONTINUE;
        END IF;

        BEGIN
            SELECT *
            INTO v_employee_customer
            FROM customers
            WHERE iin = v_iin;

            IF NOT FOUND THEN
                v_failed_count := v_failed_count + 1;
                v_failed_details := v_failed_details || jsonb_build_object(
                    'iin',v_iin,
                    'code','CUSTOMER_NOT_FOUND',
                    'message','Employee not found'
                );
                CONTINUE;
            END IF;

            SELECT *
            INTO v_employee_account
            FROM accounts
            WHERE customer_id = v_employee_customer.customer_id
              AND is_active = TRUE
            ORDER BY (currency <> v_company_account.currency), account_id
            LIMIT 1;

            IF NOT FOUND THEN
                v_failed_count := v_failed_count + 1;
                v_failed_details := v_failed_details || jsonb_build_object(
                    'iin',v_iin,
                    'code','ACCOUNT_NOT_FOUND',
                    'message','Active account not found'
                );
                CONTINUE;
            END IF;

            v_result := process_transfer(
                v_company_account.account_number,
                v_employee_account.account_number,
                v_amount,
                v_company_account.currency,
                v_descr,
                p_changed_by,
                p_ip_address,
                TRUE
            );

            IF v_result->>'status' = 'OK' THEN
                v_success_count := v_success_count + 1;
            ELSE
                v_failed_count := v_failed_count + 1;
                v_failed_details := v_failed_details || jsonb_build_object(
                    'iin',v_iin,
                    'code',v_result->>'code',
                    'message',v_result->>'message'
                );
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                v_failed_count := v_failed_count + 1;
                v_failed_details := v_failed_details || jsonb_build_object(
                    'iin',v_iin,
                    'code','UNKNOWN_ERROR',
                    'message',SQLERRM
                );
        END;
    END LOOP;

    PERFORM pg_advisory_unlock(hashtext(p_company_account_number));

    RETURN jsonb_build_object(
        'status','OK',
        'code','BATCH_PROCESSED',
        'successful_count',v_success_count,
        'failed_count',v_failed_count,
        'failed_details',v_failed_details
    );
END;
$$;


-- Documentation
-- - customers: customers, status, and daily limit
-- - accounts: accounts in different currencies
-- - transactions: transaction history + KZT amount for reports
-- - exchange_rates: exchange rates with validity period
-- - audit_log: all important changes/failures in JSONB
--
-- 2) process_transfer:
-- - One function covers all transfer business logic:
-- validation, limits, conversion, balance updates, logging to audit_log. Returns JSONB
--
-- 3) View:
-- - customer_balance_summary: calculates customer balance, ranks by amount, shows limit usage.
-- - daily_transaction_report: aggregation by days and transaction types + growth relative to the previous day.
-- - suspicious_activity_view: flags large amounts
--
-- 4) Indexes:
-- - reporting, search by account number, search for active accounts, search by email and JSONB logs.
-- - index by transactions, so reports read a minimum of data from disk.
--
-- 5) process_salary_batch:
-- - Mass payments from a single corporate account, uses process_transfer internally.
-- - Calculates the total batch amount, validates funds, collects errors in JSONB.
-- - Advisory lock by account number protects against race conditions in parallel batches.
