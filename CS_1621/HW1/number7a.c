#include <stdio.h>
#include <string.h>

typedef struct
{
	char name[64];
	int age;
	float gpa;
	char gradelvl[32];
} student_t;

student_t student_list[10];
int num_students = 0;

void add_student(char *name, int age, float gpa, char *gradelvl)
{
	if (num_students == sizeof(student_list) / sizeof(student_t))
	{
		printf("Error: Reached max number of students\n");
		return;
	}
	
	student_t *s = &student_list[num_students++];
	strncpy(s->name, name, 64);
	s->age = age;
	s->gpa = gpa;
	strncpy(s->gradelvl, gradelvl, 32);
	
	printf("Student Added: %s\n", name);
}

void print_students()
{
	printf("Student List:\n");
	int i = 0;
	for (i = 0; i < num_students; i++)
	{
		student_t *s = &student_list[i];
		printf("Name = %s\nAge = %i\nGPA = %f\nGrade Level: %s\n--------\n", s->name, s->age, s->gpa, s->gradelvl);
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
