# cmake/CPackConfig.cmake

#  Базовые метаданные пакета
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VENDOR "")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Сервис ${PROJECT_NAME}")
set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")

# Настройка генераторов и компонентов в зависимости от ОС
if(WIN32)
    # На Windows создаем портативный архив и классический установщик
    set(CPACK_GENERATOR "ZIP;NSIS")

    # В Windows-пакет обязательно включаем собранные DLL (которые подтянул vcpkg)
    set(CPACK_COMPONENTS_ALL Runtime Dependencies)

    # Настройки для установщика NSIS (добавление в PATH, иконки и т.д.)
    set(CPACK_NSIS_MODIFY_PATH ON)
    set(CPACK_NSIS_DISPLAY_NAME "${CPACK_PACKAGE_NAME}")
endif()

if(UNIX AND NOT APPLE)
    # Проверяем, находимся ли мы на Arch Linux
    if(EXISTS "/etc/arch-release")
        # Для Arch собираем архив tar.zst (нативный формат сжатия)
        set(CPACK_GENERATOR "TZST")

        # Поскольку мы генерируем портативный архив в обход pacman,
        # нам нужно запаковать нестандартные .so зависимости вместе с бинарником.
        set(CPACK_COMPONENTS_ALL Runtime Dependencies Systemd)
    else()
        # Для Debian/Ubuntu собираем .deb пакет
        set(CPACK_GENERATOR "DEB")

        # В .deb пакет кладем только бинарник, библиотеку и systemd-сервис.
        # Системные зависимости разрешатся через apt, поэтому Dependencies исключаем.
        set(CPACK_COMPONENTS_ALL Runtime Systemd)

        # Метаданные специфичные для Debian/Ubuntu
        set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Developer <>")

        # Архитектура пакета
        execute_process(COMMAND dpkg --print-architecture
            OUTPUT_VARIABLE CPACK_DEBIAN_PACKAGE_ARCHITECTURE
            OUTPUT_STRIP_TRAILING_WHITESPACE)

        # Отключаем автоматический поиск зависимостей по библиотекам,
        set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS OFF)
    endif()
endif()

# 3. Инициализация подсистемы упаковки
# Эта команда всегда должна быть в самом конце файла конфигурации CPack
include(CPack)
