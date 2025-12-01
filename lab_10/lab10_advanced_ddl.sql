CREATE TABLE accounts (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          shop VARCHAR(100) NOT NULL,
                          product VARCHAR(100) NOT NULL,
                          price DECIMAL(10, 2) NOT NULL
);
INSERT INTO accounts (name, balance) VALUES
                                         ('Alice', 1000.00),
                                         ('Bob', 500.00),
                                         ('Wally', 750.00);
INSERT INTO products (shop, product, price) VALUES
                                                ('Joe''s Shop', 'Coke', 2.50),
                                                ('Joe''s Shop', 'Pepsi', 3.00);

--task 1
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';
COMMIT;
select * from accounts;
--a) Alice's balance=900; Bob's balance=600.
--b) Because both operations represent one logical action.
--c) Alice’s money might be deducted, but Bob never receives it

--task 2
BEGIN;
UPDATE accounts SET balance = balance - 500.00
WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';
--a) Alice's balance = 400
--b) After rollback Alice's balance=900
--c) Use rollback when you detect an error

--task 3
BEGIN;
UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Wally';
COMMIT;
--a) Alice's balance = 800. Bob's balance = 600. Wally's balance = 850.
--b) Bob credit was reversed by rollback. No change was made in the end.
--c) Allows partial rollback inside a transaction without aborting whole transaction.

--task 4
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;
--a) before coke, pepsi. after only fanta.

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;
--b) see old values coke and pepsi
--c) READ COMMITTED lets you see changes others made, SERIALIZABLE makes it seem like you're working alone.

--task 5
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
SELECT MAX(price), MIN(price) FROM products
WHERE shop = 'Joe''s Shop';
COMMIT;
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;
--a) No, Terminal 1 does not see the new product.
--b) Phantom read is when you see new rows that weren't there before.
--c) SERIALIZABLE.

--task 6
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;
BEGIN;
UPDATE products SET price = 99.99
WHERE product = 'Fanta';
ROLLBACK;
--a) No, Terminal 1 did not see the price 99.99 because PostgreSQL does not allow dirty reads, even with READ UNCOMMITTED.
--b) A dirty read is when a transaction reads uncommitted data from another transaction.
--c) READ UNCOMMITTED should be avoided because it can lead to reading incorrect, temporary data.


--Independent Exercises
--ex 1
DO $$
    BEGIN
        IF (SELECT balance FROM accounts WHERE name = 'Bob') >= 200 THEN
            UPDATE accounts SET balance = balance - 200 WHERE name = 'Bob';
            UPDATE accounts SET balance = balance + 200 WHERE name = 'Wally';
        ELSE
            RAISE NOTICE 'Insufficient funds';
        END IF;
END $$;

--ex 2
BEGIN;
INSERT INTO products(shop, product, price) VALUES ('ASD FGH', 'RTY', 23);
SAVEPOINT spi;
UPDATE products SET price = 45 WHERE product='RTY';
SAVEPOINT spu;
DELETE FROM products WHERE product='RTY';
SAVEPOINT spd;
ROLLBACK TO spi;
COMMIT;
select * from products;

--ex 3
--terminal 1
BEGIN TRANSACTION isolation level SERIALIZABLE;
SELECT balance FROM accounts WHERE name = 'Alice';
UPDATE accounts SET balance = balance - 150 WHERE name = 'Alice';
COMMIT;
--terminal2
BEGIN TRANSACTION isolation level SERIALIZABLE;
SELECT balance FROM accounts WHERE name = 'Alice';
UPDATE accounts SET balance = balance - 150 WHERE name = 'Alice';
COMMIT;
--READ UNCOMMITTED allows dirty reads (seeing uncommitted changes)
--READ COMMITTED shows only committed data (this one also can be good solution)
--REPEATABLE READ maintains snapshot consistency but allows phantoms
--SERIALIZABLE provides full isolation preventing all concurrency issues.

--ex 4
SELECT MAX(price), MIN(price) FROM products WHERE shop = 'Joe''s Shop';

BEGIN;
SELECT MAX(price), MIN(price) FROM products WHERE shop = 'Joe''s Shop';
COMMIT;


