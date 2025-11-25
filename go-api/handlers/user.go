package handlers

import (
    "database/sql"
    "encoding/json"
    "net/http"
    "go-api/database"
    "go-api/models"
    
    "golang.org/x/crypto/bcrypt"
)

func RegisterHandler(w http.ResponseWriter, r *http.Request) {
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
        "INSERT INTO user (email, password, user_data) VALUES (?, ?, ?)",
        req.Email, 
        string(hashedPassword), 
        req.UserData,
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
        "SELECT id, email, user_data, created_at FROM user WHERE id = ?",
        userID,
    ).Scan(&user.ID, &user.Email, &user.UserData, &user.CreatedAt)
    if err != nil {
        http.Error(w, "Error retrieving user", http.StatusInternalServerError)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(user)
}

func LoginHandler(w http.ResponseWriter, r *http.Request) {
    var req models.LoginRequest
    err := json.NewDecoder(r.Body).Decode(&req)
    if err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    var user models.User
    err = database.DB.QueryRow(
        "SELECT id, email, password, user_data, created_at FROM user WHERE email = ?",
        req.Email,
    ).Scan(&user.ID, &user.Email, &user.Password, &user.UserData, &user.CreatedAt)
    
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

    response := models.UserResponse{
        ID:        user.ID,
        Email:     user.Email,
        UserData:  user.UserData,
        CreatedAt: user.CreatedAt.Format("2006-01-02 15:04:05"),
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
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