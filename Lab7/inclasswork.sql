-- FROM LAB 6
DROP TABLE IF EXISTS employees;
CREATE TABLE IF NOT EXISTS employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10,2)
);

DROP TABLE IF EXISTS departments;
CREATE TABLE IF NOT EXISTS departments(
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

DROP TABLE IF EXISTS projects;
CREATE TABLE IF NOT EXISTS projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);



-- T1
CREATE VIEW employee_directory AS
SELECT e.emp_name, d.dept_name, d.location, e.salary,
       CASE
           WHEN e.salary > 55000 THEN 'High earner'
           ELSE 'Standart'
        END AS status
FROM employees e
LEFT JOIN departments d ON d.dept_id = e.dept_id
ORDER BY emp_name, dept_name;


-- test
SELECT * FROM employee_directory ORDER BY dept_name;



-- T2
CREATE VIEW project_summary AS
SELECT p.project_name, p.budget, d.dept_name, d.location,
       CASE
            WHEN p.budget > 80000 THEN 'Large'
            WHEN p.budget > 50000 THEN 'Medium'
            ELSE 'SMALL'
        END AS project_size
FROM projects p
JOIN departments d ON p.dept_id =  d.dept_id;

-- test
SELECT * FROM project_summary WHERE project_size = 'Large';


-- T3
CREATE OR REPLACE VIEW employee_directory AS
    SELECT
        CASE
            WHEN d.dept_name LIKE 'IT' || d.dept_name LIKE 'Development' THEN 'Technical'
            ELSE 'Non technical'
        END AS dept_category
FROM employees e
LEFT JOIN departments d ON d.dept_id == e.dept_id;


ALTER VIEW project_summary RENAME TO project_overview;

DROP VIEW project_overview;



-- T4
CREATE MATERIALIZED VIEW dept_summary AS
    SELECT d.name, COUNT(e.emp_id), COUNT(p.project_id), SUM(p.budget)
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON p.dept_id = d.dept_id
GROUP BY d.dept_id
WITH DATA;



INSERT INTO projects (project_id, project_name, dept_id, budget)
VALUES (105, 'Security Audit', 103, 4500);

SELECT * FROM dept_summary d WHERE d.name = 'Operations';

REFRESH MATERIALIZED VIEW dept_summary;

SELECT * FROM dept_summary d WHERE d.name = 'Operations';






-- T5

CREATE ROLE view_role;
GRANT SELECT ON employee_directory, departments TO view_role;

CREATE ROLE editor_role;
GRANT SELECT ON employees, projects, departments TO editor_role;
GRANT INSERT ON employees TO editor_role;
GRANT UPDATE ON employees TO editor_role;



