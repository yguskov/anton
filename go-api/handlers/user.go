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

func GetUsersHandler(w http.ResponseWriter, r *http.Request) {
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
    var userData models.UserData
    err := database.DB.QueryRow(
        "SELECT id, email, password, user_data, created_at, guid FROM user WHERE id = ?",
        userID,
    ).Scan(&user.ID, &user.Email, &user.Password, &user.UserData, &user.CreatedAt, &user.Guid)

    if err != nil {
        http.Error(w, "Error scanning user", http.StatusInternalServerError)
        return
    }
    user.UserData = userData

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

func writeResponse(w http.ResponseWriter, status int, response Response) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(response)
}