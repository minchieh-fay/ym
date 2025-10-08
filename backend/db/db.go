package db

import (
	"fmt"
	"log"
	"time"
	"ym/define"
	"ym/model"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// Db 数据库连接管理器
type Db struct {
	DB *gorm.DB
}

// NewDb 创建数据库实例
func NewDb() *Db {
	return &Db{}
}

// createDatabaseIfNotExists 创建数据库（如果不存在）
func (d *Db) createDatabaseIfNotExists() error {
	// 连接到默认的postgres数据库来创建目标数据库
	defaultDSN := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=postgres sslmode=%s",
		define.DB_HOST, define.DB_PORT, define.DB_USER, define.DB_PASSWORD, define.DB_SSLMODE)

	// 使用默认数据库连接
	db, err := gorm.Open(postgres.Open(defaultDSN), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent), // 静默模式，避免创建数据库时的日志干扰
	})
	if err != nil {
		return fmt.Errorf("failed to connect to default database: %w", err)
	}
	defer func() {
		if sqlDB, err := db.DB(); err == nil {
			sqlDB.Close()
		}
	}()

	// 检查数据库是否存在
	var exists bool
	err = db.Raw("SELECT EXISTS(SELECT datname FROM pg_catalog.pg_database WHERE datname = ?)", define.DB_NAME).Scan(&exists).Error
	if err != nil {
		return fmt.Errorf("failed to check if database exists: %w", err)
	}

	// 如果数据库不存在，则创建它
	if !exists {
		log.Printf("Database '%s' does not exist, creating it...", define.DB_NAME)

		// 创建数据库
		err = db.Exec(fmt.Sprintf("CREATE DATABASE %s", define.DB_NAME)).Error
		if err != nil {
			return fmt.Errorf("failed to create database '%s': %w", define.DB_NAME, err)
		}

		log.Printf("Database '%s' created successfully", define.DB_NAME)
	} else {
		log.Printf("Database '%s' already exists", define.DB_NAME)
	}

	return nil
}

// Init 初始化数据库连接
func (d *Db) Init() error {
	// 首先尝试创建数据库（如果不存在）
	if err := d.createDatabaseIfNotExists(); err != nil {
		return fmt.Errorf("failed to create database: %w", err)
	}

	// 构建数据库连接字符串
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		define.DB_HOST, define.DB_PORT, define.DB_USER, define.DB_PASSWORD, define.DB_NAME, define.DB_SSLMODE)

	// 配置GORM
	config := &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
		NowFunc: func() time.Time {
			return time.Now().Local()
		},
	}

	// 连接数据库
	db, err := gorm.Open(postgres.Open(dsn), config)
	if err != nil {
		return fmt.Errorf("failed to connect database: %w", err)
	}

	// 配置连接池
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("failed to get underlying sql.DB: %w", err)
	}

	// 设置连接池参数
	sqlDB.SetMaxIdleConns(10)           // 最大空闲连接数
	sqlDB.SetMaxOpenConns(100)          // 最大打开连接数
	sqlDB.SetConnMaxLifetime(time.Hour) // 连接最大生存时间

	// 测试连接
	if err := sqlDB.Ping(); err != nil {
		return fmt.Errorf("failed to ping database: %w", err)
	}

	d.DB = db
	log.Println("Database connected successfully")

	// 自动迁移表结构
	if err := d.autoMigrate(); err != nil {
		return fmt.Errorf("failed to migrate database: %w", err)
	}

	return nil
}

// autoMigrate 自动迁移数据库表结构
func (d *Db) autoMigrate() error {
	// 迁移用户表
	if err := d.DB.AutoMigrate(&model.User{}); err != nil {
		return fmt.Errorf("failed to migrate user table: %w", err)
	}

	log.Println("Database migration completed")
	return nil
}

// GetDB 获取数据库连接实例
func (d *Db) GetDB() *gorm.DB {
	return d.DB
}

// Close 关闭数据库连接
func (d *Db) Close() error {
	if d.DB != nil {
		sqlDB, err := d.DB.DB()
		if err != nil {
			return fmt.Errorf("failed to get underlying sql.DB: %w", err)
		}
		return sqlDB.Close()
	}
	return nil
}

// Health 检查数据库健康状态
func (d *Db) Health() error {
	if d.DB == nil {
		return fmt.Errorf("database not initialized")
	}

	sqlDB, err := d.DB.DB()
	if err != nil {
		return fmt.Errorf("failed to get underlying sql.DB: %w", err)
	}

	return sqlDB.Ping()
}
