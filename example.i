/* File : example.i */
%module example

/* Do not link against Python debug libraries */
%begin %{
#ifdef _MSC_VER
#define SWIG_PYTHON_INTERPRETER_NO_DEBUG
#endif
%}

%inline %{
extern int    gcd(int x, int y);
extern double Foo;
%}
