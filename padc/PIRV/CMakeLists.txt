cmake_minimum_required(VERSION 3.9.0)
project(Lab1 VERSION 0.1.0)

include(CTest)
enable_testing()

set(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)

set(SOURCE_FILES main.cpp matrix_multiply.cpp matrix_multiply.h utils.cpp utils.h )
add_executable(Lab1 main.cpp)

add_library(MatrixMultiply matrix_multiply.cpp)
add_library(Utils utils.cpp)

add_executable(Test1 multiply_test.cpp)
target_link_libraries(Lab1 PUBLIC Utils MatrixMultiply)
target_link_libraries(Test1 PUBLIC MatrixMultiply)

find_package(OpenMP REQUIRED)

# if(OpenMP_CXX_FOUND)
# target_compile_options(Lab1 PRIVATE -Wall ${OpenMP_CXX_FLAGS})
# target_link_libraries(Lab1 PRIVATE ${OpenMP_CXX_FLAGS})
# target_compile_options(Test1 PRIVATE -Wall ${OpenMP_CXX_FLAGS})
# target_link_libraries(Test1 PRIVATE ${OpenMP_CXX_FLAGS})

# endif()

include(FindOpenMP)
if(OPENMP_FOUND)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif(OPENMP_FOUND)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
set(CTEST_OUTPUT_ON_FAILURE, true)
set(CMAKE_VERBOSE_MAKEFILE, true)
include(CPack)

add_test(NAME Test1 COMMAND Test1)

