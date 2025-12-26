package models

import (
    "database/sql/driver"
    "encoding/json"
    "errors"
    "time"
)

type User struct {
    ID        int            `json:"id"`
    Email     string         `json:"email"`
    Password  string         `json:"-"`
    UserData  UserData       `json:"user_data"`
    CreatedAt time.Time      `json:"created_at"`
    UpdatedAt time.Time      `json:"updated_at"`
    Guid      string         `json:"guid"`
}

type UserData map[string]interface{}

// Value преобразует UserData в JSON для хранения в БД
func (ud UserData) Value() (driver.Value, error) {
    return json.Marshal(ud)
}

// Scan преобразует JSON из БД в UserData
func (ud *UserData) Scan(value interface{}) error {
    if value == nil {
        *ud = UserData{}
        return nil
    }
    
    bytes, ok := value.([]byte)
    if !ok {
        return errors.New("type assertion to []byte failed")
    }
    
    return json.Unmarshal(bytes, ud)
}

type RegisterRequest struct {
    Email    string   `json:"email"`
    Password string   `json:"password"`
    UserData UserData `json:"user_data"`
}

type LoginRequest struct {
    Email    string `json:"email"`
    Password string `json:"password"`
}

type PasswordRequest struct {
    Old    string `json:"old"`
    New    string `json:"new"`
}

type CVRequest struct {
    ID string `json:"id"`
}

type UserResponse struct {
    ID        int      `json:"id"`
    Email     string   `json:"email"`
    UserData  UserData `json:"user_data"`
    CreatedAt string   `json:"created_at"`
    Guid      string   `json:"guid"`
}