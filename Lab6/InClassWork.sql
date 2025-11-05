CREATE TABLE employeers(
    emp_id SERIAL PRIMARY KEY,
    department VARCHAR(50),
    dep_id INT
);
CREATE TABLE project(
    project_id SERIAL PRIMARY KEY,
    department VARCHAR(50),
    department_name VARCHAR(50),
    dep_id INT,
    budget DECIMAL(10, 2)
);
CREATE TABLE IF NOT EXISTS departments(
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);






SELECT department
FROM employeers
WHERE department = 'Unassigned employeer';

SELECT department
FROM employeers
WHERE department = 'Unassigned project';

SELECT department,
    CASE
        WHEN COUNT(employeers.dep_id) > COUNT(project.dep_id) THEN 'Overloaded'
        ELSE 'Balanced'
    END AS res
FROM departments
LEFT JOIN project ON project.dep_id == employeers.dep_id
GROUP BY employeers.dep_id, project.dep_id;




SELECT dept_name,
    COUNT(employeers.emp_id) AS employee_count,
    SUM()
FROM departments
LEFT JOIN employeers ON employeers.dep_id == departments.dept_id









