-- Drop all tables
DROP TABLE IF EXISTS student_book_loans CASCADE;
DROP TABLE IF EXISTS library_books CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS student_records CASCADE;
DROP TABLE IF EXISTS class_schedule CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS professors CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS grade_scale CASCADE;
DROP TABLE IF EXISTS semester_calendar CASCADE;

-- Drop all databases
DROP DATABASE IF EXISTS university_backup;
DROP DATABASE IF EXISTS university_distributed;
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_archive;
DROP DATABASE IF EXISTS university_main;




-- Task 1.1

CREATE DATABASE university_main
    OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8';

CREATE DATABASE university_archive
    OWNER = postgres
    CONNECTION LIMIT = 50
    TEMPLATE = template0
    ENCODING = 'UTF8';

CREATE DATABASE university_test
    OWNER = postgres
    CONNECTION LIMIT = 10
    TEMPLATE = template0
    ENCODING = 'UTF8'
    IS_TEMPLATE = true;



-- Task 1.2

CREATE TABLESPACE student_data
    OWNER postgres
    LOCATION '/data/students';

CREATE TABLESPACE course_data
    OWNER postgres
    LOCATION '/data/courses';

CREATE DATABASE university_distributed
    TABLESPACE = student_data
    ENCODING = 'LATIN9';



-- Task 2.1

CREATE TABLE students (
  student_id       SERIAL PRIMARY KEY,
  first_name       VARCHAR(50),
  last_name        VARCHAR(50),
  email            VARCHAR(100),
  phone            CHAR(15),
  date_of_birth    DATE,
  enrollment_date  DATE,
  gpa              NUMERIC(3,2),
  is_active        BOOLEAN,
  graduation_year  SMALLINT
);

CREATE TABLE professors (
  professor_id     SERIAL PRIMARY KEY,
  first_name       VARCHAR(50),
  last_name        VARCHAR(50),
  email            VARCHAR(100),
  office_number    VARCHAR(20),
  hire_date        DATE,
  salary           NUMERIC(12,2),
  is_tenured       BOOLEAN,
  years_experience INTEGER
);

CREATE TABLE courses (
  course_id        SERIAL PRIMARY KEY,
  course_code      CHAR(8),
  course_title     VARCHAR(100),
  description      TEXT,
  credits          SMALLINT,
  max_enrollment   INTEGER,
  course_fee       NUMERIC(10,2),
  is_online        BOOLEAN,
  created_at       TIMESTAMP WITHOUT TIME ZONE
);


-- Task 2.2

CREATE TABLE class_schedule (
    schedule_id      SERIAL PRIMARY KEY,
    course_id        INTEGER,
    professor_id     INTEGER,
    classroom        VARCHAR(30),
    class_date       DATE,
    start_time       TIME WITHOUT TIME ZONE,
    end_time         TIME WITHOUT TIME ZONE,
    session_type     VARCHAR(15),
    room_capacity    INTEGER,
    equipment_needed TEXT
);

CREATE TABLE student_records (
    record_id             SERIAL PRIMARY KEY,
    student_id            INTEGER,
    course_id             INTEGER,
    semester              VARCHAR(20),
    year                  INTEGER,
    grade                 VARCHAR(5),
    attendance_percentage NUMERIC(4,1),
    submission_timestamp  TIMESTAMP WITH TIME ZONE,
    extra_credit_points   NUMERIC(4,1) DEFAULT 0.0,
    final_exam_date       DATE
);

-- Task 3.1

ALTER TABLE students
    ADD COLUMN middle_name VARCHAR(30),
    ADD COLUMN student_status VARCHAR(20),
    ALTER COLUMN phone TYPE VARCHAR(20),
    ALTER COLUMN student_status SET DEFAULT 'ACTIVE',
    ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors
    ADD COLUMN department_code CHAR(5),
    ADD COLUMN research_area TEXT,
    ALTER COLUMN years_experience TYPE SMALLINT,
    ALTER COLUMN is_tenured SET DEFAULT false,
    ADD COLUMN last_promotion_date DATE;

