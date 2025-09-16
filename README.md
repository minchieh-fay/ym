# YM 项目

## 项目结构

```
ym/
├── doc/                    # 工程文档/需求文档
├── backend/               # Go后端服务
│   ├── cmd/              # 应用程序入口
│   ├── internal/         # 内部包
│   │   ├── handler/      # HTTP处理器
│   │   ├── service/      # 业务逻辑层
│   │   ├── model/        # 数据模型
│   │   ├── config/       # 配置管理
│   │   └── middleware/   # 中间件
│   ├── pkg/              # 公共包
│   │   ├── utils/        # 工具函数
│   │   └── database/     # 数据库相关
│   ├── api/              # API定义
│   │   └── v1/           # API版本1
│   ├── scripts/          # 脚本文件
│   ├── deployments/      # 部署配置
│   └── go.mod           # Go模块文件
├── frontend/             # UniApp小程序前端
│   ├── src/             # 源代码
│   │   ├── pages/       # 页面
│   │   ├── components/  # 组件
│   │   ├── utils/       # 工具函数
│   │   ├── api/         # API接口
│   │   └── store/       # 状态管理
│   ├── static/          # 静态资源
│   ├── unpackage/       # 打包输出
│   ├── manifest.json    # 应用配置
│   ├── pages.json       # 页面配置
│   └── package.json     # 依赖配置
└── README.md            # 项目说明
```

## 技术栈

### 后端
- **语言**: Go 1.21+
- **框架**: Gin
- **数据库**: MySQL + GORM
- **认证**: JWT
- **配置**: Viper

### 前端
- **框架**: UniApp
- **语言**: Vue 3 + TypeScript
- **平台**: 微信小程序、抖音小程序

## 开发环境

### 后端开发
```bash
cd backend
go mod tidy
go run cmd/main.go
```

### 前端开发
```bash
cd frontend
npm install
npm run dev:mp-weixin    # 微信小程序开发
npm run dev:mp-toutiao   # 抖音小程序开发
```

## 部署

### 后端部署
```bash
cd backend
go build -o bin/server cmd/main.go
./bin/server
```

### 前端部署
```bash
cd frontend
npm run build:mp-weixin    # 构建微信小程序
npm run build:mp-toutiao   # 构建抖音小程序
```

## 文档

详细文档请查看 `doc/` 目录下的相关文档。