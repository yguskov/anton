package main

import (
    "fmt"
    "log"
    "net/http"
    "encoding/json"	
	"os"
    "os/signal"
    "syscall"

    "go-api/config"
    "go-api/database"
    "go-api/handlers"
	"go-api/middleware"	
    
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

    // Инициализируем базу данных
    log.Println("🔄 Connecting to database...")
    if err := database.InitDB(dsn); err != nil {
        log.Fatalf("❌ Database connection failed: %v", err)
    }
    defer database.CloseDB()

    // Настраиваем роутер
    router := mux.NewRouter()
    
    // Middleware для логирования
    router.Use(loggingMiddleware)
    
    // API routes - публичные
    public := router.PathPrefix("/api").Subrouter()
    public.HandleFunc("/register", func(w http.ResponseWriter, r *http.Request) {
        handlers.RegisterHandler(w, r, cfg)
    }).Methods("POST")
    public.HandleFunc("/login", func(w http.ResponseWriter, r *http.Request) {
        handlers.LoginHandler(w, r, cfg)
    }).Methods("POST")

	public.HandleFunc("/health", healthHandler).Methods("GET")


    // Защищенные routes - требуют аутентификации
    protected := router.PathPrefix("/api").Subrouter()
    protected.Use(middleware.AuthMiddleware(cfg))
    protected.HandleFunc("/users", handlers.GetUsersHandler).Methods("GET")
    // protected.HandleFunc("/profile", handlers.GetProfileHandler).Methods("GET")	
    
    // Настраиваем CORS для Flutter Web
    c := cors.New(cors.Options{
        AllowedOrigins:   []string{"http://localhost:8080", "http://localhost:*"},
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
    server := &http.Server{
        Addr:    ":" + port,
        Handler: handler,
    }	

    // Graceful shutdown
    go gracefulShutdown(server)	
    
    log.Printf("🚀 Server starting on http://localhost:%s", port)
    log.Printf("🔐 JWT Secret: %s***", cfg.JWT.SecretKey[:10])
    log.Printf("📊 API endpoints:")
    log.Printf("   POST http://localhost:%s/api/register (public)", port)
    log.Printf("   POST http://localhost:%s/api/login (public)", port)
    log.Printf("   GET  http://localhost:%s/api/users (protected)", port)
    log.Printf("   GET  http://localhost:%s/api/profile (protected)", port)
    log.Printf("   GET  http://localhost:%s/api/health (public)", port)
    
    if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
        log.Fatalf("❌ Server failed to start: %v", err)
    }
    // log.Fatal(http.ListenAndServe(":"+port, handler))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    // Проверяем соединение с базой данных
    if err := database.DB.Ping(); err != nil {
        http.Error(w, `{"status":"error","message":"Database connection failed"}`, http.StatusServiceUnavailable)
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]string{
        "status":  "ok",
        "message": "Server is healthy",
    })
}

func loggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        log.Printf("%s %s %s", r.Method, r.RequestURI, r.RemoteAddr)
        next.ServeHTTP(w, r)
    })
}

func gracefulShutdown(server *http.Server) {
    stop := make(chan os.Signal, 1)
    signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
    
    <-stop
    log.Println("🔄 Shutting down server gracefully...")
    
    if err := database.CloseDB(); err != nil {
        log.Printf("❌ Error closing database: %v", err)
    }
    
    log.Println("✅ Server shutdown complete")
    os.Exit(0)
}