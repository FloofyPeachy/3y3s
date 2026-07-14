cmake_minimum_required(VERSION 3.28...3.30)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/common/bootstrap.cmake" NO_POLICY_SCOPE)

project(${_name} VERSION ${_version})

option(ENABLE_FRONTEND_API "Use obs-frontend-api for UI functionality" OFF)
option(ENABLE_QT "Use Qt functionality" OFF)

include(compilerconfig)
include(defaults)
include(helpers)
include(FetchContent)

add_library(${CMAKE_PROJECT_NAME} MODULE
        src/FrameProcessor.hpp
        src/FrameProcessor.cpp
        src/core/definition.hpp
        src/core/template.cpp
        src/Vision.hpp
        src/Vision.cpp
        src/core/PresetLoader.cpp
        src/GameStatus.cpp
        src/CabinetScoreOutput.cpp
)

find_package(libobs REQUIRED)
find_package(OpenCV REQUIRED)
FetchContent_Declare(
        uws
        GIT_REPOSITORY https://github.com/uNetworking/uWebSockets.git
        GIT_TAG v20.71.0
        GIT_SHALLOW true
)
FetchContent_GetProperties(uws)

if(NOT uws_POPULATED)
  FetchContent_MakeAvailable(uws)
  if(TARGET uSockets)
    set_target_properties(uSockets PROPERTIES POSITION_INDEPENDENT_CODE ON)
  endif()
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(UWS_LTO 0)
  else()
    set(UWS_LTO 1)
  endif()

  find_program(MAKE_EXECUTABLE NAMES gmake make mingw32-make nmake REQUIRED)
  execute_process(
          COMMAND ${CMAKE_COMMAND} -E env WITH_LTO=${UWS_LTO} LIBUS_NO_SSL=1 CFLAGS=-fPIC CXXFLAGS=-fPIC ${MAKE_EXECUTABLE}
          WORKING_DIRECTORY ${uws_SOURCE_DIR}/uSockets
          OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  add_library(uwslib STATIC IMPORTED GLOBAL)
  set_target_properties(uwslib PROPERTIES IMPORTED_LOCATION ${uws_SOURCE_DIR}/uSockets/uSockets.a)
  target_include_directories(uwslib INTERFACE ${uws_SOURCE_DIR}/src ${uws_SOURCE_DIR}/uSockets/src)
  target_compile_definitions(uwslib INTERFACE LIBUS_NO_SSL UWS_WITH_PROXY UWS_HTTPRESPONSE_NO_WRITEMARK)
  target_link_libraries(uwslib INTERFACE -lz)
endif()


target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${uws_SOURCE_DIR}/src)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE OBS::libobs PRIVATE ${OpenCV_LIBS} PRIVATE uwslib)
if(ENABLE_FRONTEND_API)
  find_package(obs-frontend-api REQUIRED)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE OBS::obs-frontend-api)
endif()

if(ENABLE_QT)
  find_package(Qt6 COMPONENTS Widgets Core)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Qt6::Core Qt6::Widgets)
  target_compile_options(
    ${CMAKE_PROJECT_NAME}
    PRIVATE $<$<C_COMPILER_ID:Clang,AppleClang>:-Wno-quoted-include-in-framework-header -Wno-comma>
  )
  set_target_properties(
    ${CMAKE_PROJECT_NAME}
    PROPERTIES AUTOMOC ON AUTOUIC ON AUTORCC ON
  )
endif()

target_sources(${CMAKE_PROJECT_NAME} PRIVATE src/plugin-main.cpp)

set_target_properties_plugin(${CMAKE_PROJECT_NAME} PROPERTIES OUTPUT_NAME ${_name} CXX_STANDARD 20
        CXX_STANDARD_REQUIRED ON
        CXX_EXTENSIONS OFF)
