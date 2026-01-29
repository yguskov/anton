package handlers

import (
    "database/sql"
    // "encoding/json"
    // "log"
	"fmt"
	"strings"
    // "go-api/config"
    // "go-api/database"
    // "go-api/middleware"
    "go-api/models"
)

// SaveUserDataToHintsWithCheck извлекает данные из UserData и сохраняет в таблицу hint с проверкой дубликатов
func saveHints(db *sql.DB, userData models.UserData) (int, error) {
    totalInserted := 0
    
    // Извлекаем данные
    position := getString(userData, "position")
    sector := getString(userData, "sector")
    officeCountry := getString(userData, "office_country")
    officeLocation := getString(userData, "office_location")
    dutyData := getSlice(userData, "duty")
    skillData := getSlice(userData, "skill")
    
    // Начинаем транзакцию
    tx, err := db.Begin()
    if err != nil {
        return 0, fmt.Errorf("failed to begin transaction: %w", err)
    }
    
    // Откатываем транзакцию в случае ошибки
    defer func() {
        if err != nil {
            tx.Rollback()
        }
    }()
    
    // 1. Сохраняем position
    if position != "" {
        inserted, err := insertIfNotExists(tx, position, "position")
        if err != nil {
            return 0, fmt.Errorf("failed to insert position: %w", err)
        }
        totalInserted += inserted
    }
    
    // 2. Сохраняем duties
    for _, duty := range dutyData {
        if name := getStringFromMap(duty, "name"); name != "" {
            inserted, err := insertIfNotExists(tx, name, "duty")
            if err != nil {
                return 0, fmt.Errorf("failed to insert duty: %w", err)
            }
            totalInserted += inserted
        }
    }
    
    // 3. Сохраняем skills
    for _, skill := range skillData {
        if name := getStringFromMap(skill, "name"); name != "" {
            inserted, err := insertIfNotExists(tx, name, "skill")
            if err != nil {
                return 0, fmt.Errorf("failed to insert skill: %w", err)
            }
            totalInserted += inserted
        }
    }
    
    // 4. Сохраняем sector
    if sector != "" {
        inserted, err := insertIfNotExists(tx, sector, "sector")
        if err != nil {
            return 0, fmt.Errorf("failed to insert sector: %w", err)
        }
        totalInserted += inserted
    }
    
    // 5. Сохраняем office_country
    if officeCountry != "" {
        inserted, err := insertIfNotExists(tx, officeCountry, "office_country")
        if err != nil {
            return 0, fmt.Errorf("failed to insert office_country: %w", err)
        }
        totalInserted += inserted
    }
    
    // 6. Сохраняем office_location
    if officeLocation != "" {
        inserted, err := insertIfNotExists(tx, officeLocation, "office_location")
        if err != nil {
            return 0, fmt.Errorf("failed to insert office_location: %w", err)
        }
        totalInserted += inserted
    }
    
    // Фиксируем транзакцию
    if err := tx.Commit(); err != nil {
        return 0, fmt.Errorf("failed to commit transaction: %w", err)
    }
    
    return totalInserted, nil
}

// insertIfNotExists вставляет запись, если ее еще нет в базе
func insertIfNotExists(tx *sql.Tx, name, category string) (int, error) {
    // Сначала проверяем существование
    var exists bool
    err := tx.QueryRow(
        "SELECT EXISTS(SELECT 1 FROM hint WHERE name = ? AND category = ?)",
        name, category,
    ).Scan(&exists)
    
    if err != nil {
        return 0, fmt.Errorf("check existence failed: %w", err)
    }
    
    // Если запись уже существует, пропускаем
    if exists {
        return 0, nil
    }
    
    // Вставляем новую запись
    result, err := tx.Exec(
        "INSERT INTO hint (name, category) VALUES (?, ?)",
        name, category,
    )
    if err != nil {
        return 0, fmt.Errorf("insert failed: %w", err)
    }
    
    rowsAffected, err := result.RowsAffected()
    if err != nil {
        return 1, nil // Предполагаем, что вставка прошла успешно
    }
    
    return int(rowsAffected), nil
}

// Вспомогательные функции
func getString(data models.UserData, key string) string {
    if val, ok := data[key]; ok {
        if str, ok := val.(string); ok {
            return strings.TrimSpace(str)
        }
    }
    return ""
}

func getSlice(data models.UserData, key string) []interface{} {
    if val, ok := data[key]; ok {
        if slice, ok := val.([]interface{}); ok {
            return slice
        }
    }
    return []interface{}{}
}

func getStringFromMap(data interface{}, key string) string {
    if m, ok := data.(map[string]interface{}); ok {
        if val, ok := m[key]; ok {
            if str, ok := val.(string); ok {
                return strings.TrimSpace(str)
            }
        }
    }
    return ""
}