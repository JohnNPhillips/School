#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MALLOC(x) my_worstfit_malloc(x)
#define FREE(x) my_free(x)

void * sbrk(int increment);
void *my_worstfit_malloc(int size);
void my_free(void *ptr);

void *base = (void *)-1;

void *my_worstfit_malloc(int size);
void my_free(void *ptr);