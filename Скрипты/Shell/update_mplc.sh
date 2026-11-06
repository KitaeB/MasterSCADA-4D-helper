#!/bin/bash

# ==========================================
# Базовые настройки конфигурации
# ==========================================
SERVER="download.mps-soft.ru"
USERNAME="GuestSupport"
PASSWORD="guest"
HTTPS_BASE="https://download.mps-soft.ru/support/Updates/Installation/MasterSCADA_4D/RunTime/"

# Список файлов для скачивания (одинаковый для demo и key)
FILES=("admin.tar.gz" "dotnet-runtime.tar.gz" "install.sh" "mplc4.tar.gz" "netcore.tar.gz" "nginx.tar.gz" "rtsp.tar.gz")

# Переходим в директорию самого скрипта, чтобы все пути ./ были относительны его расположения
cd "$(dirname "$0")" || exit 1

# ==========================================
# Вспомогательные функции
# ==========================================

# Проверка связи с сервером
check_connection() {
    echo "Проверка связи с сервером $SERVER..."
    if ! ping -c 4 "$SERVER" > /dev/null 2>&1; then
        echo "Ошибка: Нет связи с сервером $SERVER. Проверьте подключение к интернету."
        exit 1
    else
        echo "Связь с сервером $SERVER установлена."
    fi
}

# Проверка наличия директории /opt/mplc4 и файла uninstall.sh
uninstall_existing() {
    if [ -d "/opt/mplc4" ] && [ -f "/opt/mplc4/uninstall.sh" ]; then
        echo "Удаление существующей установки..."
        sh /opt/mplc4/uninstall.sh
    else
        echo "Директория /opt/mplc4 или файл uninstall.sh не найдены, пропускаем удаление"
    fi
}

