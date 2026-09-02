package handlers

import (
    // "database/sql"
    "encoding/json"
    "net/http"
    "go-api/config"
    "go-api/database"
	"regexp"    
    // "strconv"
)

type ManagerRequest struct {
    Email    string `json:"email"`
    Password string `json:"password"`
}

func ManagerHandler(w http.ResponseWriter, r *http.Request, cfg *config.Config) {
    var req ManagerRequest
    err := json.NewDecoder(r.Body).Decode(&req)
    if err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    // Проверяем обязательные поля
    if req.Email == "" {
        http.Error(w, "Email are required", http.StatusBadRequest)
        return
    }
    
    // Проверяем формат
    if !isValidEmail(req.Email) {
        writeResponse(w, http.StatusCreated, Response{
            Success: false,
            Message: "Неверный формат",
        })

        // http.Error(w, "Invalid email", http.StatusBadRequest)
        return
    }    

    // Сохраняем пользователя в БД
    _, err = database.DB.Exec(
        "INSERT INTO manager (email) VALUES (?)",
        req.Email, 
    )
    if err != nil {
        writeResponse(w, http.StatusCreated, Response{
            Success: true,
            Message: "Вы подписаны",
        })

        // http.Error(w, "Error creating manager: "+err.Error(), http.StatusInternalServerError)
        return
    }

    writeResponse(w, http.StatusCreated, Response{
        Success: true,
        Message: "Вы подписаны",
    })

    // w.Header().Set("Content-Type", "application/json")
    // w.WriteHeader(http.StatusCreated)
    // json.NewEncoder(w).Encode(user)
}

func isValidEmail(email string) bool {
	// Простой шаблон: буквы/цифры/точки/плюс/дефис + @ + домен
	re := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	return re.MatchString(email)
}