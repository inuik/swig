# Swig example using CMake

## Prerequisites ##
* Windows 10.
* CMake.
* Visual Studio 2017.
* Python 2.7.
* Download [SWIG](http://www.swig.org/download.html) & extract the contents to \<repository root\>\external\swigwin-3.0.12.
```shell
  powershell Invoke-WebRequest https://cytranet.dl.sourceforge.net/project/swig/swigwin/swigwin-3.0.12/swigwin-3.0.12.zip -OutFile swigwin-3.0.12.zip
  powershell Expand-Archive swigwin-3.0.12.zip -DestinationPath .\external
  del swigwin-3.0.12.zip
```

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

