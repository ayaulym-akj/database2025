--СREATE
CREATE TABLE employees (
employee_id SERIAL PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
department VARCHAR(50),
salary NUMERIC(10,2),
hire_date DATE,
manager_id INTEGER,
email VARCHAR(100)
);

CREATE TABLE projects (
project_id SERIAL PRIMARY KEY,
project_name VARCHAR(100),
budget NUMERIC(12,2),
start_date DATE,
end_date DATE,
status VARCHAR(20)
);

CREATE TABLE assignments (
assignment_id SERIAL PRIMARY KEY,
employee_id INTEGER REFERENCES employees(employee_id),
project_id INTEGER REFERENCES projects(project_id),
hours_worked NUMERIC(5,1),
assignment_date DATE
);

--INSERT
INSERT INTO employees (first_name, last_name, department, salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL, 'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1, 'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL, 'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL, 'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3, 'lisa.a@company.com');

INSERT INTO projects (project_name, budget, start_date, end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30', 'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31', 'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31', 'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');

INSERT INTO assignments (employee_id, project_id, hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');

--Part 1
--1.1
SELECT CONCAT(first_name, ' ', last_name) AS full_name, department, salary FROM employees;
--1.2
SELECT DISTINCT department FROM employees;
--1.3
SELECT project_name, budget, CASE
	WHEN budget > 150000 THEN 'Large'
	WHEN budget between 100000 and 150000 THEN 'Medium'
	ELSE 'Small'
END AS budget_category FROM projects;
--1.4
SELECT first_name, COALESCE (email, 'No email provided') FROM employees;

--Part 2
--2.1
SELECT first_name, last_name, hire_date FROM employees WHERE hire_date > '2020-01-01';
--2.2
SELECT first_name, last_name, salary FROM employees WHERE salary between 60000 and 70000;
--2.3
SELECT first_name, last_name FROM employees WHERE last_name LIKE 'S%' or last_name LIKE 'J%';
--2.4
SELECT first_name, last_name, department, manager_id FROM employees WHERE department= 'IT' and manager_id IS NOT NULL;

--Part 3

--3.1
SELECT UPPER(first_name), LENGTH(last_name), SUBSTRING(email, 1,3) FROM employees;
--3.2
SELECT first_name, salary, salary * 12 AS annual_salary, round(salary, 2) AS rounded_salary, salary * 1.1 AS raise_salary FROM employees;
--3.3
SELECT FORMAT('Project: %s,  Budget: $%s, Status: %s', project_name, budget, status) FROM projects;
--3.4
SELECT first_name, hire_date, AGE(NOW(), hire_date) AS days_worked  FROM employees;

--Part 4
--4.1
SELECT department, AVG(salary) AS average_sal FROM employees GROUP BY department;
--4.2
SELECT project_name, (end_date - start_date) *24  AS worked_hours FROM projects;
--4.3
SELECT department, COUNT(employee_id) AS employee_num FROM employees GROUP BY department HAVING COUNT(employee_id)>1;
--4.4
SELECT MAX(salary) AS max_s, MIN(salary) AS min_s, SUM(salary) AS totall FROM employees;

--Part 5
--5.1
SElECT  employee_id, first_name, last_name, salary, hire_date FROM employees WHERE salary > 65000
UNION 
SElECT  employee_id, first_name, last_name, salary, hire_date FROM employees WHERE hire_date > ' 2020-01-01';
--5.2
SElECT  employee_id, first_name, last_name, salary, department FROM employees WHERE department = 'IT'
INTERSECT
SElECT  employee_id, first_name, last_name, salary, department FROM employees WHERE salary > 65000;
--5.3
SELECT employee_id FROM employees
EXCEPT
SELECT employee_id FROM assignments;

--Part 6
--6.1
SELECT employee_id, first_name FROM employees
WHERE EXISTS (SELECT employee_id FROM assignments WHERE employees.employee_id = assignments.employee_id);
--6.2
SELECT employee_id FROM employees
WHERE employee_id IN (SELECT employee_id FROM assignments WHERE employees.employee_id = assignments.employee_id
                     AND project_id IN (SELECT project_id FROM projects WHERE status = 'Active'));
--6.3
SELECT * FROM employees
WHERE salary > ANY (SELECT salary FROM employees WHERE department = 'Sales');

--Part 7
--7.1
WITH employee_hours AS (SELECT employee_id,
                               AVG(hours_worked) AS avg_hours_worked
                        FROM assignments
                        GROUP BY employee_id)
SELECT e.first_name || ' ' || e.last_name AS employee_name,
       e.department,
       COALESCE(eh.avg_hours_worked, 0.0) AS average_hours_worked,
       RANK() OVER (
           PARTITION BY e.department
           ORDER BY e.salary DESC
           )                              AS salary_rank_in_department
FROM employees e
         LEFT JOIN
     employee_hours eh ON e.employee_id = eh.employee_id
ORDER BY e.department,
         salary_rank_in_department;


--7.2
SELECT p.project_name,
       SUM(a.hours_worked)           AS total_hours,
       COUNT(DISTINCT a.employee_id) AS number_of_employees
FROM projects p
         JOIN
     assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150
ORDER BY total_hours DESC;

--7.3
WITH DepartmentAggregates AS (SELECT department,
                                     first_name,
                                     last_name,
                                     salary,
                                     COUNT(*) OVER (PARTITION BY department)                    AS total_employees,
                                     AVG(salary) OVER (PARTITION BY department)                 AS average_salary,
                                     RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
                              FROM employees)
SELECT da.department,
       da.total_employees,
       ROUND(da.average_salary, 2)            AS average_salary,
       (da.first_name || ' ' || da.last_name) AS highest_paid_employee_name,
       GREATEST(da.salary, 50000)             AS salary_or_50k_min,
       LEAST(da.salary, 50000)                AS salary_or_50k_max
FROM DepartmentAggregates da
WHERE da.salary_rank = 1
ORDER BY da.department;