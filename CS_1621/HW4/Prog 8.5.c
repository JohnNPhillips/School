/*
	Consider the following C program. Rewrite it using no gotos.
	for (i = 1; i <= n; i++) {
		for (j = 1; j <= n; j++)
		if (x[i][j] != 0)
			goto reject;
		println ('First all-zero row is:', i);
		break;
	reject:
	}
*/

for (int i = 1; i <= n; i++)
{
	int j;
	for (j = 1; j <= n; j++)
	{
		if (x[i][j] != 0)
			break;
	}
	
	if (j > n)
		println('First all-zero row is:', i);
}
