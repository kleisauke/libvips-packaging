SET(CMAKE_C_COMPILER clang)
SET(CMAKE_CXX_COMPILER clang++)

# 10.9 should be a good minimal release target
SET(CMAKE_OSX_DEPLOYMENT_TARGET 10.9)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)