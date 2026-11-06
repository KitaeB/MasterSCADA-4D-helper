#include <OpenXLSX.hpp>
#include <fstream>
#include <iostream>
#include <nlohmann/json.hpp>
#include <string>

#ifdef _WIN32
#    include <windows.h>
#endif

#include "Parser.hpp"

using json = nlohmann::json;

int main(int argc, char* argv[]) {
    // -- Установка кодировки UTF-8 для Windows консоли --
#ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
    SetConsoleCP(CP_UTF8);
#endif

    // -- Чтение конфигурационного файла --
    std::string configPath = (argc > 1) ? argv[1] : "config.json";

    // -- Проверка существования файла конфигурации
    std::ifstream configFile(configPath);
    if (!configFile.is_open()) {
        std::cerr << "Ошибка: не удалось открыть " << configPath << "\n";
        return 1;
    }

    // -- Парсинг JSON конфигурации --
    json config;
    try {
        configFile >> config;
    } catch (const json::parse_error& e) {
        std::cerr << "Ошибка парсинга JSON: " << e.what() << "\n";
        return 1;
    }

    // -- Чтение пути и запрос у пользователя, если он отсутствует --
    std::string excelPath = config.value("path", "");
    if (excelPath.empty()) {
        std::cout << "Путь к Excel файлу (path) не указан в конфигурации.\n"
                  << "Введите полный путь к файлу: ";

        std::getline(std::cin, excelPath);

        // -- Убираем кавычки, если пользователь перетащил файл прямо в окно
        // терминала --
        if (excelPath.size() >= 2 && excelPath.front() == '"' && excelPath.back() == '"') {
            excelPath = excelPath.substr(1, excelPath.size() - 2);
        }

        if (excelPath.empty()) {
            std::cerr << "Ошибка: путь не может быть пустым.\n";
            return 1;
        }
    }

    // -- Обработка nodeId. Может быть передан как пустая строка или число --
    int globalNodeId = 0;
    if (config.contains("node_id")) {
        if (config["node_id"].is_number()) {
            globalNodeId = config["node_id"].get<int>();
        } else if (config["node_id"].is_string() && !config["node_id"].get<std::string>().empty()) {
            try {
                globalNodeId = std::stoi(config["node_id"].get<std::string>());
            } catch (const std::exception&) {
                std::cerr << "Предупреждение: Некорректный формат node_id. Установлен 0.\n";
            }
        }
    }

    // -- Чтение глобального имени узла (node_name) --
    std::string globalNodeName = config.value("node_name", "");

    // -- Считываем наименование таблицы для объектов и сообщений --
    std::string objectTableName = config.value("object_table", "object_table");
    std::string messageTableName = config.value("message_table", "message_table");

    // -- Открытие Excel файла --
    OpenXLSX::XLDocument doc;
    try {
        doc.open(excelPath);
    } catch (const std::exception& e) {
        std::cerr << "Ошибка открытия Excel файла: " << e.what() << "\n";
        return 1;
    }

    // -- Создание SQL файла --
    std::ofstream sqlOut("create.sql");
    if (!sqlOut.is_open()) {
        std::cerr << "Ошибка создания файла create.sql\n";
        return 1;
    }

    // -- Начало транзакции --
    sqlOut << "BEGIN;\n\n";

    // -- Парсинг объектов --
    if (config.contains("object") && config["object"].is_object()) {
        for (const auto& [key, objConfig] : config["object"].items()) {
            // -- Чтение параметров объекта с учетом возможных опечаток в ключах --
            std::string sheetName = objConfig.value("sheet", "");
            auto startRow = static_cast<uint32_t>(objConfig.value("start_row", objConfig.value("object_id", 1)));
            bool hasTech = objConfig.value("has_tech", true);
            auto structId = objConfig.value("struct_id", 0);

            auto objectIdColumn = static_cast<uint32_t>(objConfig.value("object_id_column", 2));
            auto techNameColumn = static_cast<uint32_t>(objConfig.value("tech_name_column", 1));
            auto nameColumn = static_cast<uint32_t>(objConfig.value("name_column", 3));

            // -- Проверка существования листа в Excel файле --
            if (!doc.workbook().worksheetExists(sheetName)) {
                std::cerr << "Предупреждение: Лист объектов '" << sheetName << "' не найден. Пропуск.\n";
                continue;
            }

            // -- Парсинг объектов --
            std::cout << "Парсинг листа объектов: " << sheetName << "...\n";
            auto wks = doc.workbook().worksheet(sheetName);

            // Передаем globalNodeName в качестве аргумента fallback-значения
            parseObjects(wks, objectTableName, startRow, globalNodeId, globalNodeName, structId, hasTech,
                         objectIdColumn, techNameColumn, nameColumn, sqlOut);
        }
    }

    // -- Парсинг сообщений (истории) --
    std::string historSheet = config.value("histor_sheet", "");
    if (!historSheet.empty()) {
        // -- Чтение строки начала сообщений --
        auto historRow = static_cast<uint32_t>(config.value("histor_row", 1));

        // -- Проверка существования листа сообщений --
        if (!doc.workbook().worksheetExists(historSheet)) {
            std::cerr << "Предупреждение: Лист сообщений '" << historSheet << "' не найден. Пропуск.\n";
        } else {
            std::cout << "Парсинг листа сообщений: " << historSheet << "...\n";
            auto wks = doc.workbook().worksheet(historSheet);
            parseMessages(wks, messageTableName, historRow, sqlOut);
        }
    }

    // -- Завершение транзакции --
    sqlOut << "\nCOMMIT;\n";
    sqlOut.close();

    // -- Закрытие Excel файла --
    doc.close();
    std::cout << "Успешно! Скрипт сохранен в create.sql\n";
    return 0;
}
