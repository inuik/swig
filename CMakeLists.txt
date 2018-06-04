cmake_minimum_required(VERSION 3.10)

project(swig)

# default install prefix under the binary dir for now (allows deleting everything in one shot)
get_filename_component(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" ABSOLUTE)
set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH "default install path" FORCE)

find_package(SWIG REQUIRED)
find_package(PythonInterp REQUIRED)
find_package(PythonLibs REQUIRED)


# add CMake modules in subdirs
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})

include(_UseSWIG)
include_directories( ${PYTHON_INCLUDE_DIRS} )

add_library(cpp_example STATIC example.cpp)

set(module_name example)

# let swig know that example.i is c++
set_source_files_properties(${module_name}.i PROPERTIES CPLUSPLUS ON)

# configure for python generation
swig_add_library(example_py_wrapper SHARED LANGUAGE python SOURCES ${module_name}.i)

# link with python libraries to build the python wrapper
swig_link_libraries(example_py_wrapper cpp_example ${PYTHON_LIBRARIES})

# install required files
install(FILES $<TARGET_FILE:${SWIG_MODULE_example_py_wrapper_REAL_NAME}> DESTINATION python RENAME _${module_name}.pyd)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${module_name}.py DESTINATION python)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/runme.py DESTINATION python)


#
# CSharp variant
#
include(CheckLanguage)
check_language(CSharp)
if (CMAKE_CSharp_COMPILER)
	# configure for csharp generation
	swig_add_library(example_cs_wrapper TYPE SHARED LANGUAGE csharp SOURCES ${module_name}.i)
	
	# link with csharp libraries to build the csharp wrapper
    swig_link_libraries(example_cs_wrapper cpp_example ${CSHARP_LIBRARIES})
	
	install(TARGETS ${SWIG_MODULE_example_cs_wrapper_REAL_NAME} RUNTIME DESTINATION csharp)
	
	enable_language(CSharp)
	# create a csharp library with the generated .cs swig files
	add_library(example SHARED $<TARGET_PROPERTY:example_cs_wrapper,EXTRA_OUTPUT>)
	add_custom_command(
	    TARGET example PRE_BUILD
		COMMAND echo "EXTRA_OUTPUT $<TARGET_PROPERTY:example_cs_wrapper,EXTRA_OUTPUT>"
	)
	
    set_target_properties(example PROPERTIES LINKER_LANGUAGE CSharp)
    target_link_libraries(example ${SWIG_MODULE_example_cs_wrapper_REAL_NAME})
    install(TARGETS example RUNTIME DESTINATION csharp)
	
	# create an executable with the above csharp library
    add_executable(runme runme.cs)
    set_target_properties(runme PROPERTIES LINKER_LANGUAGE CSharp)
    target_link_libraries(runme example)
    install(TARGETS runme RUNTIME DESTINATION csharp)
else()
	message(STATUS "Not building CSharp variant, as suitable compiler not found.")
endif()
