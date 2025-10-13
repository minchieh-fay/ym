package main

import (
	"fmt"
	"log"
	"ym/db"
	"ym/model"
)

// 这个文件展示了如何使用优化后的数据库
func main() {
	// 创建数据库实例
	database := db.NewDb()

	// 初始化数据库连接
	if err := database.Init(); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.Close()

	// 获取GORM实例
	gormDB := database.GetDB()

	// 创建用户示例
	user := &model.User{
		Username: "testuser",
		Email:    "test@example.com",
		Password: "hashedpassword",
		Nickname: "测试用户",
		Status:   1,
		IsActive: true,
	}

	// 创建用户
	if err := gormDB.Create(user).Error; err != nil {
		log.Printf("Failed to create user: %v", err)
	} else {
		fmt.Printf("User created successfully with ID: %d\n", user.ID)
	}

	// 查询用户
	var foundUser model.User
	if err := gormDB.Where("username = ?", "testuser").First(&foundUser).Error; err != nil {
		log.Printf("Failed to find user: %v", err)
	} else {
		fmt.Printf("Found user: %+v\n", foundUser)
	}

	// 更新用户
	if err := gormDB.Model(&foundUser).Update("nickname", "更新后的昵称").Error; err != nil {
		log.Printf("Failed to update user: %v", err)
	} else {
		fmt.Println("User updated successfully")
	}

	// 检查数据库健康状态
	if err := database.Health(); err != nil {
		log.Printf("Database health check failed: %v", err)
	} else {
		fmt.Println("Database is healthy")
	}
}
