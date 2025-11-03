--Part 1
CREATE TABLE employees (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(50),
dept_id INT,
salary DECIMAL(10, 2)
);
CREATE TABLE departments (
dept_id INT PRIMARY KEY,
dept_name VARCHAR(50),
location VARCHAR(50)
);
CREATE TABLE projects (
project_id INT PRIMARY KEY,
project_name VARCHAR(50),
dept_id INT,
budget DECIMAL(10, 2)
);

INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

--Part 2
SELECT e.emp_name, d.dept_name FROM employees e CROSS JOIN departments d; --5*4=20 rows
SELECT e.emp_name, d.dept_name FROM employees e, departments d;
SELECT e.emp_name, d.dept_name FROM employees e INNER JOIN departments d ON TRUE;
SELECT e.emp_name, p.project_name FROM employees e CROSS JOIN projects p;

--Part 3
SELECT e.emp_name, d.dept_name, d.location FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id; 
--4 rows are returned. Tom Brown’s dept_id is NULL, so there’s no match in the departments table.
SELECT emp_name, dept_name, location FROM employees INNER JOIN departments USING (dept_id);
SELECT emp_name, dept_name, location FROM employees NATURAL INNER JOIN departments;

SELECT e.emp_name, d.dept_name, p.project_name 
FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id INNER JOIN projects p ON d.dept_id = p.dept_id;
--Part 4
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id; 
--LEFT JOIN keeps all rows from the left table (employees), even if there’s no matching row in the right table (departments).
SELECT emp_name, dept_id, dept_name FROM employees LEFT JOIN departments USING (dept_id);
SELECT e.emp_name, e.dept_id FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id WHERE d.dept_id IS NULL;
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id GROUP BY d.dept_id, d.dept_name ORDER BY employee_count DESC;

--Part 5
SELECT e.emp_name, d.dept_name FROM employees e RIGHT JOIN departments d ON e.dept_id = d.dept_id;
SELECT e.emp_name, d.dept_name FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id;
SELECT d.dept_name, d.location FROM employees e RIGHT JOIN departments d ON e.dept_id = d.dept_id WHERE e.emp_id IS NULL;

--Part 6
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name FROM employees e FULL JOIN departments d ON e.dept_id = d.dept_id;
--Tom Brown right side = NULL. Marketing left side = NULL.
SELECT d.dept_name, p.project_name, p.budget FROM departments d FULL JOIN projects p ON d.dept_id = p.dept_id;

SELECT CASE WHEN e.emp_id IS NULL THEN 'Department without employees' WHEN d.dept_id IS NULL THEN 'Employee without department' ELSE 'Matched'
END AS record_status, e.emp_name, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

--Part 7
SELECT e.emp_name, d.dept_name, e.salary FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';
SELECT e.emp_name, d.dept_name, e.salary FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id WHERE d.location = 'Building A';

--Part 8
SELECT d.dept_name, e.emp_name, e.salary, p.project_name, p.budget FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id LEFT JOIN projects p ON d.dept_id = p.dept_id ORDER BY d.dept_name, e.emp_name;

ALTER TABLE employees ADD COLUMN manager_id INT;
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;
SELECT e.emp_name AS employee, m.emp_name AS manager FROM employees e LEFT JOIN employees m ON e.manager_id = m.emp_id;

SELECT d.dept_name, AVG(e.salary) AS avg_salary FROM departments d INNER JOIN employees e ON d.dept_id = e.dept_id GROUP BY d.dept_id, d.dept_name HAVING AVG(e.salary) > 50000;

--Lab Questions

--1. INNER JOIN returns only matching rows in both tables. LEFT JOIN returns all rows from the left table + matches from the right (NULL if no match).

--2. CROSS JOIN use when you need all combinations of two tables.

--3. For INNER JOIN, it doesn’t matter (results are the same). 
--For OUTER JOIN, putting the filter in ON keeps unmatched rows; in WHERE, it can remove them (turning it into an inner-like result).

--4. COUNT result of CROSS JOIN 5 × 10 = 50 rows.

--5. NATURAL JOIN automatically joins tables using columns with the same name in both tables.

--6. Risks of NATURAL JOIN. Unintended joins if column names match by coincidence.
--Query can break if schema changes (column added/renamed).

--7. Convert LEFT JOIN to RIGHT JOIN. SELECT * FROM B RIGHT JOIN A ON A.id = B.id;

--8. FULL OUTER JOIN we use when we need all rows from both tables, keeping unmatched ones on both sides (showing NULLs where no match).
