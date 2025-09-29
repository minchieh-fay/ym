# UniApp项目运行说明

## 🚨 当前问题

由于UniApp的CLI工具和依赖版本兼容性问题，直接使用npm运行遇到了以下问题：

1. **依赖版本冲突**：@dcloudio/vite-plugin-uni与@vitejs/plugin-vue版本不兼容
2. **缺少文件**：entry-server.js文件缺失
3. **CLI工具问题**：uni命令无法找到

## 💡 推荐解决方案

### 方案1：使用HBuilderX（推荐）

1. **下载HBuilderX**
   - 访问：https://www.dcloud.io/hbuilderx.html
   - 下载HBuilderX X版本

2. **创建UniApp项目**
   - 打开HBuilderX
   - 文件 → 新建 → 项目
   - 选择"uni-app" → "默认模板"
   - 项目名称：ym-miniprogram

3. **导入现有代码**
   - 将我们创建的Vue文件复制到新项目中
   - 替换默认的页面文件

### 方案2：使用Vue CLI创建UniApp项目

```bash
# 全局安装@vue/cli
npm install -g @vue/cli

# 创建uni-app项目
vue create -p dcloudio/uni-preset-vue ym-miniprogram

# 进入项目目录
cd ym-miniprogram

# 安装依赖
npm install
```

### 方案3：使用HTML演示版本（当前可用）

我已经创建了一个完整的HTML演示版本 `demo.html`，包含了所有登录功能：

- ✅ 手机号验证码登录
- ✅ 微信一键登录
- ✅ 兴趣标签选择
- ✅ 用户信息管理
- ✅ 响应式设计

**运行方式：**
```bash
# 在浏览器中打开
open demo.html
# 或者
python -m http.server 8000
# 然后访问 http://localhost:8000/demo.html
```

## 📁 项目文件结构

```
frontend/
├── src/
│   ├── pages/
│   │   ├── index/
│   │   │   └── index.vue          # 首页
│   │   └── login/
│   │       └── login.vue          # 登录页
│   ├── store/
│   │   ├── index.ts               # Store入口
│   │   └── user.ts                # 用户状态管理
│   ├── api/
│   │   └── auth.ts                # 认证API
│   ├── utils/
│   │   └── request.ts             # 网络请求工具
│   ├── manifest.json              # 应用配置
│   └── pages.json                 # 页面配置
├── demo.html                      # HTML演示版本
├── package.json                   # 依赖配置
└── vite.config.js                 # Vite配置
```

## 🎯 功能特性

### 登录页面功能
- **手机号验证**：实时验证手机号格式
- **验证码发送**：带倒计时的验证码发送
- **兴趣标签**：首次注册时选择兴趣标签
- **微信登录**：一键微信授权登录
- **用户协议**：协议和隐私政策展示

### 状态管理
- **用户信息**：全局用户状态管理
- **登录状态**：自动检查登录状态
- **本地存储**：自动保存和恢复用户信息

### UI设计
- **现代化界面**：渐变背景、卡片式设计
- **响应式布局**：适配不同屏幕尺寸
- **交互反馈**：按钮状态、加载动画

## 🔧 技术栈

- **Vue 3** + **Composition API**
- **TypeScript** 类型安全
- **Pinia** 状态管理
- **UniApp** 跨平台开发
- **Vite** 构建工具

## 📱 平台支持

- **微信小程序**：主要目标平台
- **抖音小程序**：次要目标平台
- **H5**：Web版本支持

## 🚀 下一步计划

1. **解决UniApp环境问题**
   - 使用HBuilderX创建标准项目
   - 迁移现有代码到新项目

2. **后端API对接**
   - 连接Go后端服务
   - 实现真实的登录接口

3. **功能完善**
   - 活动列表页面
   - 聊天功能
   - 会员系统

## 📞 技术支持

如果遇到问题，可以：

1. 查看HTML演示版本了解功能
2. 使用HBuilderX创建标准UniApp项目
3. 参考官方文档：https://uniapp.dcloud.net.cn/

## 🎉 当前可用功能

虽然UniApp环境有问题，但我们已经完成了：

- ✅ 完整的登录页面设计
- ✅ 用户状态管理逻辑
- ✅ API接口定义
- ✅ HTML演示版本
- ✅ 项目架构设计

所有代码都是标准的Vue 3 + TypeScript，可以直接迁移到任何UniApp项目中。
