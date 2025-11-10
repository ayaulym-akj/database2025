--Part 2
--2.1
CREATE VIEW  employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location
FROM employees e
JOIN departments d ON e.dept_id=d.dept_id;
SELECT * FROM employee_details; --4 rows are returned.  Tom Brown hasn't dept id, so he  doesn't appear.
--2.2
CREATE VIEW dept_statistics AS
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS maximum_salary,
    MIN(e.salary) AS minimum_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id=e.dept_id
GROUP BY d.dept_name;
SELECT * FROM dept_statistics
ORDER BY employee_count DESC;
--2.3
CREATE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS team_size
FROM projects p
JOIN departments d ON p.dept_id=d.dept_id
LEFT JOIN employees e ON d.dept_id=e.dept_id
GROUP BY  p.project_name, p.budget, d.dept_name, d.location;
SELECT * FROM project_overview;
--2.4
CREATE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
JOIN departments d ON e.dept_id=d.dept_id WHERE e.salary>55000;
SELECT * FROM high_earners;

--Part 3
--3.1
CREATE OR REPLACE VIEW  employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary >60000 THEN 'High'
        WHEN e.salary >50000 THEN 'Medium'
        ELSE 'Standard'
    END AS  salary_grade
FROM employees e
JOIN departments d ON e.dept_id=d.dept_id;
SELECT * FROM employee_details;
--3.2
ALTER VIEW high_earners RENAME TO top_performers;
SELECT * FROM top_performers;
--3.3
CREATE VIEW temp_view AS SELECT emp_name, salary FRoM employees WHERE salary <50000;
SELECT * FROM temp_view;
DROP VIEW temp_view;

--Part 4
--4.1
CREATE VIEW employee_salaries AS SElECT emp_id, emp_name, dept_id, salary FROM employees;
SELECT * FROM employee_salaries;
--4.2
UPDATE employee_salaries SET salary= 52000 WHERE emp_name='John Smith';
SELECT * FROM employees WHERE emp_name = 'John Smith'; --yes, table was updated.
--4.3
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary) VALUES
(6, 'Alice Johnson', 102, 58000);
--4.4
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary FROM employees WHERE dept_id=101
WITH LOCAL CHECK OPTION;
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000); -- ERROR: new row violates check option for view "it_employees"

--Part 5
--5.1
                                      drop materialized view dept_summary_mv;
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(DISTINCT e.emp_id) AS total_employees,
    COALESCE(SUM(e.salary), 0) AS total_salary,
    COUNT(DISTINCT p.project_id) AS total_project,
    COALESCE(SUM(p.budget), 0) AS total_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id=e.dept_id
LEFT JOIN projects p ON e.dept_id=p.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;
--5.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(8,  'Charlie Brown', 101, 54000);
REFRESH MATERIALIZED VIEW dept_summary_mv;
select * from dept_summary_mv;--before we have 2 employees in IT department, and now it is 3, also salary and budget in IT department was updated.
--5.3
CREATE UNIQUE INDEX dept_summary_mv_id ON dept_summary_mv(dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
--5.4
drop materialized view project_stats_mv;
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS ass_employees
FROM projects p
JOIN departments d ON p.dept_id=d.dept_id
JOIN employees e ON d.dept_id=e.dept_id
GROUP BY  p.project_name, p.budget, d.dept_name
WITH NO DATA;
REFRESH MATERIALIZED VIEW project_stats_mv;
SELECT * FROM project_stats_mv; --firstly we need refresh, then select.

--Part 6
--6.1
CREATE ROLE analyst;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE USER report_user WITH PASSWORD 'report456';
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';
--6.2
CREATE ROLE db_creator LOGIN PASSWORD 'creator789' CREATEDB;
CREATE ROLE user_manager LOGIN PASSWORD 'manager101' CREATEROLE;
CREATE ROLE admin_user LOGIN PASSWORD 'admin999' SUPERUSER;
--6.3
GRANT SELECT ON TABLE  employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON  employee_details TO  data_viewer;
GRANT SELECT, INSERT ON TABLE employees TO report_user;
--6.4
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

GRANT hr_user1, hr_user2 TO hr_team;
GRANT finance_user1 TO finance_team;
GRANT SELECT, UPDATE ON TABLE employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;
--6.5
REVOKE UPDATE ON TABLE employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;
--6.6
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;

--Part 7
--7.1
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';
GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;
GRANT INSERT, UPDATE ON TABLE employees TO senior_analyst;
--7.2
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';
ALTER VIEW  dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;
SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';
--7.3
CREATE ROLE temp_owner LOGIN;
CREATE TABLE temp_table(id int);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO aaulymkarasaeva;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;
--7.4
CREATE VIEW hr_employee_view AS SELECT emp_name, dept_id FROM employees WHERE dept_id =102;
GRANT SELECT ON hr_employee_view TO hr_team;
CREATE VIEW finance_employee_view AS SELECT  emp_id, emp_name, salary FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;

--Part 8
--8.1
drop view dept_dashboard;
CREATE VIEW dept_dashboard AS
SELECT
    d.dept_name,
    d.location,
    COUNT( DISTINCT e.emp_id) AS total_emp,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    SUM(p.budget) AS total_bud,
    ROUND(SUM(p.budget)/COUNT(e.emp_id), 2) AS b_p_employee
FROM departments d
LEFT JOIN employees e ON d.dept_id=e.dept_id
LEFT JOIN projects p ON e.dept_id=p.dept_id
GROUP BY d.dept_name, d.location;
SELECT * FROM dept_dashboard;
--8.2
ALTER TABLE projects ADD COLUMN created_date timestamp DEFAULT current_timestamp;
SELECT * FROM projects;

CREATE VIEW dept_dashboard AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
CASE
    WHEN p.budget > 150000 THEN 'Critical Review Required'
    WHEN p.budget > 100000 THEN 'Management Approval Needed'
    ELSE 'Standard Process'
END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id=d.dept_id
WHERE p.budget > 75000;

SELECT * FROM high_budget_projects;
--8.3
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON TABLE employees, projects TO entry_role;

CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON TABLE employees, projects TO analyst_role;

CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON TABLE  employees, projects TO manager_role;

CREATE USER alice PASSWORD 'alice123';
CREATE USER bob PASSWORD 'bob123';
CREATE USER charlie PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;
