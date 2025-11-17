--Part 2
--2.1
CREATE INDEX emp_salary_idx ON employees(salary);
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';
--2  indexes. one for PRIMARY KEY (emp_id) and the newly created emp_salary_idx
--2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);
SELECT * FROM employees WHERE dept_id = 101;
--It makes JOIN operations faster. It also helps the database quickly check the relationship when you add or update data.
--2.3
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
--departments_pkey, employees_pkey, projects_pkey  were created automatically

--Part 3
--3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
--No, it would not be very useful. The index is on dept_id, salary. If you only search by salary, the database cannot use the index efficiently because dept_id is the first column.
--3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
--Yes, the order is very important. The index works best when your query uses the leftmost columns first.

--Part 4
--4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;
UPDATE employees SET email = 'alice.johnson@company.com' WHERE emp_id = 6;
UPDATE employees SET email = 'charlie.brown@company.com' WHERE emp_id = 8;
select * from employees;

CREATE INDEX emp_email_unq_iDx ON employees(email);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (7, 'New Employee', 101, 55000, 'john.smith@company.com'); -- email must be unique.

--4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%'; --yes, PostgreSQL automatically create a unique B-tree index for the UNIQUE constraint.

--Part 5
--5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC; --The index keeps the data pre-sorted. The database can just read it in order without sorting.
--5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);
SELECT project_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

--Part 6
--6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));
SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith'; --Without the index, the database must check every single row in the table.
--6.2
CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));
SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

--Part 7
--7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';
--7.2
DROP INDEX emp_dept_salary_idx; --Indexes slow down data changes because the database must update them too.
--7.3
REINDEX INDEX employees_salary_index;

--Part 8
--8.1
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;
--8.2
CREATE INDEX proj_high_budget_idx ON projects(budget) WHERE budget > 80000;
SELECT project_name, budget
FROM projects
WHERE budget > 80000; --A partial index is smaller, faster to maintain, and faster to scan.
--8.3
EXPLAIN SELECT * FROM employees WHERE salary > 52000; --it shows Seq Scan, database ignored the index and read the entire table, which is slow.

--Part 9
--9.1
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);
SELECT * FROM departments WHERE dept_name = 'IT'; --Use a HASH index only for simple equality comparisons.
--9.2
CREATE INDEX proj_name_btree_idx ON projects(project_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (project_name);
SELECT * FROM projects WHERE project_name = 'Website Redesign';
SELECT * FROM projects WHERE project_name > 'Database';

--Part 10
--10.1
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;--The index on a column with many unique values or a multicolumn index will usually be the largest. IN my case it is departments_pkey.
--10.2
DROP INDEX IF EXISTS proj_name_hash_idx;
--10.3
CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%salary%';
SELECT * FROM index_documentation;


--Summary questions
--1. B-tree is the default index type in PostgreSQL.
--2. Create indexes when: searching often, joining tables, or needing sorted results.
--3. Don't create indexes on: small tables or columns that change too frequently.
--4. Indexes get updated too when you insert, update, or delete data, which slows down these operations.
--5. Use EXPLAIN ANALYZE before your query to see if it's using an index.
