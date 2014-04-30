public class omet_show
{
	public static void printUsage()
	{
		System.out.println("Usage: java omet_show <survey_id>");
	}
	
	public static void main(String args[])
	{
		if (args.length != 1)
		{
			System.out.println("Error: Invalid number of arguments given");
			printUsage();
			return;
		}
		
		int survey_id;
		try
		{
			survey_id = Integer.parseInt(args[0]);
		}
		catch (NumberFormatException nfe)
		{
			System.out.println("Error: survey ID must be an integer");
			printUsage();
			return;
		}
		
		if (!omet.connect())
		{
			return;
		}
		omet.showSurvey(survey_id);
		omet.disconnect();
	}
}
