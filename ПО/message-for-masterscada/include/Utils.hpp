#pragma once
#include <string>
#include <OpenXLSX.hpp>

/**
 * @brief Экранирует одинарные кавычки в строке для безопасной вставки в PostgreSQL.
 * Механизм: Проходит по всем символам строки и удваивает каждую встреченную кавычку, 
 * что является стандартом экранирования в SQL.
 */
std::string escapeSql(const std::string& input);

/**
 * @brief Проверяет, является ли ячейка пустой или содержит ошибку.
 */
bool isCellEmpty(const OpenXLSX::XLCell& cell);

/**
 * @brief Безопасно извлекает целочисленное значение из ячейки.
 * @throws std::invalid_argument если тип ячейки несовместим или строка пуста.
 */
int getIntValue(const OpenXLSX::XLCellValue& cellValue);

/**
 * @brief Безопасно извлекает строковое значение из ячейки любого базового типа.
 */
std::string getStringValue(const OpenXLSX::XLCellValue& cellValue);