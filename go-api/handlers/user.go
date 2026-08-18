package handlers

import (
    "database/sql"
    "encoding/json"
    "net/http"
    "log"
    "time"
    "go-api/config"
    "go-api/database"
    "go-api/middleware"
    "go-api/models"
    "golang.org/x/crypto/bcrypt"
    "github.com/rs/xid"
    "fmt"
    "os/exec"
    "crypto/rand"
    "encoding/base64"
    // "strconv"
)

type AuthResponse struct {
    Token string      `json:"token"`
    User  interface{} `json:"user"`
}

type Response struct {
    Success bool        `json:"success"`
    Message string      `json:"message"`
    Data    interface{} `json:"data,omitempty"`
    Error   string      `json:"error,omitempty"`
}

func RegisterHandler(w http.ResponseWriter, r *http.Request, cfg *config.Config) {
    var req models.RegisterRequest
    err := json.NewDecoder(r.Body).Decode(&req)
    if err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    // Проверяем обязательные поля
    if req.Email == "" || req.Password == "" {
        http.Error(w, "Email and password are required", http.StatusBadRequest)
        return
    }

    // Хешируем пароль
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
    if err != nil {
        http.Error(w, "Error processing password", http.StatusInternalServerError)
        return
    }

    // Сохраняем пользователя в БД
    result, err := database.DB.Exec(
        "INSERT INTO user (email, password, user_data, guid) VALUES (?, ?, ?, ?)",
        req.Email, 
        string(hashedPassword), 
        req.UserData,
        xid.New().String(),
    )
    if err != nil {
        http.Error(w, "Error creating user: "+err.Error(), http.StatusInternalServerError)
        return
    }

    userID, err := result.LastInsertId()
    if err != nil {
        http.Error(w, "Error getting user ID", http.StatusInternalServerError)
        return
    }

    // Получаем созданного пользователя
    var user models.User
    err = database.DB.QueryRow(
        "SELECT id, email, user_data, created_at, guid FROM user WHERE id = ?",
        userID,
    ).Scan(&user.ID, &user.Email, &user.UserData, &user.CreatedAt, &user.Guid)
    if err != nil {
        http.Error(w, "Error retrieving user", http.StatusInternalServerError)
        return
    }

    // save hints
    saveHints(database.DB, user.UserData);

    // Генерируем JWT токен
    token, err := middleware.GenerateJWTToken(user.ID, user.Email, cfg)
    if err != nil {
        writeResponse(w, http.StatusInternalServerError, Response{
            Success: false,
            Error:   "Error generating token",
        })
        return
    }

    authResponse := AuthResponse{
        Token: token,
        User:  user,
    }

    writeResponse(w, http.StatusCreated, Response{
        Success: true,
        Message: "User registered successfully",
        Data:    authResponse,
    })


    // w.Header().Set("Content-Type", "application/json")
    // w.WriteHeader(http.StatusCreated)
    // json.NewEncoder(w).Encode(user)
}

