DROP TABLE surveydata CASCADE CONSTRAINTS;
DROP TABLE surveys CASCADE CONSTRAINTS;
DROP TABLE courses CASCADE CONSTRAINTS;
DROP TABLE students CASCADE CONSTRAINTS;
DROP TABLE subjects CASCADE CONSTRAINTS;
DROP TABLE instructors CASCADE CONSTRAINTS;
DROP TABLE dept CASCADE CONSTRAINTS;
DROP TABLE school CASCADE CONSTRAINTS;
COMMIT;

@project.schema.sql
COMMIT;

@project.trigger.sql
COMMIT;

@project.sample-data.sql
-- Terms aren't set in sample data
UPDATE courses SET term = 2141;
COMMIT;
