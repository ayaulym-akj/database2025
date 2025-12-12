--Bonus Laboratory Work
CREATE TABLE customers(
    customer_id serial primary key,
    iin varchar(12) unique ,
    full_name varchar(100),
    phone int,
    email varchar(100),
    status varchar(50) check(status in ('active', 'blocked', 'frozen')) ,
    created_at timestamp default now(),
    daily_limit_kzt numeric
);
CREATE TABLE accounts (
    account_id serial primary key,
    customer_id int references customers(customer_id),
    account_number varchar(34) unique,
    currency varchar(10) check (currency in('KZT', 'USD', 'EUR', 'RUB')),
    balance numeric default 0,
    is_active boolean default true,
    opened_at timestamp default now(),
    closed_at timestamp
);
CREATE TABLE transactions(
    transaction_id serial primary key,
    from_account_id int references accounts(account_id),
    to_account_id int references accounts(account_id),
    amount numeric,
    currency varchar(10),
    exchange_rate numeric,
    amount_kzt numeric,
    type varchar(20) check(type in ('transfer', 'deposit', 'withdrawal')),
    status varchar(30) check(status in ('pending', 'completed', 'failed', 'reversed')),
    created_at timestamp default now(),
    completed_at timestamp,
    description varchar(100)
);
CREATE TABLE exchange_rates(
    rate_id serial primary key,
    from_currency varchar(10),
    to_currency varchar(10),
    rate numeric,
    valid_from timestamp,
    valid_to timestamp
);
CREATE TABLE audit_log(
    log_id serial primary key,
    table_name text,
    record_id int,
    action varchar(15) check (action in('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by text,
    changed_at timestamp default now(),
    ip_address text
);
INSERT INTO customers (iin, full_name, phone, email, status, daily_limit_kzt) VALUES
(071102200300, 'customer1', 12345, 'customer1@gmail.com', 'active', 200000),
(071202200400, 'customer2', 12312, 'customer2@gmail.com', 'active', 400000),
(070102200300, 'customer3', 19845, 'customer3@gmail.com', 'blocked', 300000),
(021202200400, 'customer4', 18732, 'customer4@gmail.com', 'frozen', 4200000),
(001202200400, 'customer5', 16732, 'customer5@gmail.com', 'active', 430000),
(071202200470, 'customer6', 12318, 'customer6@gmail.com', 'blocked', 270000),
(051202200400, 'customer7', 10312, 'customer7@gmail.com', 'frozen', 500000),
(031202200400, 'customer8', 12912, 'customer8@gmail.com', 'active', 900000),
(011202200400, 'customer9', 12314, 'customer9@gmail.com', 'frozen', 100000),
(991202200400, 'customer10', 15312, 'customer10@gmail.com', 'active', 600000);

INSERT INTO accounts(customer_id, account_number, currency, balance) VALUES
(1, 'account1', 'KZT', 100000),
(2, 'account2', 'USD', 1200),
(3, 'account3', 'EUR', 800),
(4, 'account4', 'KZT', 120000),
(5, 'account5', 'RUB', 100000),
(6, 'account6', 'KZT', 600000),
(7, 'account7', 'USD', 200),
(8, 'account8', 'KZT', 30000),
(9, 'account9', 'EUR', 1000),
(10, 'account10', 'KZT', 1000000);

INSERT INTO exchange_rates(from_currency,to_currency,rate,valid_from,valid_to) VALUES
('KZT', 'USD', 20000, now(), now() + interval '25 days'),
('USD', 'KZT', 100, now(), now() + interval '25 days'),
('RUB', 'USD', 2000, now(), now() + interval '25 days'),
('KZT', 'RUB', 10000, now(), now() + interval '25 days'),
('EUR', 'USD', 200, now(), now() + interval '25 days'),
('EUR', 'KZT', 230, now(), now() + interval '25 days'),
('RUB', 'EUR', 15000, now(), now() + interval '25 days'),
('RUB', 'KZT', 2500, now(), now() + interval '25 days'),
('KZT', 'EUR', 10000, now(), now() + interval '25 days'),
('USD', 'RUB', 200, now(), now() + interval '25 days');



--task 1
CREATE OR REPLACE PROCEDURE process_transfer(
    p_from_acc TEXT,
    p_to_acc TEXT,
    p_amount NUMERIC,
    p_currency TEXT,
    p_description TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_from_id INT;
    v_to_id INT;
    v_from_balance NUMERIC;
    v_status TEXT;
    v_limit NUMERIC;
    v_sum_today NUMERIC;
    v_rate NUMERIC;
    v_amount_kzt NUMERIC;
BEGIN
    SELECT account_id, balance INTO v_from_id, v_from_balance FROM accounts WHERE account_number = p_from_acc AND is_active = true FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sender account not found' USING ERRCODE='P0001';
    END IF;

    SELECT account_id INTO v_to_id
    FROM accounts WHERE account_number = p_to_acc AND is_active = true
        FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Receiver account not found' USING ERRCODE='P0002';
    END IF;

    SELECT status, daily_limit_kzt INTO v_status, v_limit
    FROM customers c
             JOIN accounts a ON a.customer_id=c.customer_id
    WHERE a.account_id=v_from_id;
    IF v_status <> 'active' THEN
        RAISE EXCEPTION 'Customer is not active' USING ERRCODE='P0003';
    END IF;

    SELECT COALESCE(SUM(amount_kzt),0)
    INTO v_sum_today
    FROM transactions
    WHERE from_account_id=v_from_id
      AND created_at::date = CURRENT_DATE
      AND status='completed';

    SELECT rate INTO v_rate
    FROM exchange_rates
    WHERE from_currency=p_currency AND to_currency='KZT'
      AND NOW() BETWEEN valid_from AND valid_to;

    v_amount_kzt := p_amount * v_rate;

    IF v_sum_today + v_amount_kzt > v_limit THEN
        RAISE EXCEPTION 'Daily limit exceeded' USING ERRCODE='P0004';
    END IF;
    IF v_from_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient funds' USING ERRCODE='P0005';
    END IF;

    UPDATE accounts SET balance = balance - p_amount WHERE account_id = v_from_id;
    UPDATE accounts SET balance = balance + p_amount WHERE account_id = v_to_id;

    INSERT INTO transactions(from_account_id, to_account_id, amount, currency,exchange_rate, amount_kzt, type, status, description, completed_at) VALUES
    (v_from_id, v_to_id, p_amount, p_currency,v_rate, v_amount_kzt, 'transfer', 'completed', p_description, NOW());
END;
$$;


--task 2
--view 1
CREATE VIEW customer_balance_summary AS
SELECT
    c.customer_id,
    c.full_name,
    a.account_number,
    a.currency,
    a.balance,
    CASE
        WHEN a.currency = 'KZT' THEN a.balance
        WHEN a.currency = 'USD' THEN a.balance * 450
        WHEN a.currency = 'EUR' THEN a.balance * 490
        WHEN a.currency = 'RUB' THEN a.balance * 5
        END as balance_kzt,
    RANK() OVER (ORDER BY SUM(
            CASE
                WHEN a.currency = 'KZT' THEN a.balance
                WHEN a.currency = 'USD' THEN a.balance * 450
                WHEN a.currency = 'EUR' THEN a.balance * 490
                WHEN a.currency = 'RUB' THEN a.balance * 5
                END)
        DESC) as customer_rank
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
WHERE a.is_active = true
GROUP BY c.customer_id, a.account_id;

--view 2
CREATE VIEW daily_transaction_report AS
SELECT
    DATE(created_at) as transaction_date,
    type,
    COUNT(*) as transaction_count,
    SUM(amount_kzt) as total_amount,
    AVG(amount_kzt) as avg_amount,
    SUM(SUM(amount_kzt)) OVER (ORDER BY DATE(created_at)) as running_total
FROM transactions
WHERE status = 'completed'
GROUP BY DATE(created_at), type;

--view 3
CREATE VIEW suspicious_activity_view WITH (security_barrier = true) AS
SELECT
    t.transaction_id,
    t.amount_kzt,
    t.created_at,
    c.full_name
FROM transactions t
         JOIN accounts a ON t.from_account_id = a.account_id
         JOIN customers c ON a.customer_id = c.customer_id
WHERE t.amount_kzt > 5000000 OR EXISTS (
    SELECT 1 FROM transactions t2
    WHERE t2.from_account_id = t.from_account_id AND DATE_TRUNC('hour', t2.created_at) = DATE_TRUNC('hour', t.created_at)
    GROUP BY DATE_TRUNC('hour', t2.created_at)
    HAVING COUNT(*) > 10
);


--task 3
-- 1 B-tree
CREATE INDEX idx_accounts ON accounts(customer_id);

EXPLAIN ANALYZE
SELECT * FROM accounts WHERE customer_id = 1;
--2 Hash
CREATE INDEX idx_hash_accounts ON accounts USING HASH(account_number);

EXPLAIN ANALYZE
SELECT * FROM accounts WHERE account_number = 'account1';
--3 GIN
CREATE INDEX idx_gin_audit ON audit_log USING GIN(new_values);

EXPLAIN ANALYZE
SELECT * FROM audit_log WHERE new_values @> '{"status": "completed"}';
--4 BRIN
CREATE INDEX idx_brin_transactions ON transactions USING BRIN(created_at);

EXPLAIN ANALYZE
SELECT COUNT(*) FROM transactions WHERE created_at > CURRENT_DATE - INTERVAL '7 days';
--5 Composite
CREATE INDEX idx_transactions_date_status ON transactions(created_at, status);

EXPLAIN ANALYZE
SELECT * FROM transactions WHERE created_at >= '2024-01-01' AND status = 'completed'
ORDER BY created_at DESC
LIMIT 10;

--task 4
CREATE OR REPLACE PROCEDURE process_salary_batch(
    company_acc VARCHAR(34),
    payments JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    company_acc_id INT;
    company_balance DECIMAL;
    total_amount DECIMAL := 0;
    success_count INT := 0;
    fail_count INT := 0;
    fail_details JSONB := '[]';
    payment_record JSONB;
    emp_iin VARCHAR;
    emp_amount DECIMAL;
    emp_desc TEXT;
    emp_acc_id INT;
BEGIN
    PERFORM pg_advisory_lock(hashtext(company_acc));
    SELECT account_id, balance INTO company_acc_id, company_balance
    FROM accounts WHERE account_number = company_acc
        FOR UPDATE;

    FOR payment_record IN SELECT * FROM jsonb_array_elements(payments)
        LOOP
            total_amount := total_amount + (payment_record->>'amount')::DECIMAL;
        END LOOP;

    IF company_balance < total_amount THEN
        RAISE EXCEPTION 'The company does not have enough funds';
    END IF;

    FOR payment_record IN SELECT * FROM jsonb_array_elements(payments)
        LOOP
            BEGIN
                emp_iin := payment_record->>'iin';
                emp_amount := (payment_record->>'amount')::DECIMAL;
                emp_desc := payment_record->>'description';

                SELECT a.account_id INTO emp_acc_id
                FROM accounts a
                         JOIN customers c ON a.customer_id = c.customer_id
                WHERE c.iin = emp_iin AND a.is_active = true;

                IF emp_acc_id IS NULL THEN
                    RAISE EXCEPTION 'Employee account not found';
                END IF;


                UPDATE accounts SET balance = balance - emp_amount
                WHERE account_id = company_acc_id;

                UPDATE accounts SET balance = balance + emp_amount
                WHERE account_id = emp_acc_id;


                INSERT INTO transactions (
                    from_account_id, to_account_id, amount, currency,
                    amount_kzt, type, status, completed_at, description
                ) VALUES (
                             company_acc_id, emp_acc_id, emp_amount, 'KZT',
                             emp_amount, 'transfer', 'completed',
                             CURRENT_TIMESTAMP, emp_desc
                         );

                success_count := success_count + 1;

            EXCEPTION
                WHEN OTHERS THEN
                    fail_count := fail_count + 1;
                    fail_details := fail_details || jsonb_build_object(
                            'iin', emp_iin,
                            'error', SQLERRM
                                                    );
                    CONTINUE;
            END;
        END LOOP;

    PERFORM pg_advisory_unlock(hashtext(company_acc));


    RAISE NOTICE 'Success: %, Errors: %', success_count, fail_count;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM pg_advisory_unlock(hashtext(company_acc));
        RAISE;
END;
$$;



