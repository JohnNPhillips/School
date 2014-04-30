-- John Phillips

-- >> Question 1 <<
-- Create a view called current_play_in_team (player_id, cur_team_id)
-- that lists the team id of the team that every player
-- currently belongs to.

CREATE OR REPLACE VIEW
	current_play_in_team(player_id, cur_team_id)
	AS
	SELECT player_id, team_id as cur_team_id
	FROM play_in_team WHERE
		to_date IS NULL;

-- >> Question 2 <<
-- Create a view called captain (team_id, player_id) that lists the
-- player id of the current team captain for every team.

CREATE OR REPLACE VIEW
	captain(team_id, player_id)
	AS
	SELECT team_id, player_id
	FROM play_in_team WHERE
		to_date IS NULL AND
		is_captain = '1';

-- >> Question 3 <<
-- Create a constraint called two_digits, to enforce the fact that
-- a player’s squad number cannot be more than 99.

ALTER TABLE play_in_team ADD CONSTRAINT two_digits CHECK (squad_number <= 99);

-- >> Question 4 <<
-- Create a constraint called one_coach, to enforce the fact
-- that a coach cannot be coaching more than one team at the
-- same time.

ALTER TABLE team ADD CONSTRAINT one_coach UNIQUE (coach_id);

-- >> Question 5 <<
-- Assuming table violations (team_id, violation_text) is
-- defined, create a trigger that will insert a violation
-- message every time a team has more than one captains at
-- any point of time. The violation message should
-- include the phrase ”VIOLATION - Multiple Captains”,
-- and the captains’ names

CREATE OR REPLACE TRIGGER multiple_captains
	AFTER INSERT OR UPDATE ON play_in_team
BEGIN
	-- For each pair of conflicting captains
	FOR x IN
	(
		-- Find sets of conflicting captains (player1, player2, team ID)
		SELECT p1.firstname || ' ' || p1.lastname AS player1,
			p2.firstname || ' ' || p2.lastname AS player2,
			tid1 as tid FROM
		(
			-- Find conflicting captains (player IDs, team IDs)
			SELECT * FROM
			(
				-- Select all captains
				SELECT player_id as pid1, team_id as tid1, from_date fd1, NVL(to_date, SYSDATE) as td1
					FROM play_in_team
					WHERE is_captain = '1'
			),
			(
				-- Select all captains
				SELECT player_id as pid2, team_id as tid2, from_date fd2, NVL(to_date, SYSDATE) as td2
					FROM play_in_team
					WHERE is_captain = '1'
			)	
			WHERE
			(
				-- Different players (greater than removes duplicates)
				pid1 > pid2
				AND
				-- Ensure they are on the same team
				tid1 = tid2
				AND
				-- Dates overlap
				((fd2 >= fd1 AND fd2 < td1) OR (td2 > fd1 AND td2 <= td2))
			)
		)
		JOIN player p1 ON p1.player_id = pid1 -- Find player1 name
		JOIN player p2 ON p2.player_id = pid2 -- Find player2 name
	)
	LOOP
		-- Insert violations
		INSERT INTO violations(team_id, violation_text) VALUES
		(
			x.tid,
			'VIOLATION - Multiple Captains - ' || x.player1 || ' and ' || x.player2
		);
	END LOOP;
END;
/