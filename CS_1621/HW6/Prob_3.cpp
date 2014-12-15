#include <stdio.h>

class A
{
	public: virtual void print() { printf("ClassA!\n"); }
};
class B : public A
{
	public: virtual void print() { printf("ClassB!\n"); }
};
class C : public B
{
	public: void print() { printf("ClassC!\n"); }
};

int main()
{
	A *a = new A();
	B *b = new B();
	C *c = new C();
	
	a->print();
	a = b;
	a->print();
	a = c;
	a->print();

	return 0;
}