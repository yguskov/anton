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
        "SELECT id, email, password, user_data, created_at, guid FROM user WHERE email = ?",
        req.Email,
    ).Scan(&user.ID, &user.Email, &user.Password, &user.UserData, &user.CreatedAt, &user.Guid)
    
    if err == sql.ErrNoRows {
        http.Error(w, "Invalid credentials", http.StatusUnauthorized)
        return
    } else if err != nil {
        http.Error(w, "Database error", http.StatusInternalServerError)
        return
    }

    // Проверяем пароль
    err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password))
    if err != nil {
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
    err = database.DB.QueryRow(
        "SELECT id, email, password, user_data, created_at, guid FROM user WHERE guid = ?",
        req.ID,
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

    // Хешируем старый пароль
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.New), bcrypt.DefaultCost)
    if err != nil {
        http.Error(w, "Error processing new password", http.StatusInternalServerError)
        return
    }    

    log.Printf(" Change password for id=%d new hash=%s", userID, string(hashedPassword))

    var user models.User
    err = database.DB.QueryRow(
        "SELECT id, email, password, user_data, created_at FROM user WHERE id = ?",
        userID, 
    ).Scan(&user.ID, &user.Email, &user.Password, &user.UserData, &user.CreatedAt)
    
    if err == sql.ErrNoRows {
        http.Error(w, "Invalid credentials", http.StatusUnauthorized)
        return
    } else if err != nil {
        http.Error(w, "Database error", http.StatusInternalServerError)
        return
    }

    // Проверяем пароль
    err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Old))
    if err != nil {
        http.Error(w, "Invalid old password", http.StatusUnauthorized)
        return
    }

    // Меняем пароль
    result, err := database.DB.Exec(
        "UPDATE user SET password = ? WHERE id = ?",
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
        http.Error(w, "Database error", http.StatusInternalServerError)
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
        // Обработка ошибки SQL (например, сбой подключения, синтаксис и т.д.)
        http.Error(w, "Database error", http.StatusUnauthorized)
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

func GetUsersHandler(w http.ResponseWriter, r *http.Request, cfg *config.Config) {
    // Извлекаем из контекста
    userID, ok := middleware.GetUserIDFromContext(r.Context())
    if !ok {
        writeResponse(w, http.StatusInternalServerError, Response{
            Success: false,
            Error:   "Error when define admin",
        })
        return
    }

    // проверяем есть ли такой юзер
    var exists bool
    err := database.DB.QueryRow(
        "SELECT EXISTS(SELECT 1 FROM user WHERE id = ?)", // @todo filter with role admin
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

    // page, _ := strconv.Atoi(r.URL.Query().Get("page"))     // default 1
    // limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))   // default 20
    // page, _ := strconv.Atoi("1")     // default 1
    page  := req.Page                  // default 1
    limit := req.Limit                // default 20
    sortBy := req.SortBy             // fio, position, sector
    sortOrder := req.SortOrder      // asc, desc
    search := req.Search           // текст поиска

    // Валидация sortBy (защита от SQL инъекций)
    allowedSorts := map[string]bool{"fio_virtual": true, "position_virtual": true, "sector_virtual": true, "created_at": true}
    sortCol := "created_at"
    if allowedSorts[sortBy] { sortCol = sortBy }
    if sortOrder != "desc" { sortOrder = "asc" }

    offset := (page - 1) * limit

    // 2. Построение запроса
    // Используем подготовленные выражения для search, но сортировку вставляем аккуратно
    queryCount := "SELECT COUNT(*) FROM user"
    // queryData := "SELECT id, user_data->>'$.fio' as fio, user_data->>'$.position' as position, user_data->>'$.sector' as sector FROM user"
    queryData := "SELECT id, JSON_UNQUOTE(JSON_EXTRACT(user_data, '$.fio')) as fio, JSON_UNQUOTE(JSON_EXTRACT(user_data, '$.position')) as position, JSON_UNQUOTE(JSON_EXTRACT(user_data, '$.sector')) as sector FROM user"
    
    args := []interface{}{}
    whereClause := ""

    if search != "" {
        whereClause = " WHERE (fio_virtual LIKE ? OR position_virtual LIKE ? OR sector_virtual LIKE ?)"
        searchParam := "%" + search + "%"
        args = append(args, searchParam, searchParam, searchParam)
    }

    // Получаем общее количество
    var total int
    database.DB.QueryRow(queryCount + whereClause, args...).Scan(&total)

    // Получаем данные страницы
    queryData += whereClause + fmt.Sprintf(" ORDER BY %s %s LIMIT ? OFFSET ?", sortCol, sortOrder)
    args = append(args, limit, offset)

    rows, err := database.DB.Query(queryData, args...); 
    
    if err != nil {
        log.Printf(" --- error %v in sql: %s", err, queryData)
        http.Error(w, "Database user selection error", http.StatusInternalServerError)
        return
    }

    defer rows.Close() // Обязательно закрываем rows, чтобы не утекали соединения

    items := make([]models.UserGridItem, 0, limit) // Предварительное выделение памяти

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

    // Проверяем ошибки итерации (например, обрыв соединения во время чтения)
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


