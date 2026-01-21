package database

import (
    "database/sql"
    "fmt"
    _ "github.com/go-sql-driver/mysql"
)

var DB *sql.DB

func InitDB(dataSourceName string) error {
    var err error
    DB, err = sql.Open("mysql", dataSourceName)
    if err != nil {
        return err
    }

    if err = DB.Ping(); err != nil {
        return err
    }

    // Создаем таблицу пользователей
    createTableSQL := `
    CREATE TABLE IF NOT EXISTS user (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        guid VARCHAR(20) NOT NULL,
        user_data JSON
    )`

    _, err = DB.Exec(createTableSQL)
    if err != nil {
        return fmt.Errorf("error creating user table: %v", err)
    }

    fmt.Println("Database connected and table ensured")
    return nil
}

// CloseDB закрывает соединение с базой данных
func CloseDB() error {
    if DB != nil {
        return DB.Close()
    }
    return nil
}