import java.sql.*;

import java.util.ArrayList;

public class omet
{
	public static final String SQL_URL = "jdbc:oracle:thin:@class3.cs.pitt.edu:1521:dbclass";

	public static final String SQL_USERNAME = "";
	public static final String SQL_PASSWORD = "";

	private static Connection connection = null;

	public static boolean connect()
	{
		try
		{
			if (connection != null && !connection.isClosed())
			{
				return true;
			}
		}
		catch (SQLException sqle)
		{
			disconnect();
		}

		try
		{
			// Register the oracle driver.  
			DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());

			//create a connection to DB on class3.cs.pitt.edu
			connection = DriverManager.getConnection(SQL_URL, SQL_USERNAME, SQL_PASSWORD);
		}
		catch (Exception e)
		{
			connection = null;
			System.out.println("Error connecting to database. Machine Error: " + e.toString());
			return false;
		}

		return true;
	}

	public static void disconnect()
	{
		if (connection != null)
		{
			try
			{
				connection.close();
			}
			catch (Exception e)
			{
			}

			connection = null;
		}
	}

	private static void debugResults(ResultSet rs, boolean readFirst) throws SQLException
	{
		System.out.println("=== Output Results ===");

		ResultSetMetaData rsmd = rs.getMetaData();
		while (true)
		{
			if (!readFirst && !rs.next())
			{
				break;
			}
			System.out.println(">> Next Row <<");

			for (int i = 1; i < rsmd.getColumnCount(); i++)
			{
				System.out.println(rsmd.getColumnName(i) + ": " + rs.getString(i));
			}

			if (readFirst && !rs.next())
			{
				break;
			}
		}

		System.out.println("=== End Output Results ===");
	}

	private static PreparedStatement getListStatement(String whereClause) throws SQLException
	{
		String sql = "SELECT survey_id, term, subject, course_number, last_name, " +
			"CASE num_submitted WHEN 0 THEN 0 ELSE (sum_q1 / num_submitted) END AS avg_q1 FROM " +
			"Surveys JOIN Courses ON surveys.cid = courses.cid JOIN Instructors ON instructor_id = fid WHERE " + whereClause;

		return connection.prepareStatement(sql);
	}

	private static double getQuartile(ArrayList<Double> list, double quartile)
	{
		double index = (list.size() - 1) * quartile;

		if (Math.abs(Math.round(index) - index) < 0.001) // allow for minor rounding errors
		{
			return list.get((int)Math.round(index));
		}
		else
		{
			double topBias = index - Math.floor(index);

			double topVal = list.get((int)Math.ceil(index));
			double bottomVal = list.get((int)Math.floor(index));

			return topVal * topBias + bottomVal * (1 - topBias);
		}
	}

	private static String getRoundedAverage(int total, int num)
	{
		return num == 0 ? "n/a" : String.format("%.2g", (double)total / (double)num);
	}

	private static PreparedStatement getStatsStatement(String whereClause) throws SQLException
	{
		String sql = "SELECT CASE num_submitted WHEN 0 THEN 0 ELSE (sum_q1 / num_submitted) END AS avg_q1 FROM " +
			"Surveys JOIN Courses ON surveys.cid = courses.cid JOIN Instructors ON instructor_id = fid " +
			"WHERE " + whereClause + " AND num_submitted > 0 ORDER BY avg_q1 ASC";

		return connection.prepareStatement(sql);
	}

	public static boolean hasResults(String query)
	{
		try
		{
			Statement statement = connection.createStatement();

			ResultSet rs = statement.executeQuery(query);

			boolean hasRes = rs.next();

			statement.close();
			rs.close();

			return hasRes;
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	private static boolean list(PreparedStatement statement)
	{
		try
		{
			ResultSet rs = statement.executeQuery();

			if (!rs.next())
			{
				System.out.println("Sorry, there are no surveys matching those parameters.");
				return true;
			}

			do
			{
				int surveyId = rs.getInt("survey_id");
				int term = rs.getInt("term");
				String subject = rs.getString("subject");
				int courseNum = rs.getInt("course_number");
				String profLastName = rs.getString("last_name");
				String avg_q1 = String.format("%.2g", rs.getDouble("avg_q1"));

				System.out.println(String.format("%d %d %s %d %s %s", surveyId, term, subject, courseNum, profLastName, avg_q1));
			}
			while (rs.next());

			return true;
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	public static boolean listByClass(String subject, int number)
	{
		try
		{
			PreparedStatement statement = getListStatement("subject = ? AND course_number = ?");
			statement.setString(1, subject);
			statement.setInt(2, number);

			return list(statement);
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	public static boolean listByProfessor(String profLastName)
	{
		try
		{
			PreparedStatement statement = getListStatement("last_name = ?");
			statement.setString(1, profLastName);

			return list(statement);
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	public static boolean listBySubject(String subject)
	{
		try
		{
			PreparedStatement statement = getListStatement("subject = ?");
			statement.setString(1, subject);

			return list(statement);
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	public static boolean listByTerm(int term)
	{
		try
		{
			PreparedStatement statement = getListStatement("term = ?");
			statement.setInt(1, term);

			return list(statement);
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	private static void logError(SQLException e)
	{
		System.out.println("Encountered SQL error - " + e.getMessage());
		e.printStackTrace();
	}

	public static boolean showSurvey(int surveyId)
	{
		try
		{
			Statement selectSurvey = connection.createStatement();
			String checkQuery = "SELECT * FROM " +
				"Surveys JOIN Courses ON surveys.cid = courses.cid JOIN Instructors ON instructor_id = fid " +
				"WHERE survey_id = " + surveyId;

			// Get survey
			ResultSet surveyResult = selectSurvey.executeQuery(checkQuery);
			if (!surveyResult.next())
			{
				System.out.println("Invalid survey -- no such survey id: " + surveyId);
				return false;
			}

			int cid = surveyResult.getInt("cid");
			String subject = surveyResult.getString("subject");
			int courseNum = surveyResult.getInt("course_number");
			String profLast = surveyResult.getString("last_name");

			System.out.println(String.format("Survey %d for class %s %d (Prof. %s)", surveyId, subject, courseNum, profLast));

			// Get individual survey results
			Statement selectAll = connection.createStatement();
			String allQuery = "SELECT * FROM Surveydata WHERE survey_id = " + surveyId;

			ResultSet allResults = selectAll.executeQuery(allQuery);
			int num = 0;
			int sum1 = 0, sum2 = 0, sum3 = 0, sum4 = 0;
			while (allResults.next())
			{
				int q1 = allResults.getInt("q1");
				int q2 = allResults.getInt("q2");
				int q3 = allResults.getInt("q3");
				int q4 = allResults.getInt("q4");
				String q5 = allResults.getString("q5_str");

				System.out.println(String.format("%d.  %d   %d   %d   %d   %s", ++num, q1, q2, q3, q4, q5));

				sum1 += q1;
				sum2 += q2;
				sum3 += q3;
				sum4 += q4;
			}

			// Print aggregate summary
			System.out.println("--------------------------------------------------");
			System.out.println("SURVEY SUMMARY:");
			System.out.println("Average Q1: " + getRoundedAverage(sum1, num));
			System.out.println("Average Q2: " + getRoundedAverage(sum2, num));
			System.out.println("Average Q3: " + getRoundedAverage(sum3, num));
			System.out.println("Average Q4: " + getRoundedAverage(sum4, num));
			System.out.println("Submitted: " + num);
			System.out.println("Enrollment: " + surveyResult.getInt("enrollment"));

			surveyResult.close();
			return false;
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	private static boolean stats(PreparedStatement statement)
	{
		try
		{
			ResultSet rs = statement.executeQuery();

			if (!rs.next())
			{
				System.out.println("Sorry, there are no surveys matching those parameters.");
				return true;
			}

			ArrayList<Double> avgList = new ArrayList<Double>();
			do
			{
				avgList.add(rs.getDouble("avg_q1"));
			}
			while (rs.next());

			System.out.println(String.format("%.2g", getQuartile(avgList, 1.00)) + " Max");
			System.out.println(String.format("%.2g", getQuartile(avgList, 0.75)) + " Top 25%");
			System.out.println(String.format("%.2g", getQuartile(avgList, 0.50)) + " Median");
			System.out.println(String.format("%.2g", getQuartile(avgList, 0.25)) + " Bottom 25%");
			System.out.println(String.format("%.2g", getQuartile(avgList, 0.00)) + " Min");

			return true;
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	public static boolean statsByClass(String subject, int number)
	{
		try
		{
			PreparedStatement statement = getStatsStatement("subject = ? AND course_number = ?");
			statement.setString(1, subject);
			statement.setInt(2, number);

			return stats(statement);
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	public static boolean statsByProfessor(String profLastName)
	{
		try
		{
			PreparedStatement statement = getStatsStatement("last_name = ?");
			statement.setString(1, profLastName);

			return stats(statement);
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	public static boolean statsBySubject(String subject)
	{
		try
		{
			PreparedStatement statement = getStatsStatement("subject = ?");
			statement.setString(1, subject);

			return stats(statement);
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	public static boolean statsByTerm(int term)
	{
		try
		{
			PreparedStatement statement = getStatsStatement("term = ?");
			statement.setInt(1, term);

			return stats(statement);
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}

	public static boolean submitSurvey(int surveyId, int sid, int q1, int q2, int q3, int q4, String q5)
	{
		if (q1 < 1 || q1 > 5 || q2 < 1 || q2 > 5 || q3 < 1 || q3 > 5 || q4 < 1 || q4 > 5)
		{
			System.out.println("Error: q1, q2, q3, and q4 must all be between 1 and 5");
			return false;
		}

		try
		{
			String findSurveyQuery = "SELECT * FROM surveys JOIN courses ON surveys.cid = courses.cid WHERE survey_id = " + surveyId;
			Statement findSurveyStatement = connection.createStatement();
			ResultSet surveyResult = findSurveyStatement.executeQuery(findSurveyQuery);
			if (!surveyResult.next())
			{
				System.out.println("Invalid survey -- no such survey id: " + surveyId);
				return false;
			}
			String subject = surveyResult.getString("subject");
			String courseNum = surveyResult.getString("course_number");

			if (!hasResults("SELECT * FROM surveys WHERE survey_id = " + surveyId))
			{
				System.out.println("Invalid survey -- no such survey id: " + surveyId);
				return false;
			}

			if (!hasResults("SELECT * FROM students WHERE sid = " + sid))
			{
				System.out.println("Invalid survey -- no such student id: " + sid);
				return false;
			}

			if (hasResults(String.format("SELECT * FROM surveydata WHERE survey_id = %d AND sid = %d", surveyId, sid)))
			{
				System.out.println("Invalid submission - student has already completed this survey");
				return false;
			}

			String insertQuery = "INSERT INTO surveydata(survey_id, sid, submit_time, q1, q2, q3, q4, q5_str) " +
				"VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
			PreparedStatement ps = connection.prepareStatement(insertQuery);
			ps.setInt(1, surveyId);
			ps.setInt(2, sid);
			ps.setDate(3, new Date(new java.util.Date().getTime()));
			ps.setInt(4, q1);
			ps.setInt(5, q2);
			ps.setInt(6, q3);
			ps.setInt(7, q4);
			ps.setString(8, q5);

			ps.execute();

			System.out.println(String.format("Survey %d for class %s %s recorded.", surveyId, subject, courseNum));
			return true;
		}
		catch (SQLException e)
		{
			logError(e);
			return false;
		}
	}
}