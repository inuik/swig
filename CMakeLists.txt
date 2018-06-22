cmake_minimum_required(VERSION 3.12)

project(swig)

enable_testing ()

# default install prefix under the binary dir for now (allows deleting everything in one shot)
get_filename_component(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" ABSOLUTE)
set(CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH "default install path" FORCE)

find_package(SWIG REQUIRED)
include(UseSWIG)


# let swig know that example.i is c++
set_source_files_properties(example.i PROPERTIES CPLUSPLUS ON)


#
# Python variant
#
find_package(Python COMPONENTS Interpreter Development)
if(Python_FOUND)
    include_directories( ${Python_INCLUDE_DIRS} )

    # configure for python generation
    swig_add_library(example_py_wrapper LANGUAGE python SOURCES example.i example.cxx)
    target_include_directories(example_py_wrapper PUBLIC ${CMAKE_CURRENT_LIST_DIR})

    # link with python libraries to build the python wrapper
    target_link_libraries(example_py_wrapper ${Python_LIBRARIES})

    # rename output .pyd file name
    set_target_properties(example_py_wrapper PROPERTIES OUTPUT_NAME example)
    
    # install required files
    
    # install required files
    install(FILES $<TARGET_FILE:${SWIG_MODULE_example_py_wrapper_REAL_NAME}> DESTINATION python RENAME _example.pyd)
    #install(TARGETS example_py_wrapper LIBRARY DESTINATION python)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/example.py DESTINATION python)
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/runme.py DESTINATION python)
    
    add_test (NAME PythonTest
              COMMAND "${CMAKE_COMMAND}" -E env "PYTHONPATH=${CMAKE_CURRENT_BINARY_DIR};$<TARGET_FILE_DIR:${SWIG_MODULE_example_py_wrapper_REAL_NAME}>"
                      "${Python_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/runme.py")

else()
    message(STATUS "Not building Python variant, as suitable interpreter not found.")
endif()

#
# CSharp variant
#
include(CheckLanguage)
check_language(CSharp)
if(CMAKE_CSharp_COMPILER)
    # configure for csharp generation
    swig_add_library(example_cs_wrapper TYPE SHARED LANGUAGE csharp SOURCES example.i example.cxx)
    target_include_directories(example_cs_wrapper PUBLIC ${CMAKE_CURRENT_LIST_DIR})
    install(TARGETS ${SWIG_MODULE_example_cs_wrapper_REAL_NAME} RUNTIME DESTINATION csharp)
    
    enable_language(CSharp)
    # create a csharp library with the generated .cs swig files
    set_source_files_properties( Square.cs Circle.cs Shape.cs PROPERTIES GENERATED 1)
    add_library(example SHARED $<TARGET_PROPERTY:example_cs_wrapper,SWIG_SUPPORT_FILES> Square.cs Circle.cs Shape.cs)
    set_target_properties(example PROPERTIES LINKER_LANGUAGE CSharp)
    target_link_libraries(example example_cs_wrapper)
    install(TARGETS example RUNTIME DESTINATION csharp)

    # create an executable with the above csharp library
    add_executable(runme runme.cs)
    set_target_properties(runme PROPERTIES LINKER_LANGUAGE CSharp)
    target_link_libraries(runme example)
    install(TARGETS runme RUNTIME DESTINATION csharp)
    
    add_test (NAME CSharpTest COMMAND $<TARGET_FILE:runme>)
else()
    message(STATUS "Not building CSharp variant, as suitable compiler not found.")
endif()
