# cmake/Dependencies.cmake
message(STATUS "=== Настройка зависимостей ===")

# Подключаем CPM
include(CPM)

# Находим библиотеки
find_package(spdlog CONFIG REQUIRED)
find_package(OpenXLSX CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)

# Создаем удобную функцию-помощник для линковки
function(target_link_all_dependencies target_name)
    # Линкуем хедеры используемые в логике
    target_include_directories(${target_name} PRIVATE ${CMAKE_SOURCE_DIR}/include)
    target_include_directories(${target_name} PRIVATE ${CMAKE_SOURCE_DIR}/third_party)

    # Линкуем библиотеки
    target_link_libraries(${target_name} PRIVATE
        spdlog::spdlog
        OpenXLSX::OpenXLSX
        nlohmann_json::nlohmann_json
    )

endfunction()

message(STATUS "==============================")
