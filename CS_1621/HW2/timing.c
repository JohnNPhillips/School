#include <stdio.h>
#include <stdlib.h>
#include <time.h>

clock_t start;
clock_t elapsed;

void start_timer() { start = clock(); }
int stop_timer()
{
	elapsed = clock() - start; 
	return elapsed * 1000 / CLOCKS_PER_SEC;
}

void static_var() { static int var[1024 * 128]; }
void stack_var() { int var[1024 * 128]; }
void heap_var() { free(malloc(sizeof(int) * 1024 * 128)); }

int main()
{
	start_timer();
	for (int i = 0; i < 100000; i++)
	{
		static_var();
	}
	printf("Static: %i ms\n", stop_timer());
	
	start_timer();
	for (int i = 0; i < 100000; i++)
	{
		stack_var();
	}
	printf("Stack: %i ms\n", stop_timer());
	
	start_timer();
	for (int i = 0; i < 100000; i++)
	{
		heap_var();
	}
	printf("Heap: %i ms\n", stop_timer());
}
