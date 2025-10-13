package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"ym/db"
	"ym/define"
	"ym/http"

	"github.com/gin-gonic/gin"
)

func main() {
	// 加载配置
	fmt.Println("Start server ", define.PORT, define.VERSION)

	// 初始化数据库
	database := db.NewDb()
	if err := database.Init(); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer func() {
		if err := database.Close(); err != nil {
			log.Printf("Error closing database: %v", err)
		}
	}()

	// 设置Gin模式
	gin.SetMode(gin.ReleaseMode)

	// 启动Web服务
	go func() {
		http.WebServer(gin.Default())
	}()

	// 等待中断信号
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")
}
