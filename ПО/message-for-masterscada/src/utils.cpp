#include "Utils.hpp"
#include <stdexcept>

// -- Реализация функций из Utils.hpp --

/// @brief Экранирует одинарные кавычки в строке для безопасной вставки в PostgreSQL.
std::string escapeSql(const std::string& input) {
    std::string output;
    output.reserve(input.size());  // Резервируем память во избежание лишних аллокаций

    for (char c : input) {
        if (c == '\'') {
            output += "''";
        } else {
            output += c;
        }
    }
    return output;
}

// @brief Проверяет, является ли ячейка пустой или содержит ошибку.
bool isCellEmpty(const OpenXLSX::XLCell& cell) {
    auto type = cell.value().type();
    return type == OpenXLSX::XLValueType::Empty || type == OpenXLSX::XLValueType::Error;
}

// @brief Безопасно извлекает целочисленное значение из ячейки.
int getIntValue(const OpenXLSX::XLCellValue& cellValue) {
    switch (cellValue.type()) {
        case OpenXLSX::XLValueType::Integer:
            return cellValue.get<int>();
        case OpenXLSX::XLValueType::Float:
            return static_cast<int>(cellValue.get<double>());
        case OpenXLSX::XLValueType::String: {
            std::string str = cellValue.get<std::string>();
            if (str.empty()) {
                throw std::invalid_argument("Empty string");
            }
            return std::stoi(str);
        }
        default:
            throw std::invalid_argument("Invalid cell type for integer");
    }
}

// @brief Безопасно извлекает строковое значение из ячейки любого базового типа.
std::string getStringValue(const OpenXLSX::XLCellValue& cellValue) {
    switch (cellValue.type()) {
        case OpenXLSX::XLValueType::String:
            return cellValue.get<std::string>();
        case OpenXLSX::XLValueType::Integer:
            return std::to_string(cellValue.get<int>());
        case OpenXLSX::XLValueType::Float:
            return std::to_string(cellValue.get<double>());
        case OpenXLSX::XLValueType::Boolean:
            return cellValue.get<bool>() ? "true" : "false";
        default:
            return "";
    }
}
