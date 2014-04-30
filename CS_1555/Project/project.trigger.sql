CREATE OR REPLACE TRIGGER update_survey_trigger
	AFTER INSERT ON surveydata
FOR EACH ROW
BEGIN
	UPDATE surveys SET num_submitted = num_submitted + 1,
		sum_q1 = sum_q1 + :new.q1,
		sum_q2 = sum_q2 + :new.q2,
		sum_q3 = sum_q3 + :new.q3,
		sum_q4 = sum_q4 + :new.q4
		WHERE surveys.survey_id = :new.survey_id;
END;
/