# Функция скачивания (используется для demo и key)
download_files() {
    local TARGET_DIR=$1
    local URL_SUFFIX=$2

    check_connection

    # Создание и очистка временной директории tmp
    mkdir -p ./tmp
    rm -rf ./tmp/*

    echo "Скачивание файлов во временную директорию ./tmp..."
    for FILE in "${FILES[@]}"; do
        echo "Загрузка: $FILE"
        if ! wget --no-check-certificate --user="$USERNAME" --password="$PASSWORD" -P ./tmp "${HTTPS_BASE}${URL_SUFFIX}/$FILE"; then
            echo "Ошибка при скачивании $FILE. Очистка tmp и выход."
            rm -rf ./tmp
            exit 1
        fi
    done

    # Если скачивание успешно, перемещаем файлы в целевую директорию
    echo "Загрузка успешно завершена. Замена файлов в $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
    rm -rf "${TARGET_DIR:?}"/* # Очищаем целевую директорию перед заменой
    mv ./tmp/* "$TARGET_DIR/"
    
    # Очистка tmp
    rm -rf ./tmp
    echo "Файлы успешно подготовлены в $TARGET_DIR."
}

#!/bin/bash

# ==========================================
# Базовые настройки конфигурации
# ==========================================
SERVER="download.mps-soft.ru"
USERNAME="GuestSupport"
PASSWORD="guest"
HTTPS_BASE="https://download.mps-soft.ru/support/Updates/Installation/MasterSCADA_4D/RunTime/"

# Список файлов для скачивания (одинаковый для demo и key)
FILES=("admin.tar.gz" "dotnet-runtime.tar.gz" "install.sh" "mplc4.tar.gz" "netcore.tar.gz" "nginx.tar.gz" "rtsp.tar.gz")

# Переходим в директорию самого скрипта, чтобы все пути ./ были относительны его расположения
cd "$(dirname "$0")" || exit 1

# ==========================================
# Вспомогательные функции
# ==========================================

# Проверка связи с сервером
check_connection() {
    echo "Проверка связи с сервером $SERVER..."
    if ! ping -c 4 "$SERVER" > /dev/null 2>&1; then
        echo "Ошибка: Нет связи с сервером $SERVER. Проверьте подключение к интернету."
        exit 1
    else
        echo "Связь с сервером $SERVER установлена."
    fi
}

# Проверка наличия директории /opt/mplc4 и файла uninstall.sh
uninstall_existing() {
    if [ -d "/opt/mplc4" ] && [ -f "/opt/mplc4/uninstall.sh" ]; then
        echo "Удаление существующей установки..."
        sh /opt/mplc4/uninstall.sh
    else
        echo "Директория /opt/mplc4 или файл uninstall.sh не найдены, пропускаем удаление"
    fi
}

# Функция скачивания (используется для demo и key)
download_files() {
    local TARGET_DIR=$1
    local URL_SUFFIX=$2

    check_connection

    # Создание и очистка временной директории tmp
    mkdir -p ./tmp
    rm -rf ./tmp/*

    echo "Скачивание файлов во временную директорию ./tmp..."
    for FILE in "${FILES[@]}"; do
        echo "Загрузка: $FILE"
        if ! wget --no-check-certificate --user="$USERNAME" --password="$PASSWORD" -P ./tmp "${HTTPS_BASE}${URL_SUFFIX}/$FILE"; then
            echo "Ошибка при скачивании $FILE. Очистка tmp и выход."
            rm -rf ./tmp
            exit 1
        fi
    done

    # Если скачивание успешно, перемещаем файлы в целевую директорию
    echo "Загрузка успешно завершена. Замена файлов в $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
    rm -rf "${TARGET_DIR:?}"/* # Очищаем целевую директорию перед заменой
    mv ./tmp/* "$TARGET_DIR/"
    
    # Очистка tmp
    rm -rf ./tmp
    echo "Файлы успешно подготовлены в $TARGET_DIR."
}

# Функция создания сервиса Xvfb и установки самого Xvfb при необходимости
create_xvfb_service() {
    echo "Проверка наличия Xvfb в системе..."
    
    if ! command -v Xvfb > /dev/null 2>&1; then
        echo "Xvfb не установлен. Попытка установки..."
        
        # Определяем пакетный менеджер и устанавливаем
        if command -v apt-get > /dev/null 2>&1; then
            echo "Используется apt-get. Обновление списков и установка xvfb..."
            apt-get update && apt-get install -y xvfb
        elif command -v yum > /dev/null 2>&1; then
            echo "Используется yum. Установка xorg-x11-server-Xvfb..."
            yum install -y xorg-x11-server-Xvfb
        elif command -v dnf > /dev/null 2>&1; then
            echo "Используется dnf. Установка xorg-x11-server-Xvfb..."
            dnf install -y xorg-x11-server-Xvfb
        elif command -v zypper > /dev/null 2>&1; then
            echo "Используется zypper. Установка xorg-x11-server-extra..."
            zypper install -y xorg-x11-server-extra
        else
            echo "Ошибка: Не удалось определить пакетный менеджер. Установите Xvfb вручную (например, 'sudo apt install xvfb') и повторите попытку."
            exit 1
        fi
        
        # Проверяем успешность установки
        if ! command -v Xvfb > /dev/null 2>&1; then
            echo "Ошибка: Установка Xvfb завершилась неудачно. Установите его вручную и повторите попытку."
            exit 1
        fi
        echo "Xvfb успешно установлен."
    else
        echo "Xvfb уже установлен в системе."
    fi

    echo "Создание службы xvfb-report.service для постоянного виртуального дисплея..."
    
    local SERVICE_FILE="/etc/systemd/system/xvfb-report.service"

    # Создаем файл сервиса
    cat << 'EOF' > "$SERVICE_FILE"
[Unit]
Description=X Virtual Frame Buffer for Reports
After=network.target

[Service]
ExecStart=/usr/bin/Xvfb :99 -screen 0 1024x768x16
User=administrator
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    # Установка правильных прав
    chmod 644 "$SERVICE_FILE"

    echo "Перезагрузка конфигурации systemd и запуск службы xvfb-report.service..."
    systemctl daemon-reload
    
    # Очистка возможных старых блокировок
    killall -9 Xvfb xvfb-run 2>/dev/null
    rm -f /tmp/.X99-lock
    rm -f /tmp/.X11-unix/X99
    
    systemctl enable xvfb-report.service
    
    if systemctl restart xvfb-report.service; then
        echo "Служба xvfb-report.service успешно запущена на дисплее :99."
    else
        echo "Ошибка при запуске службы xvfb-report.service. Проверьте логи: journalctl -u xvfb-report.service"
    fi
}

# Функция установки скачанных версий (Runtime)
install_version() {
    local INSTALL_DIR=$1
    local VERSION_TYPE=$2

    if [ ! -d "$INSTALL_DIR" ] || [ ! -f "$INSTALL_DIR/install.sh" ]; then
        echo "Ошибка: Установочные файлы в $INSTALL_DIR не найдены. Сначала скачайте их."
        exit 1
    fi

    # Перед установкой удаляем старую версию
    uninstall_existing

    echo "Начало установки версии $VERSION_TYPE из $INSTALL_DIR..."
    cd "$INSTALL_DIR" || exit 1
    
    if sh install.sh --enable-log --use-systemd --http-port=8043; then
        echo "Установка версии $VERSION_TYPE успешно завершена."

        # Создаем службу виртуального дисплея после установки SCADA
        create_xvfb_service
        
        # Обработка задач cron в зависимости от версии
        if [ "$VERSION_TYPE" = "demo" ]; then
            if ! grep -q "systemctl restart mplc4.service" /etc/crontab; then
                echo "Добавление задачи перезапуска службы mplc4 в /etc/crontab..."
                # Использован корректный синтаксис *0 для перезапуска каждые 30 минут
                if echo "*0 * * * * root /etc/init.d/mplc4 restart" >> /etc/crontab; then
                    echo "Задача успешно добавлена в /etc/crontab."
                else
                    echo "Ошибка при добавлении задачи в /etc/crontab."
                    exit 1
                fi
            else
                echo "Задача перезапуска уже установлена."
            fi
        elif [ "$VERSION_TYPE" = "key" ]; then
            echo "Проверка наличия задачи перезапуска mplc4 в /etc/crontab..."
            if grep -q "systemctl restart mplc4.service" /etc/crontab; then
                echo "Задача найдена, удаление..."
                if sed -i '/systemctl restart mplc4.service/d' /etc/crontab; then
                    echo "Задача успешно удалена из /etc/crontab."
                else
                    echo "Ошибка при удалении задачи из /etc/crontab."
                    exit 1
                fi
            else
                echo "Задача перезапуска mplc4 в /etc/crontab не найдена, пропускаем удаление."
            fi
        fi
    else
        echo "Ошибка при выполнении install.sh."
        exit 1
    fi
    
    # Возврат в начальную директорию скрипта
    cd - > /dev/null || exit 1
}

# Функция скачивания и распаковки клиента
download_client() {
    local CLIENT_DIR="./client"
    local CLIENT_ARCHIVE="MasterSCADA4DClient-linux-x64.tar.gz"
    
    check_connection
    
    mkdir -p ./tmp
    rm -rf ./tmp/*
    
    echo "Скачивание $CLIENT_ARCHIVE во временную директорию ./tmp..."
    if ! wget --no-check-certificate --user="$USERNAME" --password="$PASSWORD" -P ./tmp "${HTTPS_BASE}linux_x64_client/$CLIENT_ARCHIVE"; then
        echo "Ошибка при скачивании клиента."
        rm -rf ./tmp
        exit 1
    fi
    
    echo "Перемещение архива клиента в $CLIENT_DIR..."
    mkdir -p "$CLIENT_DIR"
    rm -rf "${CLIENT_DIR:?}"/*
    mv ./tmp/$CLIENT_ARCHIVE "$CLIENT_DIR/"
    rm -rf ./tmp
    
    # Распаковка архива клиента
    # Флаги tar:
    # -x : извлечь файлы (extract)
    # -z : декомпрессия через gzip (т.к. у нас .tar.gz)
    # -f : указать файл архива (file)
    # -C : указать целевую директорию для распаковки (change directory)
    echo "Распаковка архива клиента в директорию /opt/..."
    if tar -xzf "$CLIENT_DIR/$CLIENT_ARCHIVE" -C /opt/; then
        echo "Клиент успешно скачан и распакован в /opt/."
    else
        echo "Ошибка при распаковке архива в /opt/. Убедитесь, что скрипт запущен с достаточными правами (sudo)."
        exit 1
    fi
}

# Функция скачивания и распаковки клиента
download_monitor() {
    local CLIENT_DIR="./monitor"
    local CLIENT_ARCHIVE="MasterSCADA4D_RT_linux-x64.zip"
    
    check_connection
    
    mkdir -p ./tmp
    rm -rf ./tmp/*
    
    echo "Скачивание $CLIENT_ARCHIVE во временную директорию ./tmp..."
    if ! wget --no-check-certificate --user="$USERNAME" --password="$PASSWORD" -P ./tmp "${HTTPS_BASE}linux_x64_monitor/$CLIENT_ARCHIVE"; then
        echo "Ошибка при скачивании монитора."
        rm -rf ./tmp
        exit 1
    fi
    
    echo "Перемещение архива монитора в $CLIENT_DIR..."
    mkdir -p "$CLIENT_DIR"
    rm -rf "${CLIENT_DIR:?}"/*
    mv ./tmp/$CLIENT_ARCHIVE "$CLIENT_DIR/"
    rm -rf ./tmp
    
    # Распаковка архива клиента
    # Флаги unzip:
    # -d : указать целевую директорию для распаковки (change directory)
    # -q : "quiet" режим (скрыть вывод списка всех файлов при распаковке)    
    echo "Распаковка архива клиента в директорию /opt/..."
    if unzip -q "$CLIENT_DIR/CLIENT_ARCHIVE" -d "./"; then
        echo "монитор успешно скачан и распакован в ./."
    else
        echo "Ошибка при распаковке архива в /opt/. Убедитесь, что скрипт запущен с достаточными правами (sudo)."
        exit 1
    fi

    # Установка клиента
    echo "Установка монитора в директорию /opt/..."
    if sh install.sh; then
        echo "монитор успешно установлен в /opt/.."
    else
        echo "Ошибка при установке в /opt/. Убедитесь, что скрипт запущен с достаточными правами (sudo)."
        exit 1
    fi
}

# ==========================================
# Основное меню
# ==========================================
echo "=========================================="
echo "Выберите действие:"
echo "1) Скачать и установить Demo-версию"
echo "2) Скачать и установить Key-версию (лицензию)"
echo "3) Установить локальную Demo-версию (из ./demo)"
echo "4) Установить локальную Key-версию (из ./key)"
echo "5) Скачать и распаковать в /opt/ MasterSCADA 4D Client"
echo "6) Скачать и распаковать в /opt/ MasterSCADA 4D Monitor"
echo "7) Установить только службу виртуального дисплея (Xvfb :99)"
echo "=========================================="
read -p "Введите номер варианта (1-7): " choice

case $choice in
    1)
        download_files "./demo" "linux-x64"
        install_version "./demo" "demo"
        ;;
    2)
        download_files "./key" "linux-x64_key"
        install_version "./key" "key"
        ;;
    3)
        install_version "./demo" "demo"
        ;;
    4)
        install_version "./key" "key"
        ;;
    5)
        download_client
        ;;
    6)
        download_monitor
        ;;
    7)
        create_xvfb_service
        ;;
    *)
        echo "Неверный выбор. Запустите скрипт снова и введите цифру от 1 до 7."
        exit 1
        ;;
esac

echo "Скрипт завершил работу."