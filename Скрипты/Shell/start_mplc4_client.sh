#!/bin/bash

# --- НАСТРОЙКИ ---
# Путь к браузеру Chromium (или google-chrome)
BROWSER="/opt/MasterSCADA4DClient-linux-x64/MasterSCADA4DClient"

# Адреса серверов (Основной и Резервный по двум сетям)
SRV1_IP1="172.16.29.85"
SRV1_IP2="172.16.30.85"
SRV2_IP1="172.16.29.86"
SRV2_IP2="172.16.30.86"

PORT="8043"

# Функция проверки доступности порта
check_service() {
    nc -z -w 1 "$1" "$PORT" > /dev/null 2>&1
}

# --- ПРОВЕРКА ДОСТУПНОСТИ СЕРВЕРОВ ---
ACTIVE_IP=""

# -- Задержка на выполнение скрипта для поднятие сети после включения --
sleep 5

echo "Проверка связи с сервисами на порту $PORT..."

if check_service "$SRV1_IP1"; then
    ACTIVE_IP=$SRV1_IP1
elif check_service "$SRV1_IP2"; then
    ACTIVE_IP=$SRV1_IP2
elif check_service "$SRV2_IP1"; then
    echo "Сервер 1 недоступен. Переключение на Сервер 2 (Сеть 1)"
    ACTIVE_IP=$SRV2_IP1
elif check_service "$SRV2_IP2"; then
    echo "Сервер 1 недоступен. Переключение на Сервер 2 (Сеть 2)"
    ACTIVE_IP=$SRV2_IP2
else
    echo "ВНИМАНИЕ: Ни один сервис не отвечает! Запуск с основного IP."
    ACTIVE_IP=$SRV1_IP1
fi

URL="http://$ACTIVE_IP:$PORT"
echo "Подключение к: $URL"

# --- ЗАПУСК НА ДВА МОНИТОРА ---
$BROWSER -m 2 -f -u $URL

# Отвязываем процессы от текущего терминала
disown -a