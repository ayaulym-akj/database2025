--Part 1
CREATE DATABASE university_main
    OWNER = aaulymkarasaeva
    TEMPLATE template0
    ENCODING 'UTF8';

CREATE DATABASE university_archive
    TEMPLATE template0
    CONNECTION LIMIT 50;

CREATE DATABASE university_test
    IS_TEMPLATE true
    CONNECTION LIMIT 10;

--Task 1.2
CREATE TABLESPACE student_data
    LOCATION '/data/students';

CREATE TABLESPACE course_data
    OWNER = aaulymkarasaeva
    LOCATION '/data/courses';

CREATE DATABASE university_distributed
    TABLESPACE student_data
    ENCODING 'LATIN9';


--Part 2
CREATE TABLE students(
    student_id serial PRIMARY KEY,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    phone char(15),
    date_of_birth date,
    enrollment_date date,
    gpa numeric(3,2),
    is_active boolean,
    graduation_year smallint
);

CREATE TABLE professors(
    professor_id serial PRIMARY KEY,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    office_number varchar(20),
    hire_date date,
    salary numeric(10,2),
    is_tenured boolean,
    years_experience int
);

CREATE TABLE courses(
    course_id serial PRIMARY KEY,
    course_code char(8),
    course_title varchar(100),
    description text,
    credits smallint,
    max_enrollment int,
    course_fee numeric(10,2),
    is_online boolean,
    created_at timestamp
);

--Task 2.2
CREATE TABLE class_schedule(
    schedule_id serial primary key,
    course_id int,
    professor_id int,
    classroom varchar(20),
    class_date date,
    start_time time,
    end_time time,
    duration interval
);

CREATE TABLE student_records(
    record_id serial primary key,
    student_id int,
    course_id int,
    semester varchar(20),
    year int,
    grade char(2),
    attendance_percentage numeric(3,1),
    submission_timestamp timestamptz,
    last_updated timestamptz
);


--Part 3
--students
ALTER TABLE students ADD COLUMN middle_name varchar(30);
ALTER TABLE students ADD COLUMN student_status varchar(20);
ALTER TABLE students ALTER COLUMN phone TYPE varchar(20);
ALTER TABLE students ALTER COLUMN student_status SET DEFAULT 'ACTIVE';
ALTER TABLE students ALTER COLUMN gpa SET DEFAULT 0.00;

--professors
ALTER TABLE professors ADD COLUMN department_code char(5);
ALTER TABLE professors ADD COLUMN research_area text;
ALTER TABLE professors ALTER COLUMN years_experience TYPE smallint;
ALTER TABLE professors ALTER COLUMN is_tenured SET DEFAULT false;
ALTER TABLE professors ADD COLUMN last_promotion_date date;

--courses
ALTER TABLE courses ADD COLUMN prerequisite_course_id  int;
ALTER TABLE courses ADD COLUMN diffuculty_level smallint;
ALTER TABLE courses ALTER COLUMN course_code TYPE varchar(10);
ALTER TABLE courses ALTER COLUMN credits    SET DEFAULT 3;
ALTER TABLE courses ADD COLUMN lab_required boolean DEFAULT false;

--Task 3.2
--class_schedule
ALTER TABLE class_schedule ADD COLUMN room_capacity int;
ALTER TABLE class_schedule DROP COLUMN duration;
ALTER TABLE class_schedule ADD COLUMN session_type varchar(30);
ALTER TABLE class_schedule ALTER COLUMN classroom TYPE varchar(30);
ALTER TABLE class_schedule ALTER COLUMN  equipment_needed text;

--student_records
ALTER TABLE student_records ADD COLUMN extra_credit_points numeric(3,1);
ALTER TABLE student_records ALTER COLUMN grade TYPE varchar(5);
ALTER TABLE student_records ALTER COLUMN extra_credit_points SET DEFAULT 0.0;
ALTER TABLE student_records ADD COLUMN final_exam_date date;
ALTER TABLE student_records DROP COLUMN last_updated;


--Part 4
CREATE TABLE departaents(
    department_id serial primary key,
    dapartmaent name varchar(100),
    department_code char(5),
    building varchar(50),
    phone varchar(15),
    budget numeric(10,2),
    established_year int
);
CREATE TABLE library_books(
    book_id serial primary key,
    isbn char(13),
    title varchar(200),
    author varchar(100),
    publisher varchar(100),
    publication_date date,
    price numeric(6,2),
    is_available boolean,
    acquisition_timestamp timestamptz
);
CREATE TABLE student_book_loans(
    loan_id serial primary key,
    student_id int,
    book_id int,
    loan_date date,
    due_date date,
    return_date date,
    fine_amount numeric(6,2),
    loan_status varchar(20)
);

--Task 4.2
ALTER TABLE professors ADD COLUMN department_id int;
ALTER TABLE students ADD COLUMN advisor_id int;
ALTER TABLE courses ADD COLUMN department_id int;

CREATE TABLE grade_scale(
    grade_id serial primary key,
    letter_grade char(2),
    min_percentage numeric(3,1),
    max_percentage numeric(3,1),
    gpa_points numeric(3,2)
);
CREATE TABLE semester_calendar(
    semester_id serial primary key,
    semester_name varchar(20),
    academic_year int,
    start_date date,
    end_date date,
    registration_deadline timestamptz,
    is_current boolean
);


--Part 5
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;
CREATE TABLE grade_scale(
    grade_id serial primary key,
    letter_grade char(2),
    min_percentage numeric(3,1),
    max_percentage numeric(3,1),
    gpa_points numeric(3,2),
    remarks text
);
DROP TABLE semester_calendar CASCADE;
CREATE TABLE semester_calendar(
    semester_id serial primary key,
    semester_name varchar(20),
    academic_year int,
    start_date date,
    end_date date,
    registration_deadline timestamptz,
    is_current boolean
);

--task 5.2
UPDATE pg_database SET datistemplate = FALSE where datname ='university_test';
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;
CREATE DATABASE university_backup
    TEMPLATE university_main;