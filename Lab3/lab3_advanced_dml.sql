-- Part A
CREATE DATABASE advanced_lab;

CREATE TABLE employees(
    emp_id serial primary key,
    first_name varchar(50),
    last_name varchar(50),
    department varchar(50),
    salary int,
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


-- Part B
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (DEFAULT, 'Kevin', 'Harris', 'IT');

INSERT INTO employees (first_name, last_name, department, hire_date)
VALUES ('Laura', 'Clark', 'HR', DATE '2024-02-15');

INSERT INTO departments (dept_name, budget) VALUES
('Legal',   70000),
('Support', 65000),
('Research',180000);

INSERT INTO employees (first_name, last_name, hire_date, salary)
VALUES ('Brian', 'Lewis', CURRENT_DATE, ROUND(50000 * 1.1));

DROP TABLE IF EXISTS temp_employees;
CREATE TEMP TABLE temp_employees AS
SELECT *
FROM employees
WHERE 1=0;

INSERT INTO temp_employees
SELECT *
FROM employees
WHERE department = 'IT';



-- Part C
UPDATE employees
SET salary = ROUND(salary * 1.10);

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < DATE '2020-01-01';

UPDATE employees
SET department = CASE
  WHEN salary > 80000 THEN 'Management'
  WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
  ELSE 'Junior'
END;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = (
  SELECT ROUND(AVG(e.salary) * 1.20)
  FROM employees e
  WHERE e.department = d.dept_name
)
WHERE d.dept_name IN (
  SELECT DISTINCT department
  FROM employees
  WHERE department IS NOT NULL
);

UPDATE employees
SET salary = ROUND(salary * 1.15),
    status  = 'Promoted'
WHERE department = 'Sales';



-- Part D
DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > DATE '2023-01-01'
  AND department IS NULL;

DELETE FROM departments
WHERE dept_name NOT IN (
  SELECT DISTINCT department
  FROM employees
  WHERE department IS NOT NULL
);

DELETE FROM projects
WHERE end_date < DATE '2023-01-01'
RETURNING *;




-- Part E
INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Unknown', 'Employee', NULL, NULL);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;



-- Part F
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Nancy', 'Green', 'Marketing', 68000, DATE '2022-08-08')
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id,
          salary - 5000 AS old_salary,
          salary        AS new_salary;

DELETE FROM employees
WHERE hire_date < DATE '2020-01-01'
RETURNING *;



-- Part G
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
SELECT 'Paul', 'Allen', 'IT', 250000, CURRENT_DATE, 'Active'
WHERE NOT EXISTS (
  SELECT 1
  FROM employees
  WHERE first_name = 'Paul' AND last_name = 'Allen'
);


UPDATE employees e
SET salary = ROUND(
  salary * CASE
    WHEN (SELECT d.budget FROM departments d WHERE d.dept_name = e.department) > 100000
      THEN 1.10
    ELSE 1.05
  END
)
WHERE e.department IN (SELECT dept_name FROM departments);


INSERT INTO employees (first_name, last_name, department, salary) VALUES
('Bulk', 'One',   'Support', 45000),
('Bulk', 'Two',   'Support', 45000),
('Bulk', 'Three', 'Support', 45000),
('Bulk', 'Four',  'Support', 45000),
('Bulk', 'Five',  'Support', 45000);

UPDATE employees
SET salary = ROUND(salary * 1.10)
WHERE first_name = 'Bulk';


CREATE TABLE IF NOT EXISTS employee_archive (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    department VARCHAR(50),
    salary     INTEGER,
    hire_date  DATE,
    status     VARCHAR(20),
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO employee_archive (emp_id, first_name, last_name, department, salary, hire_date, status)
SELECT emp_id, first_name, last_name, department, salary, hire_date, status
FROM employees
WHERE status = 'Inactive';
DELETE FROM employees
WHERE status = 'Inactive';



UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
    SELECT COUNT(e.emp_id)
    FROM employees e
    JOIN departments d ON d.dept_name = e.department
    WHERE d.dept_id = p.dept_id
  ) > 3;