func LoginHandler(w http.ResponseWriter, r *http.Request, cfg *config.Config) {
    var req models.LoginRequest
    err := json.NewDecoder(r.Body).Decode(&req)
    if err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    var user models.User
    err = database.DB.QueryRow(
        "SELECT id, email, password, new_password, user_data, created_at, guid FROM user WHERE email = ?",
        req.Email,
    ).Scan(&user.ID, &user.Email, &user.Password, &user.NewPassword, &user.UserData, &user.CreatedAt, &user.Guid)
    
    if err == sql.ErrNoRows {
        http.Error(w, "Invalid credentials", http.StatusUnauthorized)
        return
    } else if err != nil {
        http.Error(w, "Database error", http.StatusInternalServerError)
        return
    }

    // Проверяем пароль
    if !checkPassword(&user, req.Password) {
        http.Error(w, "Invalid credentials", http.StatusUnauthorized)
        return
    }

    // Генерируем JWT токен
    token, err := middleware.GenerateJWTToken(user.ID, user.Email, cfg)
    if err != nil {
        writeResponse(w, http.StatusInternalServerError, Response{
            Success: false,
            Error:   "Error generating token",
        })
        return
    }

    response := models.UserResponse{
        ID:        user.ID,
        Email:     user.Email,
        UserData:  user.UserData,
        CreatedAt: user.CreatedAt.Format(time.RFC3339),
        Guid:      user.Guid,
    }

    authResponse := AuthResponse{
        Token: token,
        User:  response,
    }

    writeResponse(w, http.StatusOK, Response{
        Success: true,
        Message: "Login successful",
        Data:    authResponse,
    })

    // response := models.UserResponse{
    //     ID:        user.ID,
    //     Email:     user.Email,
    //     UserData:  user.UserData,
    //     CreatedAt: user.CreatedAt.Format("2006-01-02 15:04:05"),
    // }

    // w.Header().Set("Content-Type", "application/json")
    // json.NewEncoder(w).Encode(response)
}
func ClearHandler(w http.ResponseWriter, r *http.Request, cfg *config.Config) {
    var req models.ClearRequest
    err := json.NewDecoder(r.Body).Decode(&req)
    
    if err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    var user models.User
    err = database.DB.QueryRow(
        "SELECT id, email, password, new_password, user_data, created_at, guid FROM user WHERE email = ?",
        req.Email,
    ).Scan(&user.ID, &user.Email, &user.Password, &user.NewPassword, &user.UserData, &user.CreatedAt, &user.Guid)
    
    if err == sql.ErrNoRows {
        http.Error(w, "Invalid request", http.StatusUnauthorized)
        return
    } else if err != nil {
        http.Error(w, "Database error "+err.Error(), http.StatusInternalServerError)
        return
    }

    password, _ := GeneratePasswordBase64(8)

    // Хешируем новый пароль
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
    if err != nil {
        http.Error(w, "Error processing new password", http.StatusInternalServerError)
        return
    }

    log.Printf(" Create new password for id=%d =%s", user.ID, string(hashedPassword))

    // Меняем пароль
    result, err := database.DB.Exec(
        "UPDATE user SET new_password = ? WHERE id = ?",
        string(hashedPassword), user.ID, 
    )

    if err != nil {
        // Обработка ошибки SQL (например, сбой подключения, синтаксис и т.д.)
        http.Error(w, "Database error", http.StatusUnauthorized)
        return
    }

    rowsAffected, err := result.RowsAffected()
    if err != nil {
        // Ошибка при получении количества затронутых строк (редко, но возможно)
        http.Error(w, "Get updated rows error", http.StatusUnauthorized)
        return
    }

    if rowsAffected == 0 {
        // ❌ Ни одна строка не обновлена:
        http.Error(w, "User not found or old password is incorrect", http.StatusUnauthorized)
        return 
    }

    // send mail via php script
    email := req.Email
    newPassword, err := SendMailViaPHP(email, password)
    
    if err != nil {
        fmt.Printf("Ошибка: %v\n", err)
        return
    }
    
    fmt.Printf("Пароль отправлен: %s\n", newPassword)

    writeResponse(w, http.StatusOK, Response{
        Success: true,
        Message: "Change password successfull",
    })
}

// SendMailViaPHP отправляет письмо через PHP CLI
func SendMailViaPHP(email, password string) (string, error) {
    // Путь к PHP-скрипту
    scriptPath := "/mailsend/test.php"
    
    // Формируем команду
    cmd := exec.Command("php", scriptPath, email, password)
    
    // Выполняем
    output, err := cmd.CombinedOutput()
    if err != nil {
        return "", fmt.Errorf("ошибка выполнения: %w, вывод: %s", err, string(output))
    }
    
    // Парсим JSON ответ
    var result struct {
        Success bool   `json:"success"`
        Password string `json:"password"`
        Error   string `json:"error"`
    }
    
    if err := json.Unmarshal(output, &result); err != nil {
        return "", fmt.Errorf("ошибка парсинга: %w, вывод: %s", err, string(output))
    }
    
    if !result.Success {
        return "", fmt.Errorf("ошибка PHP: %s", result.Error)
    }
    
    // return password, nil
    return result.Password, nil
}

