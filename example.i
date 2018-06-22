/* File : example.i */
%module example

/* Do not link against Python debug libraries */
%begin %{
#ifdef _MSC_VER
#define SWIG_PYTHON_INTERPRETER_NO_DEBUG
#endif
%}

%{
#include "example.h"
%}

/* Let's just grab the original header file here */
%include "example.h"
