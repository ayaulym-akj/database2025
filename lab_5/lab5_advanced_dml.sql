--Task 1.1
create table employees(
employee_id int,
first_name text,
last_name text,
age int check (age between 18 and 65),
salary numeric check (salary>0)
);
--1.2
CREATE TABLE  products_catalog (
product_id int,
product_name text,
regular_price numeric,
discount_price numeric,
CONSTRAINT valid_discount CHECK (regular_price >0 and discount_price >0 and discount_price < regular_price)
);
--1.3
CREATE TABLE bookings(
booking_id int,
check_in_date date,
check_out_date date,
num_guests int,
CHECK (num_guests between 1 and 10),
CHECK (check_out_date > check_in_date)
);
--1.4
INSERT INTO employees VALUES
(1, 'abc', 'def', 23, 500),
(2, 'sda', 'fgd', 55, 222);

INSERT INTO products_catalog VALUES
(1, 'aghd', 230.2, 12),
(2, 'ksbq', 124, 10);

INSERT INTO bookings VALUES
(1, '2022-01-12', '2025-01-12', 4),
(2, '2022-11-19', '2022-12-23', 5);
--invalid data
INSERT INTO employees VALUES
(1, 'abc', 'def', 67, -500), --age, salary
(2, 'sda', 'fgd', 5, -2);

INSERT INTO products_catalog VALUES
(1, 'aghd', -230.2, -2), -- regular and discount price
(2, 'ksbq', -124, 0);

INSERT INTO bookings VALUES
(1, '2022-01-12', '2020-01-12', 14), --date, num of guests
(2, '2022-11-19', '2012-12-23', 235);

--Task 2.1
CREATE TABLE customers(
customer_id integer NOT NULL,
email text NOT NULL,
phone text,
registration_date date NOT NULL
);
--2.2
CREATE TABLE inventory(
item_id integer NOT NULL,
item_name text NOT NULL,
quantity integer NOT NULL CHECK(quantity>=0),
unit_price numeric NOT NULL CHECK(unit_price>0),
last_updated timestamp NOT NULL
);
--2.3
INSERT INTO customers VALUES
(1, 'vhjb@mail.ru', null, '2020-01-01');
INSERT INTO customers VALUES
(1, null, null, '2020-01-01'); --insert null value to not null

INSERT INTO inventory VALUES
(1, 'jhds', 200, 120, '2025-10-12 23:15:45');
INSERT INTO inventory VALUES
(1, 'jhds', null, 120, '2025-10-12 23:15:45');  --insert null value to not null

--Task 3.1
CREATE TABLE users(
user_id integer,
username text unique,
email text unique,
created_at timestamp
);
--3.2
CREATE TABLE course_enrollments (
enrollment_id integer,
student_id integer,
course_code text,
semester text
CONSTRAINT unique_enrollment UNIQUE (student_id, course_code, semester)
);
--3.3
CREATE TABLE users(
user_id integer,
username text,
email text,
created_at timestamp,
CONSTRAINT unique_username UNIQUE (username),
CONSTRAINT unique_email UNIQUE (email)
);
--invalid insertion
INSERT INTO users VALUES
(1, 'add', 'jhb@mail.ru', '2025-10-12 23:15:45'),
(2, 'add', 'jhb@mail.ru', '2023-10-12 23:15:45');

--Task 4.1
CREATE TABLE departments(
dept_id integer PRIMARY KEY,
dept_name text NOT NULL,
location text
);
INSERT INTO departments VALUES
(1, 'IT', 'hckn'),
(2, 'Sales', 'bkjm'),
(3, 'HR', 'kb');
--invalid
INSERT INTO departments VALUES
(1, 'IT', 'hckn'),
(1, 'Sales', 'bkjm'),
(null, 'HR', 'kb');
--4.2
CREATE TABLE student_courses(
student_id integer,
course_id integer,
enrollment_date date,
grade text,
PRIMARY KEY(student_id, course_id)
);
--4.3
--1. PRIMARY KEY= unique + no NULLs. UNIQUE= unique but allows one NULL.
--2. Single-column PRIMARY KEY use when one column can uniquely identify each row.
--Composite PRIMARY KEY use when uniqueness comes from a combination of columns.
--3. A table can have only one PRIMARY KEY because it defines the main unique identifier for that table. 
--However, a table can have multiple UNIQUE constraints to enforce uniqueness on other important columns

