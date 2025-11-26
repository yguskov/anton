package middleware

import (
    "context"
    "net/http"
    "strings"
    "go-api/config"
    "time"	
    "github.com/golang-jwt/jwt/v4"
)

type contextKey string

const (
    UserIDKey contextKey = "userID"
    EmailKey  contextKey = "email"
)

// JWTClaims представляет кастомные claims для JWT токена
type JWTClaims struct {
    UserID int    `json:"user_id"`
    Email  string `json:"email"`
    jwt.RegisteredClaims
}

// GenerateJWTToken создает новый JWT токен
func GenerateJWTToken(userID int, email string, cfg *config.Config) (string, error) {
    expirationTime := jwt.NewNumericDate(jwt.TimeFunc().Add(time.Duration(cfg.JWT.ExpiryHours) * time.Hour))
    
    claims := &JWTClaims{
        UserID: userID,
        Email:  email,
        RegisteredClaims: jwt.RegisteredClaims{
            ExpiresAt: expirationTime,
            IssuedAt:  jwt.NewNumericDate(jwt.TimeFunc()),
            NotBefore: jwt.NewNumericDate(jwt.TimeFunc()),
            Issuer:    "go-api",
            Subject:   email,
        },
    }
    
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString([]byte(cfg.JWT.SecretKey))
}

// AuthMiddleware проверяет JWT токен и добавляет userID в контекст
func AuthMiddleware(cfg *config.Config) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            // Пропускаем публичные endpoints
            if isPublicEndpoint(r.URL.Path) {
                next.ServeHTTP(w, r)
                return
            }

            authHeader := r.Header.Get("Authorization")
            if authHeader == "" {
                http.Error(w, `{"success":false,"error":"Authorization header required"}`, http.StatusUnauthorized)
                return
            }

            // Проверяем формат "Bearer {token}"
            parts := strings.Split(authHeader, " ")
            if len(parts) != 2 || parts[0] != "Bearer" {
                http.Error(w, `{"success":false,"error":"Invalid authorization format"}`, http.StatusUnauthorized)
                return
            }

            tokenString := parts[1]
            claims, err := validateToken(tokenString, cfg.JWT.SecretKey)
            if err != nil {
                http.Error(w, `{"success":false,"error":"Invalid token: `+err.Error()+`"}`, http.StatusUnauthorized)
                return
            }

            // Добавляем данные пользователя в контекст
            ctx := context.WithValue(r.Context(), UserIDKey, claims.UserID)
            ctx = context.WithValue(ctx, EmailKey, claims.Email)
            
            next.ServeHTTP(w, r.WithContext(ctx))
        })
    }
}

// validateToken проверяет JWT токен и возвращает claims
func validateToken(tokenString, secretKey string) (*JWTClaims, error) {
    claims := &JWTClaims{}
    
    token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
        // Проверяем алгоритм подписи
        if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
            return nil, jwt.ErrSignatureInvalid
        }
        return []byte(secretKey), nil
    })
    
    if err != nil {
        return nil, err
    }
    
    if !token.Valid {
        return nil, jwt.ErrSignatureInvalid
    }


    // Дополнительные кастомные проверки
    if claims.UserID == 0 {
        return nil, fmt.Errorf("invalid user ID in token")
    }
    
    if claims.Email == "" {
        return nil, fmt.Errorf("invalid email in token")
    }	
    
    return claims, nil
}

// isPublicEndpoint проверяет, является ли endpoint публичным
func isPublicEndpoint(path string) bool {
    publicEndpoints := []string{
        "/api/register",
        "/api/login", 
        "/api/health",
    }
    
    for _, endpoint := range publicEndpoints {
        if path == endpoint {
            return true
        }
    }
    return false
}

// GetUserIDFromContext извлекает userID из контекста
func GetUserIDFromContext(ctx context.Context) (int, bool) {
    userID, ok := ctx.Value(UserIDKey).(int)
    return userID, ok
}

// GetEmailFromContext извлекает email из контекста
func GetEmailFromContext(ctx context.Context) (string, bool) {
    email, ok := ctx.Value(EmailKey).(string)
    return email, ok
}