func GetUsersHandlerOld(w http.ResponseWriter, r *http.Request) {
    rows, err := database.DB.Query("SELECT id, email, user_data, created_at FROM user")
    if err != nil {
        http.Error(w, "Error fetching users", http.StatusInternalServerError)
        return
    }
    defer rows.Close()

    var users []models.UserResponse
    for rows.Next() {
        var user models.UserResponse
        var userData models.UserData
        
        err := rows.Scan(&user.ID, &user.Email, &userData, &user.CreatedAt)
        if err != nil {
            http.Error(w, "Error scanning user", http.StatusInternalServerError)
            return
        }
        
        user.UserData = userData
        users = append(users, user)
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(users)
}

func GetProfileHandler(w http.ResponseWriter, r *http.Request) {
    // Извлекаем из контекста
    userID, ok := middleware.GetUserIDFromContext(r.Context())
    if !ok {
        writeResponse(w, http.StatusInternalServerError, Response{
            Success: false,
            Error:   "Error when define user",
        })
        return
    }

    var user models.User
    // var userData models.UserData
    err := database.DB.QueryRow(
        "SELECT id, email, password, user_data, created_at, guid FROM user WHERE id = ?",
        userID,
    ).Scan(&user.ID, &user.Email, &user.Password, &user.UserData, &user.CreatedAt, &user.Guid)

    if err != nil {
        http.Error(w, "Error scanning user", http.StatusInternalServerError)
        return
    }
    // user.UserData = userData

    // response := models.UserResponse{
    //     ID:        user.ID,
    //     Email:     user.Email,
    //     UserData:  user.UserData,
    //     CreatedAt: user.CreatedAt.Format(time.RFC3339),
    // }
    //  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMSwiZW1haWwiOiJyckByci5yciIsImlzcyI6ImdvLWFwaSIsInN1YiI6InJyQHJyLnJyIiwiZXhwIjoxNzY1NTMwNzg5LCJuYmYiOjE3NjU0NDQzODksImlhdCI6MTc2NTQ0NDM4OX0.TgUUXzVPUjagJHJRgSdMdstqUyb85-_xzj8SOaexBug

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(user)
    // writeResponse(w, http.StatusOK, response)
}

func CVHandler(w http.ResponseWriter, r *http.Request) {
    // Извлекаем из контекста
    var req models.CVRequest
    err := json.NewDecoder(r.Body).Decode(&req)
    if err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }


    var user models.User
    var userResult models.UserResult
    err = database.DB.QueryRow(
        "SELECT id, email, password, user_data, created_at, guid, result FROM user WHERE guid = ?",
        req.ID,
    ).Scan(&user.ID, &user.Email, &user.Password, &user.UserData, &user.CreatedAt, &user.Guid, &userResult)

    if err != nil {
        log.Printf("Error when scan: %v", err);
        http.Error(w, "Error scanning user", http.StatusInternalServerError)
        return
    }

    user.UserData["assign"] = userResult.Assign;
    user.UserData["comment"] = userResult.Comment;    

    writeResponse(w, http.StatusOK, Response{
        Success: true,
        Message: "CV get successful",
        Data:    user.UserData,
    })

}

func PasswordHandler(w http.ResponseWriter, r *http.Request, cfg *config.Config) {
    // Извлекаем из контекста
    userID, ok := middleware.GetUserIDFromContext(r.Context())
    if !ok {
        writeResponse(w, http.StatusInternalServerError, Response{
            Success: false,
            Error:   "Error when define user",
        })
        return
    }

    var req models.PasswordRequest
    err := json.NewDecoder(r.Body).Decode(&req)
    if err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    // Хешируем новый пароль
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.New), bcrypt.DefaultCost)
    if err != nil {
        http.Error(w, "Error processing new password", http.StatusInternalServerError)
        return
    }    

    log.Printf(" Change password for id=%d new hash=%s", userID, string(hashedPassword))

    var user models.User
    err = database.DB.QueryRow(
        "SELECT id, email, password, new_password, user_data, created_at FROM user WHERE id = ?",
        userID, 
    ).Scan(&user.ID, &user.Email, &user.Password, &user.NewPassword, &user.UserData, &user.CreatedAt)
    
    if err == sql.ErrNoRows {
        http.Error(w, "Invalid credentials", http.StatusUnauthorized)
        return
    } else if err != nil {
        http.Error(w, "Database error", http.StatusInternalServerError)
        return
    }

    // Проверяем пароль
    if !checkPassword(&user, req.Old) {
        http.Error(w, "Invalid old password", http.StatusUnauthorized)
        return
    }

    // Меняем пароль
    result, err := database.DB.Exec(
        "UPDATE user SET password = ?, new_password = '' WHERE id = ?",
        string(hashedPassword), userID, 
    )

    if err != nil {
        // Обработка ошибки SQL (например, сбой подключения, синтаксис и т.д.)
        http.Error(w, "Database error", http.StatusUnauthorized)
        return
    }

    rowsAffected, err := result.RowsAffected()
    if err != nil {
        // Ошибка при получении количества затронутых строк (редко, но возможно)
        http.Error(w, "Get updated rows error", http.StatusUnauthorized)
        return
    }

    if rowsAffected == 0 {
        // ❌ Ни одна строка не обновлена:
        http.Error(w, "User not found or old password is incorrect", http.StatusUnauthorized)
        return 
    }

    // Генерируем JWT токен
    token, err := middleware.GenerateJWTToken(user.ID, user.Email, cfg)
    if err != nil {
        writeResponse(w, http.StatusInternalServerError, Response{
            Success: false,
            Error:   "Error generating token",
        })
        return
    }

    authResponse := AuthResponse{
        Token: token,
    }

    writeResponse(w, http.StatusOK, Response{
        Success: true,
        Message: "Change password successful",
        Data:    authResponse,
    })
}

