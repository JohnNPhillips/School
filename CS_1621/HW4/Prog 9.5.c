/*Write a program in some language that has both static and stack-
dynamic local variables in subprograms. Create six large (at least
100 * 100) matrices in the subprogram—three static and three stack
dynamic. Fill two of the static matrices and two of the stack-dynamic
matrices with random numbers in the range of 1 to 100. The code in the
subprogram must perform a large number of matrix multiplication oper-
ations on the static matrices and time the process. Then it must repeat
this with the stack-dynamic matrices. Compare and explain the results*/

#include <stdio.h>
#include <time.h>

#define SIZE 100
#define ITERATIONS 100

clock_t start;
clock_t elapsed;

void start_timer() { start = clock(); }
int stop_timer()
{
	elapsed = clock() - start; 
	return elapsed * 1000 / CLOCKS_PER_SEC;
}

void init_matrix(int m[][SIZE])
{
	for (int r = 0; r < SIZE; r++)
		for (int c = 0; c < SIZE; c++)
			m[r][c] = r + c;
}

void mult_matrix()
{
	int m1[SIZE][SIZE];
	int m2[SIZE][SIZE];
	int m3[SIZE][SIZE];
	init_matrix(m1);
	init_matrix(m2);
	
	for (int iter = 0; iter < ITERATIONS; iter++)
	{
		for (int r = 0; r < SIZE; r++)
		{
			for (int c = 0; c < SIZE; c++)
			{
				m3[r][c] = 0;
				for (int x = 0; x < SIZE; x++)
					m3[r][c] += m1[r][x] * m2[x][c];
			}
		}
	}
}

void mult_matrix_static()
{
	static int m1[SIZE][SIZE];
	static int m2[SIZE][SIZE];
	static int m3[SIZE][SIZE];
	init_matrix(m1);
	init_matrix(m2);
	
	for (int iter = 0; iter < ITERATIONS; iter++)
	{
		for (int r = 0; r < SIZE; r++)
		{
			for (int c = 0; c < SIZE; c++)
			{
				m3[r][c] = 0;
				for (int x = 0; x < SIZE; x++)
					m3[r][c] += m1[r][x] * m2[x][c];
			}
		}
	}
}

int main()
{
	start_timer();
	mult_matrix();
	printf("Stack dynamic: %i ms\n", stop_timer());
	
	start_timer();
	mult_matrix_static();
	printf("Static: %i ms\n", stop_timer());
	
	return 0;
}