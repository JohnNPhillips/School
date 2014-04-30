public class omet_stats
{
	/*
	 * - java omet-stats term <term>
	 * For example: java omet-stats term 2144. This should generate statistics
	 * for all survey data available for term 2144.
	 * 
	 * - java omet-stats class <subject> <course_number>
	 * For example: java omet-stats class cs 1555. This should generate
	 * statistics for all survey data available for class cs 1555 (regardless
	 * of professor or term).
	 * 
	 * - java omet-stats subject <subject>
	 * For example: java omet-stats subject cs. This should generate statistics
	 * for all survey data available for cs classes (regardless of the specific
	 * class number, the professor, or the term).
	 * 
	 * - java omet-stats prof <prof_lname>
	 * For example: java omet-stats prof Labrinidis. This should generate
	 * statistics for all survey data available for classes that professor
	 * Labrinidis taught (regardless of class or term).
	 */
	public static void printUsage()
	{
		System.out.println("Usage: java omet_stats term <term> OR");
		System.out.println("       java omet_stats class <subject> <course_number> OR");
		System.out.println("       java omet_stats subject <subject> OR");
		System.out.println("       java omet_stats prof <prof_lastname>");
	}

	public static void main(String args[])
	{
		if (args.length == 0)
		{
			System.out.println("Error: No arguments given");
			printUsage();
			return;
		}

		if (!omet.connect())
		{
			return;
		}

		String cmd = args[0];

		try
		{
			if (cmd.equals("term") && args.length == 2)
			{
				omet.statsByTerm(Integer.parseInt(args[1]));
			}
			else if (cmd.equals("class") && args.length == 3)
			{
				omet.statsByClass(args[1], Integer.parseInt(args[2]));
			}
			else if (cmd.equals("subject") && args.length == 2)
			{
				omet.statsBySubject(args[1]);
			}
			else if (cmd.equals("prof") && args.length == 2)
			{
				omet.statsByProfessor(args[1]);
			}
			else
			{
				System.out.println("Error: Invalid command or invalid number of arguments");
				printUsage();
			}
		}
		catch (NumberFormatException nfe)
		{
			System.out.println("Error: Invalid parameter (expected an integer)");
			printUsage();
		}

		omet.disconnect();
	}
}