func SaveCVHandler(w http.ResponseWriter, r *http.Request, cfg *config.Config) {
    // Извлекаем из контекста
    userID, ok := middleware.GetUserIDFromContext(r.Context())
    if !ok {
        writeResponse(w, http.StatusInternalServerError, Response{
            Success: false,
            Error:   "Error when define user",
        })
        return
    }

    // проверяем есть ли такой юзер
    var exists bool
    err := database.DB.QueryRow(
        "SELECT EXISTS(SELECT 1 FROM user WHERE id = ?)",
        userID,
    ).Scan(&exists)

    if err != nil {
        log.Printf("Check user error: %v", err)
        http.Error(w, "Database error", http.StatusUnauthorized)
        return
    }

    if !exists {
        http.Error(w, "User not found", http.StatusNotFound)
        return
    }    

    var req models.UserData
    err = json.NewDecoder(r.Body).Decode(&req)
    if err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    // Меняем CV
    _, err = database.DB.Exec(
        "UPDATE user SET user_data = ? WHERE id = ?",
        req, userID, 
    )

    if err != nil {
        log.Printf("Update user error: %v", err)
        http.Error(w, "Database error", http.StatusInternalServerError)
        return
    }

    _, err = saveHints(database.DB, req)
    if err != nil {
        log.Printf("Error saving user CV to hint: %v", err)
        http.Error(w, "Failed to save hints", http.StatusInternalServerError)
        return
    }

    writeResponse(w, http.StatusOK, Response{
        Success: true,
        Message: "CV data saved",
    })

/*     authResponse := AuthResponse{
        Token: token,
    }

    writeResponse(w, http.StatusOK, Response{
        Success: true,
        Message: "Change password successful",
        Data:    authResponse,
    }) */
}

func SaveUserResultHandler(w http.ResponseWriter, r *http.Request, cfg *config.Config) {

    var req models.ResultRequest
    err := json.NewDecoder(r.Body).Decode(&req)
    if err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    var exists bool
    err = database.DB.QueryRow(
        "SELECT EXISTS(SELECT 1 FROM user WHERE guid = ?)",
        req.Guid,
    ).Scan(&exists)
    
    if err != nil {
        http.Error(w, "Database error", http.StatusInternalServerError)
        return
    }
    
    if !exists {
        http.Error(w, "User not found", http.StatusNotFound);
        return
    }
    
    userResult := models.UserResult{
        Assign:  req.Assign,
        Comment: req.Comment,
    }
    
    resultJSON, err := json.Marshal(userResult)
    if err != nil {
        http.Error(w, "Error when parse result", http.StatusInternalServerError)
        return
    }

    _, err = database.DB.Exec(
        "UPDATE user SET result = ? WHERE guid = ?",
        resultJSON, req.Guid,
    )

    if err != nil {
        log.Printf("Error: %v", err)
        http.Error(w, " Database error", http.StatusInternalServerError);
        return
    }

    writeResponse(w, http.StatusOK, Response{
        Success: true,
        Message: "Result saved",
    })
}

/*
func updateUser(db *sql.DB, userData models.UserData) (int, error) {
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
*/

