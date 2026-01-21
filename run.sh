#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
BRIGHT_BROWN='\033[38;5;136m'
BROWN_GOLD='\033[38;5;178m'
BROWN_RED='\033[38;5;166m'      # #d75f00 - красно-коричневый
# YELLOW='\033[1;33m'
YELLOW="${BROWN_GOLD}"
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Сохраняем настройки терминала
original_stty=$(stty -g)

# Восстановление терминала
restore_terminal() {
    # Восстанавливаем настройки терминала
    stty "$original_stty" 2>/dev/null
    # Сбрасываем echo и возвращаем нормальный режим
    stty sane
    stty echo
    echo ""  # Гарантированный перевод строки
}

cleanup() {
    echo -e "\n${RED}Завершение процессов...${NC}"
    kill $GO_PID $FLUTTER_PID 2>/dev/null

    # Дополнительно убиваем процессы на порту
    lsof -ti:$GO_PORT | xargs kill -9 2>/dev/null || true
    
    # Восстанавливаем терминал
    restore_terminal

    exit 0
}

# Порт вашего сервера
GO_PORT=8993

# Функция для освобождения порта
free_port() {
    echo "Проверка порта $GO_PORT..."
    PID_ON_PORT=$(lsof -ti:$GO_PORT 2>/dev/null)
    
    if [ ! -z "$PID_ON_PORT" ]; then
        echo "Найден процесс на порту $GO_PORT (PID: $PID_ON_PORT). Завершаем..."
        kill -9 $PID_ON_PORT 2>/dev/null
        sleep 1
        
        # Двойная проверка
        if lsof -ti:$GO_PORT > /dev/null 2>&1; then
            echo "Принудительное освобождение порта..."
            fuser -k $GO_PORT/tcp 2>/dev/null
            sleep 1
        fi
    fi
    echo "Порт $GO_PORT свободен"
}

trap cleanup SIGINT SIGTERM

# Функция для цветного вывода с префиксом
log_with_color() {
    local color=$1
    local prefix=$2
    while read line; do
        echo -e "${color}[$prefix]${NC} $line"
    done
}

# Освобождаем порт перед запуском
free_port

echo -e "${GREEN}Запуск Go-сервера...${NC}"
cd go-api
go run main.go 2>&1 | log_with_color "$YELLOW" "GO" &
GO_PID=$!

sleep 2

echo -e "${GREEN}Запуск Flutter-приложения...${NC}"
cd ..

flutter run -d chrome --web-renderer html --verbose 2>&1 | log_with_color "$BLUE" "FL" &
FLUTTER_PID=$!

echo -e "${GREEN}Оба приложения запущены!${NC}"
echo -e "Go PID: $GO_PID, Flutter PID: $FLUTTER_PID"
echo -e "${RED}Нажмите Ctrl+C для остановки${NC}"

# Мониторинг процессов
while true; do
    if ! kill -0 $GO_PID 2>/dev/null; then
        echo -e "${RED}Go-сервер завершился${NC}"
        break
    fi
    if ! kill -0 $FLUTTER_PID 2>/dev/null; then
        echo -e "${RED}Flutter-приложение завершилось${NC}"
        break
    fi
    sleep 1
done

cleanup