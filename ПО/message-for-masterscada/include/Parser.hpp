#pragma once
#include <OpenXLSX.hpp>
#include <ostream>
#include <cstdint>

/**
 * @brief Парсит лист сообщений Excel и формирует SQL INSERT/UPDATE скрипт.
 * 
 * @param worksheet Ссылка на рабочий лист (wks) Excel.
 * @param startRow Стартовая строка для чтения.
 * @param sqlOut Выходной поток для записи сформированного SQL.
 */
void parseMessages(OpenXLSX::XLWorksheet& worksheet, uint32_t startRow, std::ostream& sqlOut);

/**
 * @brief Парсит объекты из листа Excel и формирует SQL INSERT/UPDATE скрипт.
 */
void parseObjects(OpenXLSX::XLWorksheet& worksheet, uint32_t startRow, int nodeId, 
                  const std::string& nodeNameFallback, int structId, bool hasTech,
                  uint32_t objectIdColumn, uint32_t techNameColumn, uint32_t nameColumn, std::ostream& sqlOut);