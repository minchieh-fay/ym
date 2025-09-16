package main

import (
	"log"
	"ym-backend/internal/config"
	"ym-backend/internal/handler"
	"ym-backend/pkg/database"
)

func main() {
	// 加载配置
	cfg := config.Load()

	// 初始化数据库
	db, err := database.Init(cfg.Database)
	if err != nil {
		log.Fatal("Failed to initialize database:", err)
	}

	// 初始化路由
	router := handler.SetupRoutes(db)

	// 启动服务器
	log.Printf("Server starting on port %s", cfg.Server.Port)
	if err := router.Run(":" + cfg.Server.Port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
