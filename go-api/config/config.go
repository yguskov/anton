package config

import (
    "encoding/json"
    "os"
    // "strconv"
    // "time"	
)

type Config struct {
    Database struct {
        Host     string `json:"host"`
        Port     string `json:"port"`
        User     string `json:"user"`
        Password string `json:"password"`
        Name     string `json:"name"`
    } `json:"database"`
    Server struct {
        Port string `json:"port"`
    } `json:"server"`
	JWT struct {
        SecretKey   string
        ExpiryHours int
    }	
}

func LoadConfig(path string) (*Config, error) {
    file, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    defer file.Close()

    config := &Config{}
    decoder := json.NewDecoder(file)
    err = decoder.Decode(config)
    return config, err
}