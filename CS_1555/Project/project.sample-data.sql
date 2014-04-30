--
-- CS 1555 / CS 2055 -- Database Management Systems
-- Prof. Alexandros Labrinidis -- Spring 2014
--

INSERT INTO SCHOOL (school_id, school_name) VALUES (1, 'School of Arts and Sciences');
INSERT INTO SCHOOL (school_id, school_name) VALUES (2, 'School of Medicine');
INSERT INTO SCHOOL (school_id, school_name) VALUES (3, 'School of Engineering');

INSERT INTO DEPT (dept_id, dept_name, school_id) VALUES (1, 'Computer Science', 1);
INSERT INTO DEPT (dept_id, dept_name, school_id) VALUES (2, 'Biological Sciences', 1);
INSERT INTO DEPT (dept_id, dept_name, school_id) VALUES (3, 'History', 1);
INSERT INTO DEPT (dept_id, dept_name, school_id) VALUES (4, 'Electrical and Computer Engineering', 3);
INSERT INTO DEPT (dept_id, dept_name, school_id) VALUES (5, 'Industrial Engineering', 3);
INSERT INTO DEPT (dept_id, dept_name, school_id) VALUES (6, 'Chemical and Petroleum Engineering', 3);
INSERT INTO DEPT (dept_id, dept_name, school_id) VALUES (7, 'Dermatology', 2);
INSERT INTO DEPT (dept_id, dept_name, school_id) VALUES (8, 'Neurology', 2);

INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (1, 'John', 'Smith', 'jsmith', 5);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (2, 'Jack', 'Philips', 'jphil', 4);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (3, 'Walter', 'Sobtsak', 'wsob', 1);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (4, 'Jeffrey', 'Lebowski', 'dude', 8);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (5, 'Barney', 'Stinson', 'legend', 2);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (6, 'Captain', 'Hook', 'chook', 6);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (7, 'John', 'Smith', 'jsmith', 5);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (8, 'Nick', 'Thomas', 'nthom', 7);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (9, 'Cory', 'Philips', 'cphilips', 5);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (10, 'Antonio', 'Maldini', 'amald', 1);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (11, 'Predrak', 'Djordjevic', 'djole', 7);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (12, 'Giovani', 'Silva De Oliviera', 'elmago', 8);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (13, 'Darko', 'Kovacevic', 'darko', 2);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (14, 'Luco', 'Gonzalez', 'luco', 3);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (15, 'George', 'Saravakos', 'gsaravak', 8);
INSERT INTO INSTRUCTORS (fid, first_name, last_name, pitt_account, dept_id) VALUES (16, 'Mulan', 'Fa', 'mulan', 4);

INSERT INTO SUBJECTS (subject, dept_id) VALUES ('Algorithms', 1);
INSERT INTO SUBJECTS (subject, dept_id) VALUES ('History', 3);
INSERT INTO SUBJECTS (subject, dept_id) VALUES ('Circuits', 4);
INSERT INTO SUBJECTS (subject, dept_id) VALUES ('EM Waves', 4);
INSERT INTO SUBJECTS (subject, dept_id) VALUES ('Materials', 5);
INSERT INTO SUBJECTS (subject, dept_id) VALUES ('Chemistry', 6);
INSERT INTO SUBJECTS (subject, dept_id) VALUES ('Health', 7);

INSERT INTO STUDENTS (sid, first_name, last_name, pitt_account, major) VALUES(1, 'Sakis', 'Rouvas', 'sakis', 'Algorithms');
INSERT INTO STUDENTS (sid, first_name, last_name, pitt_account, major) VALUES(2, 'Anna', 'Vissi', 'vissi', 'History');
INSERT INTO STUDENTS (sid, first_name, last_name, pitt_account, major) VALUES(3, 'John', 'Ploutarxos', 'jplou', 'Circuits');
INSERT INTO STUDENTS (sid, first_name, last_name, pitt_account, major) VALUES(4, 'Lampros', 'Konstantaras', 'konstan', 'EM Waves');
INSERT INTO STUDENTS (sid, first_name, last_name, pitt_account, major) VALUES(5, 'Thanos', 'Veggos', 'veggos', 'Materials');
INSERT INTO STUDENTS (sid, first_name, last_name, pitt_account, major) VALUES(6, 'Nick', 'Xilouris', 'psaronik', 'Chemistry');
INSERT INTO STUDENTS (sid, first_name, last_name, pitt_account, major) VALUES(7, 'Antonis', 'Xilouris', 'psaranton', 'Circuits');
INSERT INTO STUDENTS (sid, first_name, last_name, pitt_account, major) VALUES(8, 'Marilena', 'Nikolaou', 'marinik', 'Algorithms');
INSERT INTO STUDENTS (sid, first_name, last_name, pitt_account, major) VALUES(9, 'Peter', 'Sellers', 'pnkpanth', 'Health');
INSERT INTO STUDENTS (sid, first_name, last_name, pitt_account, major) VALUES(10, 'Jake', 'Finn', 'advtime', 'Algorithms');

INSERT INTO COURSES (cid, subject, course_number, name, enrollment, instructor_id) VALUES(1, 'Algorithms', 1, 'Intro to Algorithms', 20, 10);
INSERT INTO COURSES (cid, subject, course_number, name, enrollment, instructor_id) VALUES(2, 'History', 2, 'US History', 12, 11);
INSERT INTO COURSES (cid, subject, course_number, name, enrollment, instructor_id) VALUES(3, 'Circuits', 3, 'Digital Design', 50, 12);
INSERT INTO COURSES (cid, subject, course_number, name, enrollment, instructor_id) VALUES(4, 'Health', 4, 'First Aid', 15, 11);

INSERT INTO SURVEYS (survey_id, cid, num_submitted, sum_q1, sum_q2, sum_q3, sum_q4) VALUES(1, 1, 0, 0, 0, 0, 0);
INSERT INTO SURVEYS (survey_id, cid, num_submitted, sum_q1, sum_q2, sum_q3, sum_q4) VALUES(2, 2, 0, 0, 0, 0, 0);
INSERT INTO SURVEYS (survey_id, cid, num_submitted, sum_q1, sum_q2, sum_q3, sum_q4) VALUES(3, 3, 0, 0, 0, 0, 0);
