cmake_minimum_required(VERSION 3.20)

project(excel-to-sql VERSION 0.0.1 DESCRIPTION "")

# Указываем CMake, что наши самописные модули лежат в папке /cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Подключаем наш файл (расширение .cmake писать не обязательно)
include(CompilerSettings)
include(Dependencies)

# Создаём исполняемый файл
add_executable(${PROJECT_NAME} src/main.cpp src/utils.cpp src/parser.cpp)

# Линкуем все зависимости для нашей библиотеки
target_link_all_dependencies(${PROJECT_NAME})

# Установка сервиса
include(InstallService)

# Упаковка сервиса
include(CPackConfig)

# Определение макросов с дополнительной информацией
target_compile_definitions(${PROJECT_NAME} PUBLIC
    ProjectName=\"${PROJECT_NAME}\"
    ProjectVersion=\"${PROJECT_VERSION}\"
    LOG_DIR=\"${LOG_DIR}\"
    CONFIG_DIR=\"${CONFIG_DIR}\")