--Task 5.1
CREATE TABLE employees_dept(
emp_id integer PRIMARY KEY,
emp_name text NOT NULL,
dept_id integer REFERENCES departments,
hire_date date
);
INSERT INTO employees_dept VALUES
(1, 'hvhg', 1, '2020-02-02'); -- valid
INSERT INTO employees_dept VALUES
(1, 'hvhg', 4, '2020-02-02'); --(dept_id)=(4) is not present in table "departments"
--drop table if exists employees_dept; 
--5.2
CREATE TABLE authors(
author_id integer PRIMARY KEY,
author_name text NOT NULL,
country text
);
CREATE TABLE publishers(
publisher_id integer PRIMARY KEY,
publisher_name text NOT NULL,
city text
);
CREATE TABLE books(
book_id integer PRIMARY KEY,
title text NOT NULL,
author_id integer REFERENCES authors,
publisher_id integer REFERENCES publishers,
publication_year integer,
isbn text UNIQUE
);
INSERT INTO authors VALUES
(1, 'abc', 'kz'),
(2, 'ans', 'ru');
INSERT INTO publishers VALUES
(1, 'ab', 'ala'),
(2, 'ak', 'ast');
INSERT INTO books VALUES
(1, 'asa', 1, 1, 2013, '09808'),
(2, 'aya', 2, 2, 2009,  '23098');
--5.3
CREATE TABLE categories(
category_id integer PRIMARY KEY,
category_name text NOT NULL
);
CREATE TABLE products_fk(
product_id integer PRIMARY KEY,
product_name text NOT NULL,
category_id integer REFERENCES categories ON DELETE RESTRICT
);
CREATE TABLE  orders(
order_id integer PRIMARY KEY,
order_date date NOT NULL
);
CREATE TABLE order_items(
item_id integer PRIMARY KEY,
order_id integer REFERENCES orders ON DELETE CASCADE,
product_id integer REFERENCES products_fk,
quantity integer CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics'), (2, 'Clothing');
INSERT INTO products VALUES
(101, 'Smartphone', 1),
(102, 'T-Shirt', 2);

INSERT INTO orders VALUES (500, '2025-10-14');
INSERT INTO order_items VALUES
(1, 500, 101),
(2, 500, 102);

DELETE FROM categories WHERE category_id = 1; --1 try to delete a category
DELETE FROM orders WHERE order_id = 500; --2
--3 in first case it does not deleted, because it creates with ON DELETE RESTRICT. in second it was deleted.

--Task 6
drop table if exists orders  CASCADE;
CREATE TABLE customers(
customer_id int primary key,
name text NOT NULL,
email text unique NOT NULL, 
phone int, 
registration_date date NOT NULL
);
CREATE TABLE products(
product_id int primary key, 
name text NOT NULL, 
description text, 
price int CHECK(price>=0), 
stock_quantity int CHECK(stock_quantity>=0)
);
CREATE TABLE orders(
order_id int primary key, 
customer_id int REFERENCES customers ON DELETE CASCADE, 
order_date date NOT NULL, 
total_amount int, 
status text CHECK(status in ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);
CREATE TABLE order_details(
order_detail_id int primary key, 
order_id int REFERENCES orders ON DELETE CASCADE, 
product_id int REFERENCES products ON DELETE RESTRICT, 
quantity int CHECK (quantity>0), 
unit_price int
);

INSERT INTO customers VALUES
(1, 'ads', 'xs@mail.ru', '0762', '2020-03-02'),
(2, 'alk', 'als@mail.ru', '0702', '2020-01-02'),
(3, 'jkl', 'jkl@mail.ru', '2342', '2021-03-05'),
(4, 'ghs', 'ghs@mail.ru', '0232', '2019-03-02'),
(5, 'pos', 'pos@mail.ru', '1232', '2024-11-02');
INSERT INTO products VALUES
(1, 'jbj', 'hbs', 1234, 98),
(2, 'lbj', 'hmk', 9864, 100),
(3, 'dfg', 'jkl', 9076, 23),
(4, 'afs', 'kcv', 2189, 22),
(5, 'kjh', 'las', 5642, 42);
INSERT INTO orders VALUES
(1, 1, '2025-01-01', 123, 'processing'),
(2, 1, '2025-05-01', 56, 'cancelled'),
(3, 2, '2025-10-01', 98, 'delivered'),
(4, 5, '2025-09-01', 72, 'shipped'),
(5, 3, '2025-09-01', 23, 'pending');
INSERT INTO order_details VALUES
(1, 1, 1, 123, 345),
(2, 2, 2, 234, 87),
(3, 3, 3, 870, 20),
(4, 4, 4, 200, 30),
(5, 5, 5, 100, 15);
select * from order_details;
--Test queries
INSERT INTO customers VALUES
(6, 'ads', 'xs@mail.ru', '0762', '2020-03-02'), --unique email
(7, 'alk', 'xs@mail.ru', '0702', '2020-01-02');

INSERT INTO products VALUES
(6, null, 'hbs', 1234, -78), --null name, negative nums
(7, 'lbj', 'hmk', -2, 100);

INSERT INTO orders VALUES
(1, 1, '2025-01-01', 123, 'bnd'); --orders_status_check

DELETE FROM orders WHERE order_id = 1; --cascade
DELETE FROM products WHERE product_id = 1; --restrict dont delete