ALTER TABLE courses
    ADD COLUMN prerequisite_course_id INTEGER,
    ADD COLUMN difficulty_level SMALLINT,
    ALTER COLUMN course_code TYPE VARCHAR(10),
    ALTER COLUMN credits SET DEFAULT 3,
    ADD COLUMN lab_required BOOLEAN DEFAULT false;

-- Task 3.2

ALTER TABLE class_schedule
    ADD COLUMN IF NOT EXISTS room_capacity INTEGER,
    DROP COLUMN IF EXISTS duration,
    ADD COLUMN IF NOT EXISTS session_type VARCHAR(15),
    ALTER COLUMN classroom TYPE VARCHAR(30),
    ADD COLUMN IF NOT EXISTS equipment_needed TEXT;

ALTER TABLE student_records
    ADD COLUMN IF NOT EXISTS extra_credit_points NUMERIC(4,1),
    ALTER COLUMN grade TYPE VARCHAR(5),
    ALTER COLUMN extra_credit_points SET DEFAULT 0.0,
    ADD COLUMN IF NOT EXISTS final_exam_date DATE,
    DROP COLUMN IF EXISTS last_updated;


-- Task 4.1

CREATE TABLE departments (
    department_id     SERIAL PRIMARY KEY,
    department_name   VARCHAR(100),
    department_code   CHAR(5),
    building          VARCHAR(50),
    phone             VARCHAR(15),
    budget            NUMERIC(15,2),
    established_year  INTEGER
);

CREATE TABLE library_books (
    book_id               SERIAL PRIMARY KEY,
    isbn                  CHAR(13),
    title                 VARCHAR(200),
    author                VARCHAR(100),
    publisher             VARCHAR(100),
    publication_date      DATE,
    price                 NUMERIC(10,2),
    is_available          BOOLEAN,
    acquisition_timestamp TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE student_book_loans (
    loan_id       SERIAL PRIMARY KEY,
    student_id    INTEGER,
    book_id       INTEGER,
    loan_date     DATE,
    due_date      DATE,
    return_date   DATE,
    fine_amount   NUMERIC(10,2),
    loan_status   VARCHAR(20)
);


-- Task 4.2

ALTER TABLE professors
    ADD COLUMN department_id INTEGER;

ALTER TABLE students
    ADD COLUMN advisor_id INTEGER;

ALTER TABLE courses
    ADD COLUMN department_id INTEGER;


-- Task 4.3

CREATE TABLE grade_scale (
    grade_id        SERIAL PRIMARY KEY,
    letter_grade    CHAR(2),
    min_percentage  NUMERIC(4,1),
    max_percentage  NUMERIC(4,1),
    gpa_points      NUMERIC(4,2)
);

CREATE TABLE semester_calendar (
    semester_id            SERIAL PRIMARY KEY,
    semester_name          VARCHAR(20),
    academic_year          INTEGER,
    start_date             DATE,
    end_date               DATE,
    registration_deadline  TIMESTAMP WITH TIME ZONE,
    is_current             BOOLEAN
);


-- Task 5.2

CREATE TABLE grade_scale (
    grade_id        SERIAL PRIMARY KEY,
    letter_grade    CHAR(2),
    min_percentage  NUMERIC(4,1),
    max_percentage  NUMERIC(4,1),
    gpa_points      NUMERIC(4,2),
    description     TEXT
);

CREATE TABLE semester_calendar (
    semester_id            SERIAL PRIMARY KEY,
    semester_name          VARCHAR(20),
    academic_year          INTEGER,
    start_date             DATE,
    end_date               DATE,
    registration_deadline  TIMESTAMP WITH TIME ZONE,
    is_current             BOOLEAN
);

UPDATE pg_database
    SET datistemplate = FALSE
    WHERE datname = 'university_test';


CREATE DATABASE university_backup
    TEMPLATE university_main;
