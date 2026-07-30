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
        new_password VARCHAR(255) DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        guid VARCHAR(20) NOT NULL,
        user_data JSON,
        is_hr TINYINT(1) DEFAULT 0,
        result json default NULL,
        fio_virtual VARCHAR(255) GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(user_data, '$.fio'))) VIRTUAL,
        position_virtual VARCHAR(255) GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(user_data, '$.position'))) VIRTUAL,
        sector_virtual VARCHAR(255) GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(user_data, '$.sector'))) VIRTUAL,
        INDEX idx_fio (fio_virtual),
        INDEX idx_sector (sector_virtual),
        INDEX idx_position (position_virtual),
        INDEX idx_is_hr (is_hr)
    ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`

    _, err = DB.Exec(createTableSQL)
    if err != nil {
        return fmt.Errorf("error creating user table: %v", err)
    }

    // Создаем таблицу подсказок
    createTableSQL = `
    CREATE TABLE IF NOT EXISTS hint (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) UNIQUE NOT NULL,
        category VARCHAR(255) NOT NULL
    ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`

    _, err = DB.Exec(createTableSQL)
    if err != nil {
        return fmt.Errorf("error creating hint table: %v", err)
    }

    // Создаем таблицу связей обработки 
    createTableSQL = `
    CREATE TABLE IF NOT EXISTS process (
        hr_id INT NOT NULL,
        user_id INT NOT NULL,
        proccessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (hr_id, user_id),
        FOREIGN KEY (hr_id) REFERENCES user(id),
        FOREIGN KEY (user_id) REFERENCES user(id)
    );`

    _, err = DB.Exec(createTableSQL)
    if err != nil {
        return fmt.Errorf("error creating process: %v", err)
    }
    fmt.Println("Database connected and table ensured?")
    return nil
}

// CloseDB закрывает соединение с базой данных
func CloseDB() error {
    if DB != nil {
        return DB.Close()
    }
    return nil
}