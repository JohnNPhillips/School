==============
=== README ===
==============

Author:
	John Phillips

Files:
	omet_submit.java - Omet submit (task 1)
	omet_show.java - Omet show command (task 2)
	omet_list.java - Omet list command (task 3)
	omet_stats.java - Omet stats command (task 4)
	omet.java - Contains all of the methods for accessing and manipulating the database
	
	project.init.sql - Reinitialized the database (drops all of the tables and runs the following SQL files):
		project.schema.sql - Database schema provided to us
		project.trigger.sql - The trigger to update the surveys table when new ones are submitted
		project.sample-data.sql - Sample data given to us
		
Notes:
	To compile: javac *.java
	Usage example: java omet_list prof Labrinidis
	Must run project.trigger.sql before submitting any survey results
	Everything should work
	Quartiles and median for OmetStats are interpolated if they don't land on exact indexes

