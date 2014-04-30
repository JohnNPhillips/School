import java.sql.*;

public class omet_submit
{
	public static void printUsage()
	{
		System.out.println("Usage: java omet_submit <survey_id> <sid> <q1> <q2> <q3> <q4> <q5_str>");
	}
	
	public static void main(String args[])
	{
		if (args.length != 7)
		{
			System.out.println("Error: Invalid number of arguments given");
			printUsage();
			return;
		}
		
		int survey_id, sid, q1, q2, q3, q4;
		try
		{
			survey_id = Integer.parseInt(args[0]);
			sid = Integer.parseInt(args[1]);
			q1 = Integer.parseInt(args[2]);
			q2 = Integer.parseInt(args[3]);
			q3 = Integer.parseInt(args[4]);
			q4 = Integer.parseInt(args[5]);
		}
		catch (NumberFormatException nfe)
		{
			System.out.println("Error: Invalid argument. survey_id, sid, q1, q2, q3, and q4 all have to be integer values");
			printUsage();
			return;
		}
		
		String q5_str = args[6];
		
		if (!omet.connect())
		{
			return;
		}
		omet.submitSurvey(survey_id, sid, q1, q2, q3, q4, q5_str);
		omet.disconnect();
	}
}
