/*
	Consider the following C program. Rewrite it using no gotos or breaks.
	j = -3;
	for (i = 0; i < 3; i++) {
		switch (j + 2) {
			case 3:
			case 2: j--; break;
			case 0: j += 2; break;
			default: j = 0;
		}
		if (j > 0) break;
		j = 3 - i
	}
*/

j = -3;
int done = 0;
for (i = 0; i < 3 && !done; i++)
{
	if (j + 2 == 3 || j + 2 == 2)
		j--;
	else if (j + 2 == 0)
		j += 2;
	else
		j = 0;
	
	if (j > 0)
		done = 1;
	else
		j = 3 - i;
}