func GetUsersHandler(w http.ResponseWriter, r *http.Request, cfg *config.Config) {
    userID, ok := middleware.GetUserIDFromContext(r.Context())
    if !ok {
        writeResponse(w, http.StatusInternalServerError, Response{
            Success: false,
            Error:   "Error when define admin",
        })
        return
    }

    var exists bool
    err := database.DB.QueryRow(
        "SELECT EXISTS(SELECT 1 FROM user WHERE id = ? and is_hr = 1)",
        userID,
    ).Scan(&exists)

    if err != nil {
        log.Printf("Check admin error: %v", err)
        http.Error(w, "Database error", http.StatusInternalServerError)
        return
    }

    if !exists {
        http.Error(w, "Admin not found", http.StatusNotFound)
        return
    }

    var req models.UserGridRequest
    err = json.NewDecoder(r.Body).Decode(&req)
    if err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    page := req.Page
    if page < 1 { page = 1 }
    limit := req.Limit
    if limit < 1 { limit = 10 }

    sortBy := req.SortBy
    sortOrder := req.SortOrder
    search := req.Search

    allowedSorts := map[string]bool{
        "fio_virtual": true, 
        "position_virtual": true, 
        "sector_virtual": true, 
        "created_at": true,
    }
    sortCol := "created_at"
    if allowedSorts[sortBy] { 
        sortCol = sortBy 
    }
    if sortOrder != "desc" { 
        sortOrder = "asc" 
    }

    offset := (page - 1) * limit

    baseQuery := `
        FROM user u
        WHERE 1 = 1
    `

    args := []interface{}{}

    if search != "" {
        baseQuery += " AND (u.fio_virtual LIKE ? OR u.position_virtual LIKE ? OR u.sector_virtual LIKE ?)"
        searchParam := "%" + search + "%"
        args = append(args, searchParam, searchParam, searchParam)
    }

    if req.New == 1 {
        baseQuery += ` AND NOT EXISTS (
            SELECT 1 FROM process p 
            WHERE p.hr_id = ? AND p.user_id = u.id
        )`
        args = append(args, userID)
    }

    queryCount := "SELECT COUNT(*) " + baseQuery

    queryData := fmt.Sprintf(`
        SELECT u.id, 
            JSON_UNQUOTE(JSON_EXTRACT(u.user_data, '$.fio')) as fio, 
            JSON_UNQUOTE(JSON_EXTRACT(u.user_data, '$.position')) as position, 
            JSON_UNQUOTE(JSON_EXTRACT(u.user_data, '$.sector')) as sector 
        %s
    `, baseQuery)

    var total int
    database.DB.QueryRow(queryCount, args...).Scan(&total)

    queryData += fmt.Sprintf(" ORDER BY %s %s LIMIT ? OFFSET ?", sortCol, sortOrder)
    args = append(args, limit, offset)

    rows, err := database.DB.Query(queryData, args...); 
    
    if err != nil {
        log.Printf(" --- error %v in sql: %s", err, queryData)
        http.Error(w, "Database user selection error", http.StatusInternalServerError)
        return
    }

    defer rows.Close()

    items := make([]models.UserGridItem, 0, limit)

    for rows.Next() {
        var item models.UserGridItem
        var fio, position, sector sql.NullString // Используем NullString для безопасной работы с NULL из JSON

        // Сканируем колонки в том же порядке, что и в SELECT
        // id, fio, position, sector
        err := rows.Scan(&item.ID, &fio, &position, &sector)
        if err != nil {
            log.Printf("Error scanning row: %v", err)
            continue // Пропускаем битую строку или возвращаем ошибку, в зависимости от требований
        }

        // Обрабатываем NULL значения (если ключа в JSON нет, MySQL вернет NULL)
        item.Fio = fio.String
        item.Position = position.String
        item.Sector = sector.String

        items = append(items, item)
    }

    if err := rows.Err(); err != nil {
        http.Error(w, "Database iteration error", http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(models.UserGridResponse{Data: items, Total: total})
}

func writeResponse(w http.ResponseWriter, status int, response Response) {
    w.Header().Set("Content-Type", "application/json; charset=utf-8")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(response)
}

func mergeJSONData(base, extra []byte) ([]byte, error) {
    var baseMap map[string]interface{}
    var extraMap map[string]interface{}
    
    // Парсим оба JSON
    if err := json.Unmarshal(base, &baseMap); err != nil {
        return nil, err
    }
    if err := json.Unmarshal(extra, &extraMap); err != nil {
        return nil, err
    }
    
    // Сливаем (extra перезаписывает base)
    for k, v := range extraMap {
        baseMap[k] = v
    }
    
    // Возвращаем обратно в JSON
    return json.Marshal(baseMap)
}

func checkPassword(user *models.User, password string) bool {
    // Проверяем основной пароль
    err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password))
    if err == nil {
        return true
    }
    
    // Если есть NewPassword, проверяем его
    if user.NewPassword != "" {
        err = bcrypt.CompareHashAndPassword([]byte(user.NewPassword), []byte(password))
        return err == nil
    }
    
    return false
}

// GenerateRandomBytes генерирует случайные байты
func GenerateRandomBytes(n int) ([]byte, error) {
    b := make([]byte, n)
    _, err := rand.Read(b)
    if err != nil {
        return nil, err
    }
    return b, nil
}

// GeneratePasswordBase64 генерирует пароль в base64
func GeneratePasswordBase64(length int) (string, error) {
    // Для base64 нужно больше байт, так как каждый символ кодирует 6 бит
    bytesNeeded := (length * 3) / 4
    if bytesNeeded < 1 {
        bytesNeeded = 1
    }
    
    bytes, err := GenerateRandomBytes(bytesNeeded)
    if err != nil {
        return "", err
    }
    
    // Кодируем в base64 без символов = (padding)
    password := base64.RawURLEncoding.EncodeToString(bytes)
    
    // Обрезаем до нужной длины
    if len(password) > length {
        password = password[:length]
    }
    
    return password, nil
}