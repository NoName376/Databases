-- Create tables
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

-- Insert data
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

-- Task 2.1
CREATE VIEW employee_details AS
SELECT e.emp_id, e.emp_name, d.dept_name, d.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;

-- Task 2.2
CREATE VIEW dept_statistics AS
SELECT d.dept_id, d.dept_name,
       COUNT(e.emp_id) AS employee_count,
       AVG(e.salary) AS avg_salary,
       MIN(e.salary) AS min_salary,
       MAX(e.salary) AS max_salary
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM dept_statistics ORDER BY employee_count DESC;

-- Task 2.3
CREATE VIEW project_overview AS
SELECT p.project_id, p.project_name, p.budget,
       d.dept_id, d.dept_name, d.location,
       COUNT(DISTINCT e.emp_id) AS team_size
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY p.project_id, p.project_name, p.budget,
         d.dept_id, d.dept_name, d.location;

SELECT * FROM project_overview ORDER BY project_id ASC;

-- Task 2.4
CREATE VIEW high_earners AS
SELECT e.emp_id, e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;

-- Task 3.1
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_id, e.emp_name, d.dept_name, d.location, e.salary,
       CASE
         WHEN e.salary > 60000 THEN 'High'
         WHEN e.salary > 50000 THEN 'Medium'
         ELSE 'Standard'
       END AS salary_grade
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details ORDER BY emp_id ASC;

-- Task 3.2
ALTER VIEW high_earners RENAME TO top_performers;
SELECT * FROM top_performers;

-- Task 3.3
CREATE VIEW temp_view AS
SELECT emp_id, emp_name, salary
FROM employees
WHERE salary < 50000;

SELECT * FROM temp_view;
DROP VIEW temp_view;

-- Task 4.1
CREATE VIEW employee_salaries AS
SELECT e.emp_id, e.emp_name, e.dept_id, e.salary
FROM employees e;

SELECT * FROM employee_salaries ORDER BY emp_id ASC;

-- Task 4.2
UPDATE employee_salaries SET salary = 52000 WHERE emp_name = 'John Smith';
SELECT * FROM employees WHERE emp_name = 'John Smith';

-- Task 4.3
INSERT INTO employee_salaries VALUES (6, 'Alice Johnson', 102, 58000);
SELECT * FROM employee_salaries ORDER BY emp_id ASC;

-- Task 4.4
CREATE VIEW it_employees AS
SELECT e.emp_id, e.emp_name, e.dept_id, e.salary
FROM employees e
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

-- Task 5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT d.dept_id, d.dept_name,
       COALESCE(COUNT(DISTINCT e.emp_id), 0) AS total_employees,
       COALESCE(SUM(e.salary), 0) AS total_salaries,
       COALESCE(COUNT(DISTINCT p.project_id), 0) AS total_projects,
       COALESCE(SUM(p.budget), 0) AS total_project_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

-- Task 5.2
INSERT INTO employees VALUES (8, 'Charlie Brown', 101, 54000);
REFRESH MATERIALIZED VIEW dept_summary_mv;
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

-- Task 5.3
CREATE UNIQUE INDEX dept_summary_mv_dept_id_uniqidx
ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

-- Task 6.1
CREATE ROLE analyst;
CREATE ROLE data_viewer WITH LOGIN PASSWORD 'viewer123';
CREATE USER report_user WITH PASSWORD 'report456';
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';

-- Task 6.2
CREATE ROLE db_creator  WITH CREATEDB LOGIN PASSWORD 'creator789';
CREATE ROLE user_manager WITH CREATEROLE LOGIN PASSWORD 'manager101';
CREATE ROLE admin_user WITH SUPERUSER LOGIN PASSWORD 'admin999';

-- Task 6.3
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

-- Task 6.4
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

GRANT hr_team TO hr_user1, hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

SELECT rolname, rolcanlogin AS can_login, rolinherit AS inherits
FROM pg_roles
WHERE rolname IN ('hr_team','finance_team','it_team','hr_user1','hr_user2','finance_user1')
ORDER BY rolname;

SELECT rolname AS user_name,
       ARRAY(SELECT m.rolname
             FROM pg_auth_members am
             JOIN pg_roles m ON am.roleid = m.oid
             WHERE am.member = r.oid) AS member_of_groups
FROM pg_roles r
WHERE r.rolname IN ('hr_user1','hr_user2','finance_user1');

-- Task 6.5
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

-- Task 6.6
ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;
ALTER ROLE analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;

-- Task 7.1
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA 'public' TO read_only;

CREATE ROLE junior_analyst WITH LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst WITH LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst, senior_analyst;
GRANT INSERT, UPDATE ON employees TO senior_analyst;

SELECT rolname AS user_name,
       ARRAY(SELECT m.rolname
             FROM pg_auth_members am
             JOIN pg_roles m ON am.roleid = m.oid
             WHERE am.member = r.oid) AS member_of_roles
FROM pg_roles r
WHERE r.rolname IN ('junior_analyst','senior_analyst');

SELECT grantee, table_name, privilege_type
FROM information_schema.table_privileges
WHERE grantee IN ('read_only','junior_analyst','senior_analyst')
ORDER BY grantee, table_name, privilege_type;

-- Task 7.2
CREATE ROLE project_manager WITH LOGIN PASSWORD 'pm123';
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

-- Task 7.3
CREATE ROLE temp_owner WITH LOGIN;
CREATE TABLE temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP OWNED BY temp_owner;
DROP ROLE temp_owner;

-- Task 7.4
CREATE VIEW hr_employee_view AS
SELECT * FROM employees WHERE dept_id = 102;
GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;

-- Task 8.1
CREATE VIEW dept_dashboard AS
SELECT d.dept_name, d.location,
       COUNT(DISTINCT e.emp_id) AS employee_count,
       ROUND(AVG(e.salary), 2) AS avg_salary,
       COUNT(DISTINCT p.project_id) AS active_projects,
       COALESCE(SUM(p.budget), 0) AS total_budget,
       CASE
         WHEN COUNT(DISTINCT e.emp_id) = 0 THEN 0
         ELSE ROUND(COALESCE(SUM(p.budget), 0) / COUNT(DISTINCT e.emp_id), 2)
       END AS budget_per_employee
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name, d.location;

-- Task 8.2
ALTER TABLE projects ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT p.project_name, p.budget, d.dept_name, p.created_date,
       CASE
         WHEN p.budget > 150000 THEN 'Critical Review Required'
         WHEN p.budget > 100000 THEN 'Management Approval Needed'
         ELSE 'Standard Process'
       END AS approval_status
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

-- Task 8.3
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA 'public' TO viewer_role;

CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE USER alice   WITH PASSWORD 'alice123';
CREATE USER bob     WITH PASSWORD 'bob123';
CREATE USER charlie WITH PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;
