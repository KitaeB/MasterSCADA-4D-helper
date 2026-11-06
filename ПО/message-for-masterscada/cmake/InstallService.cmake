# cmake/InstallService.cmake

include(GNUInstallDirs)

# Установка проекта
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    COMPONENT Runtime
)

set(LOG_DIR "log" CACHE STRING "Путь для хранения логов")
set(CONFIG_DIR "config" CACHE STRING "Путь для хранения конфигурации")

# Упаковка пакетов
install(TARGETS ${PROJECT_NAME} RUNTIME_DEPENDENCIES
    # Явно передаем найденные директории vcpkg
    DIRECTORIES ${DEPENDENCY_BIN_DIRS}
    PRE_EXCLUDE_REGEXES "api-ms-.*" "ext-ms-.*"
    POST_EXCLUDE_REGEXES ".*system32/.*" "^/lib" "^/usr/lib"
    DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT Runtime
)

if(LINUX)
    # Собираем сервис в systemd
    set(SERVICE_IN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/service.in")
    if(NOT EXISTS "${SERVICE_IN_FILE}")
        set(SERVICE_IN_FILE "${CMAKE_SOURCE_DIR}/service.in")
    endif()
    if(NOT EXISTS "${SERVICE_IN_FILE}")
        message(FATAL_ERROR "Service template file not found: ${SERVICE_IN_FILE}")
    endif()

    configure_file(
        "${SERVICE_IN_FILE}"
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.service"
        @ONLY
    )

    # Настройка автозапуска
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.service"
        DESTINATION "/etc/systemd/system"
        COMPONENT Systemd
    )
endif()