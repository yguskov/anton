package main

import (
    "fmt"
    "log"
    "net/http"
    "go-api/config"
    "go-api/database"
    "go-api/handlers"
    
    "github.com/gorilla/mux"
    "github.com/rs/cors"
)

func main() {
    // Загружаем конфигурацию
    cfg, err := config.LoadConfig("config.json")
    if err != nil {
        log.Fatal("Error loading config:", err)
    }

    // Подключаемся к БД
    dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true",
        cfg.Database.User,
        cfg.Database.Password,
        cfg.Database.Host,
        cfg.Database.Port,
        cfg.Database.Name,
    )
    
    err = database.InitDB(dsn)
    if err != nil {
        log.Fatal("Error connecting to database:", err)
    }

    // Настраиваем роутер
    router := mux.NewRouter()
    
    // API routes
    router.HandleFunc("/api/register", handlers.RegisterHandler).Methods("POST")
    router.HandleFunc("/api/login", handlers.LoginHandler).Methods("POST")
    router.HandleFunc("/api/users", handlers.GetUsersHandler).Methods("GET")
    
    // Настраиваем CORS для Flutter Web
    c := cors.New(cors.Options{
        AllowedOrigins:   []string{"http://localhost:3000", "https://yourdomain.com"},
        AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
        AllowedHeaders:   []string{"*"},
        AllowCredentials: true,
    })

    handler := c.Handler(router)
    
    // Запускаем сервер
    port := cfg.Server.Port
    if port == "" {
        port = "8080"
    }
    
    log.Printf("Server starting on port %s", port)
    log.Fatal(http.ListenAndServe(":"+port, handler))
}