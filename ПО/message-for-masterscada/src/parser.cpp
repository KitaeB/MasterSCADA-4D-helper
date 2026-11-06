#include "Parser.hpp"
#include "Utils.hpp"

void parseMessages(OpenXLSX::XLWorksheet& worksheet, uint32_t startRow, std::ostream& sqlOut) {
    // -- Парсинг сообщений из Excel листа --
    int currentStructId = -1;
    const int groupsCount = 4;  // Ограничение по количеству проверяемых колонок-групп

    for (uint32_t r = startRow; r <= worksheet.rowCount(); ++r) {
        auto cellA = worksheet.cell(r, 1);
        if (!isCellEmpty(cellA)) {
            try {
                currentStructId = getIntValue(cellA.value());
            } catch (const std::exception&) {
                std::cerr << "Предупреждение: Некорректный идентификатор структуры в строке " << r << ". Пропуск.\n";
                continue;
            }
        }

        // -- Проход по группам сообщений (по 3 колонки на группу) --
        for (int i = 0; i < groupsCount; ++i) {
            auto colMsgId = 3 + (i * 3);
            auto colPriority = 4 + (i * 3);
            auto colMsg = 5 + (i * 3);

            // -- Проверка выхода за пределы количества колонок --
            if (colMsg > worksheet.columnCount()) {
                break;
            }

            // -- Чтение значений ячеек --
            auto cellMsgId = worksheet.cell(r, static_cast<uint16_t>(colMsgId));
            auto cellPriority = worksheet.cell(r, static_cast<uint16_t>(colPriority));
            auto cellMsg = worksheet.cell(r, static_cast<uint16_t>(colMsg));

            // -- Пропуск строк с пустым идентификатором сообщения или текстом --
            if (isCellEmpty(cellMsgId) || isCellEmpty(cellMsg)) {
                std::cerr << "Предупреждение: Пустой идентификатор сообщения или текст в строке " << r << ", колонка "
                          << colMsgId << ". Пропуск.\n";
                continue;
            }

            try {
                // -- Чтение идентификатора сообщения и текста --
                int messageId = getIntValue(cellMsgId.value());
                std::string messageStr = getStringValue(cellMsg.value());
                if (messageStr.empty()) {
                    continue;
                }

                // -- Чтение приоритета сообщения, если он указан, иначе используем дефолтный приоритет 3 --
                int priority = 3;
                if (!isCellEmpty(cellPriority)) {
                    try {
                        priority = getIntValue(cellPriority.value());
                    } catch (const std::exception&) {
                        std::cerr << "Предупреждение: Некорректный приоритет в строке " << r << ", колонка "
                                  << colPriority << ". Используется дефолтный приоритет 3.\n";
                    }
                }

                // -- Запись SQL запроса на вставку или обновление сообщения --
                sqlOut << "INSERT INTO public.message_table (struct_id, message_id, priority, message) "
                       << "VALUES (" << currentStructId << ", " << messageId << ", " << priority << ", '"
                       << escapeSql(messageStr) << "')\n"
                       << "ON CONFLICT (struct_id, message_id) DO UPDATE SET "
                       << "priority = EXCLUDED.priority, message = EXCLUDED.message;\n";

            } catch (const std::exception&) {
                std::cerr << "Предупреждение: Некорректные данные в строке " << r << ", колонка " << colMsgId
                          << ". Пропуск.\n";
            }
        }
    }
}

// -- Парсинг объектов из Excel листа --
void parseObjects(OpenXLSX::XLWorksheet& worksheet, uint32_t startRow, int nodeId, const std::string& nodeNameFallback,
                  int structId, bool hasTech, uint32_t objectIdColumn, uint32_t techNameColumn, uint32_t nameColumn,
                  std::ostream& sqlOut) {
    const uint32_t nodeNameColumn = 4;

    // -- Парсинг объектов из Excel листа --
    for (auto r = startRow; r <= worksheet.rowCount(); ++r) {
        auto cellId = worksheet.cell(r, static_cast<uint16_t>(objectIdColumn));
        auto cellName = worksheet.cell(r, static_cast<uint16_t>(nameColumn));

        // -- Пропуск строк с пустым идентификатором объекта --
        if (isCellEmpty(cellId)) {
            continue;
        }

        try {
            // -- Чтение идентификатора и имени объекта --
            auto objectId = getIntValue(cellId.value());
            std::string objectName = getStringValue(cellName.value());

            // -- Если node_name был считан из JSON, используем его. Иначе берем из таблицы --
            std::string nodeName = nodeNameFallback;
            if (nodeName.empty()) {
                auto cellNodeName = worksheet.cell(r, static_cast<uint16_t>(nodeNameColumn));
                nodeName = getStringValue(cellNodeName.value());
            }

            // -- Чтение технологической позиции объекта, если требуется --
            std::string objectTech;
            if (hasTech) {
                auto cellTech = worksheet.cell(r, static_cast<uint16_t>(techNameColumn));
                objectTech = getStringValue(cellTech.value());
            } else {
                objectTech.swap(objectName);
            }

            // -- Запись SQL запроса на вставку или обновление объекта --
            sqlOut
                << "INSERT INTO public.object_table (struct_id, object_id, object_tech, object_name, nodeid, nodename) "
                << "VALUES (" << structId << ", " << objectId << ", '" << escapeSql(objectTech) << "', '"
                << escapeSql(objectName) << "', " << nodeId << ", '" << escapeSql(nodeName) << "')\n"
                << "ON CONFLICT (struct_id, object_id) DO UPDATE SET "
                << "object_tech = EXCLUDED.object_tech, object_name = EXCLUDED.object_name, "
                << "nodeid = EXCLUDED.nodeid, nodename = EXCLUDED.nodename;\n";

        } catch (const std::exception&) {
            std::cerr << "Предупреждение: Некорректные данные в строке " << r << ". Пропуск.\n";
        }
    }
}
