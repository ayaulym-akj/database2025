--Part A
CREATE DATABASE advanced_lab;
DROP TABLE IF EXISTS employees;
CREATE TABLE employees(
    emp_id serial primary key,
    first_name varchar(50),
    last_name varchar(50),
    department varchar(50),
    salary int, --DEFAULT 50000
    hire_date date,
    status varchar(50) DEFAULT 'Active'
);
CREATE TABLE departments(
    dept_id  serial primary key,
    dept_name varchar(50),
    budget int,
    manager_id int
);
CREATE TABLE projects(
    project_id serial primary key,
    project_name varchar(50),
    dept_id int,
    start_date date,
    end_date date,
    budget int
);
--Part B
INSERT INTO employees(first_name, last_name, department) VALUES
('Dastan', 'Satpayev', 'Finance'),
('Sherkhan', 'Kalmyrza', 'IT'),
('Arailym', 'Oralova', 'HR'),
('Dana', 'Kalnazar', 'HR');
INSERT INTO employees(first_name, last_name, department, salary, status) VALUES
('Dastan', 'Satpayev', 'Finance', default, default),
('Sherkhan', 'Kalmyrza', 'IT', default, default),
('Arailym', 'Oralova', 'Design', default, default),
('Dana', 'Kalnazar', 'HR', default, default);
INSERT INTO departments(dept_name, budget, manager_id) VALUES
('IT', 12000, 1),
('Finance', 13000, 2),
('HR', 14000, 4);
INSERT INTO employees(first_name, last_name, department, salary, hire_date) VALUES
('Dastan', 'Satpayev', 'Finance', 50000 * 1.1, current_date),
('Sherkhan', 'Kalmyrza', 'IT', 50000 * 1.1, current_date),
('Arailym', 'Oralova', 'Design', 50000 * 1.1, current_date),
('Dana', 'Kalnazar', 'HR', 50000 * 1.1, current_date);

CREATE TEMP TABLE temp_employees AS 
SELECT * FROM employees
WHERE department = 'IT';

--Part C
UPDATE employees SET salary= salary *1.1; 
UPDATE status= 'Senior' WHERE salary > 60000 and hire_date < '2020-01-01';
UPDATE employees SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;
UPDATE employees SET department= DEFAULT WHERE status='Inactive';
UPDATE departments SET budget = (SELECT AVG(salary) * 1.2 FROM employees e WHERE e.department = departments.dept_name);
UPDATE employees SET salary= salary * 1.15, status = 'Promoted' WHERE department='Sales';

--Part D
DELETE FROM employees WHERE status='Terminated';
DELETE FROM employees WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;
DELETE FROM departments WHERE dept_name NOT IN (SELECT DISTINCT department FROM employees WHERE department IS NOT NULL);
DELETE FROM projects WHERE end_date < '2023-01-01' RETURNING *;

--Part E
INSERT INTO employees(first_name, last_name, department, salary) VALUES
('Dastan', 'Satpayev', NULL, NULL),
('Sherkhan', 'Kalmyrza', 'IT',  NULL, NULL),
('Arailym', 'Oralova', 'Design',  NULL, NULL),
('Dana', 'Kalnazar', 'HR',  NULL, NULL);
UPDATE employees SET department = 'Unassigned' where department IS NULL;
DELETE FROM employees where salary IS NULL OR department IS NULL;

--Part F
INSERT INTO employees(first_name, last_name) VALUES ('Jah', 'Khalib') 
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

UPDATE employees SET salary= salary+5000 where department='IT' RETURNING emp_id, salary-5000 AS old_salary, salary AS new_salary;
DELETE FROM employees WHERE hire_date < '2020-01-01' RETURNING *;

--Part G
--23
INSERT INTO employees(first_name, last_name, department) SELECT 'Ayaulym', 'Karassayeva', 'Finance'
where not exists(
    select * from employees where first_name='Ayaulym' and last_name='Karassayeva'
);
--24
UPDATE employees e 
SET salary=salary*
    CASE
        WHEN budget > 100000 THEN 1.1
        ELSE 1.05
    END
FROM departments d WHERE e.department=d.dept_name;

--25
INSERT INTO employees(first_name, last_name, department) VALUES
('Dastan', 'Satpayev', 'Finance'),
('Sherkhan', 'Kalmyrza', 'IT'),
('Arailym', 'Oralova', 'HR'),
('Dana', 'Kalnazar', 'HR'),
('Amina', 'Shakirbek', 'IT');

UPDATE employees
SET salary = salary * 1.10
WHERE (first_name, last_name) IN (
    ('Dastan', 'Satpayev'),
    ('Sherkhan', 'Kalmyrza'),
    ('Arailym', 'Oralova'),
    ('Dana', 'Kalnazar'),
    ('Amina', 'Shakirbek')
);
 --26
CREATE TABLE employee_archive AS TABLE employees WITH NO DATA;
INSERT INTO employee_archive SELECT * FROM employees WHERE status = 'Inactive';
DELETE FROM employees WHERE status = 'Inactive';
--27
INSERT INTO projects (project_name, dept_id, start_date, end_date, budget) VALUES
('Project A', 1, '2022-01-01', '2023-05-01', 30000),
('Project B', 2, '2023-02-01', '2024-01-01', 40000),
('Project C', 3, '2021-06-15', '2022-12-31', 80000);

UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      JOIN departments d ON e.department = d.dept_name
      WHERE d.dept_id = p.dept_id
  ) > 3;




