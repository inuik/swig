# Swig example using CMake

## Prerequisites ##
* Windows 10.
* CMake.
* Visual Studio 2017.
* Python 2.7.
* Locally installed [SWIG](http://www.swig.org/download.html) & added to ENV PATH.

## How to build manually ##
1. Build Python variant
```shell
vc141
swig.exe -python -c++ example.i
cl /LD example_wrap.cxx example.cpp /I C:\Python27\include /link /LIBPATH:C:\Python27\libs /out:_example.pyd
python .\runme.py
```

2. Build CSharp variant
```shell
vc141
swig.exe -csharp -c++ example.i
cl /LD example_wrap.cxx example.cpp /link /out:example_cs_wrapper.dll
csc -target:library example.cs examplePINVOKE.cs /out:example.dll
csc runme.cs /reference:example.dll
.\runme.exe
```

## How to build with CMake ##
1. Build
```shell
mkdir build
cd build
cmake ..
cmake --build . --target install
```

2. Run Python swig client
```shell
python .\install\python\runme.py
```

3. Run CSharp swig client
```shell
.\install\csharp\runme.exe
```

