--
-- SCHEMA FOR TERM PROJECT
-- CS 1555 / CS 2055 -- Database Management Systems
-- Prof. Alexandros Labrinidis -- Spring 2014
--

create table School ( 
	school_id int,  
	school_name varchar(50),
	constraint pk_school primary key (school_id)
);

create table Dept (
	dept_id int, 
	dept_name varchar(40), 
	school_id int, 
	constraint pk_dept primary key (dept_id),
	constraint fk_dept_school foreign key (school_id) 
		references School(school_id)
);

create table Instructors (
	fid int, 
	first_name varchar(32), 
	last_name varchar(32), 
	pitt_account varchar(10), 
	dept_id int, 
	constraint pk_instructor primary key (fid),
	constraint fk_instructor_dept foreign key (dept_id)
		references Dept(dept_id)
);

create table Subjects (
	subject varchar(10), 
	dept_id int, 
	constraint pk_subjects primary key (subject),
	constraint fk_subject_dept foreign key (dept_id) 
		references Dept(dept_id)
);

create table Students ( 
	sid int, 
	first_name varchar(32), 
	last_name varchar(32), 
	pitt_account varchar(10), 
	major varchar(10), 
	constraint pk_student primary key (sid),
	constraint fk_student_subject foreign key (major) 
		references Subjects(subject)
);

create table Courses (
	cid int, 
	subject varchar(10), 
	course_number int, 
	name varchar(30), 
	enrollment int, 
	term int, 
	instructor_id int, 
	constraint pk_courses primary key (cid),
	constraint fk_courses_instructor foreign key (instructor_id) 
		references Instructors(fid),
	constraint fk_course_subject foreign key (subject) 
		references Subjects(subject)
);

create table Surveys ( 
	survey_id int, 
	cid int, 
	num_submitted int, 
	sum_q1 int, 
	sum_q2 int, 
	sum_q3 int, 
	sum_q4 int,
	constraint pk_survey primary key (survey_id),
	constraint fk_courses foreign key (cid) 
		references Courses(cid)
);

create table Surveydata ( 
	survey_id int,  
	sid int,
	submit_time date,
	q1 int, 
	q2 int, 
	q3 int, 
	q4 int, 
	q5_str varchar(250),
	constraint pk_survey_data primary key (survey_id, sid),
	constraint fk_sdata_surveys foreign key (survey_id) 
		references Surveys(survey_id),
	constraint fk_sdata_students foreign key (sid) 
		references Students(sid)
);
