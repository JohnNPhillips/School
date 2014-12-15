#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define ROWS 512
#define COLS 512

clock_t start;
clock_t elapsed;

void start_timer() { start = clock(); }
int stop_timer()
{
	elapsed = clock() - start; 
	return elapsed * 1000 / CLOCKS_PER_SEC;
}

void subscripting() {
	int var[ROWS][COLS];
	for (int i = 0; i < 1000; i++)
		for (int r = 0; r < ROWS; r++)
			for (int c = 0; c < COLS; c++)
				var[r][c] = r * c;
}

void pointers() {
	char *var = (char *)malloc(ROWS * COLS * sizeof(int));
	for (int i = 0; i < 1000; i++)
		for (int r = 0; r < ROWS; r++)
			for (int c = 0; c < COLS; c++)
				*(int *)(var + (r * COLS + c) * sizeof(int)) = r * c;
}
void stack_var() { int var[1024 * 128]; }
void heap_var() { free(malloc(sizeof(int) * 1024 * 128)); }

int main()
{
	start_timer();
	subscripting();
	printf("Subscripting: %i ms\n", stop_timer());
	
	start_timer();
	pointers();
	printf("Pointers: %i ms\n", stop_timer());
}
