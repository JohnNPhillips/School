#include <stdio.h>
#include <string.h>

#define MAX_STUDENTS 10

char name[MAX_STUDENTS][64];
int age[MAX_STUDENTS];
float gpa[MAX_STUDENTS];
char gradelvl[MAX_STUDENTS][32];

int num_students = 0;

void add_student(char *s_name, int s_age, float s_gpa, char *s_gradelvl)
{
	if (num_students == MAX_STUDENTS)
	{
		printf("Error: Reached max number of students\n");
		return;
	}
	
	strncpy(name[num_students], s_name, 64);
	age[num_students] = s_age;
	gpa[num_students] = s_gpa;
	strncpy(gradelvl[num_students], s_gradelvl, 32);
	num_students++;
	
	printf("Student Added: %s\n", s_name);
}

void print_students()
{
	printf("Student List:\n");
	int i = 0;
	for (i = 0; i < num_students; i++)
	{
		printf("Name = %s\nAge = %i\nGPA = %f\nGrade Level: %s\n--------\n", name[i], age[i], gpa[i], gradelvl[i]);
	}
	
	printf("\n");
}

int main()
{
	add_student("George Bush", 20, 3.5, "Sophomore");
	add_student("Barack Obama", 20, 3.5, "Freshman");
	add_student("Bill Clinton", 22, 3.6, "Senior");
	
	print_students();
	
	return 0;
}
