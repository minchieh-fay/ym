<template>
  <view class="login-container">
    <!-- 顶部装饰 -->
    <view class="header-decoration">
      <view class="logo-section">
        <image class="logo" src="/static/logo.png" mode="aspectFit"></image>
        <text class="app-name">YM组局</text>
        <text class="app-desc">发现有趣的线下活动</text>
      </view>
    </view>

    <!-- 登录表单 -->
    <view class="login-form">
      <view class="form-title">
        <text class="title">欢迎加入</text>
        <text class="subtitle">开启你的社交新体验</text>
      </view>

      <!-- 手机号输入 -->
      <view class="input-group">
        <view class="input-wrapper">
          <text class="input-label">手机号</text>
          <input 
            class="input-field" 
            type="number" 
            v-model="phone" 
            placeholder="请输入手机号"
            maxlength="11"
            @input="onPhoneInput"
          />
        </view>
        <view class="error-msg" v-if="phoneError">{{ phoneError }}</view>
      </view>

      <!-- 验证码输入 -->
      <view class="input-group">
        <view class="input-wrapper">
          <text class="input-label">验证码</text>
          <view class="code-input-wrapper">
            <input 
              class="input-field code-input" 
              type="number" 
              v-model="code" 
              placeholder="请输入验证码"
              maxlength="6"
            />
            <button 
              class="code-btn" 
              :disabled="!canSendCode || countdown > 0"
              @click="sendCode"
            >
              {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
            </button>
          </view>
        </view>
        <view class="error-msg" v-if="codeError">{{ codeError }}</view>
      </view>

      <!-- 兴趣标签选择 -->
      <view class="interest-section" v-if="showInterests">
        <text class="section-title">选择你的兴趣标签</text>
        <view class="interest-tags">
          <view 
            class="interest-tag" 
            :class="{ active: selectedInterests.includes(tag) }"
            v-for="tag in interestTags" 
            :key="tag"
            @click="toggleInterest(tag)"
          >
            {{ tag }}
          </view>
        </view>
      </view>

      <!-- 登录按钮 -->
      <button 
        class="login-btn" 
        :class="{ disabled: !canLogin }"
        :disabled="!canLogin"
        @click="handleLogin"
      >
        {{ isLogin ? '登录中...' : (showInterests ? '完成注册' : '立即登录') }}
      </button>

      <!-- 微信登录 -->
      <view class="wechat-login" v-if="!showInterests">
        <view class="divider">
          <text class="divider-text">或</text>
        </view>
        <button 
          class="wechat-btn" 
          open-type="getUserInfo"
          @getuserinfo="onWechatLogin"
        >
          <text class="wechat-icon">📱</text>
          <text>微信一键登录</text>
        </button>
      </view>

      <!-- 用户协议 -->
      <view class="agreement">
        <text class="agreement-text">
          登录即表示同意
          <text class="link" @click="showAgreement">《用户协议》</text>
          和
          <text class="link" @click="showPrivacy">《隐私政策》</text>
        </text>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      phone: '',
      code: '',
      phoneError: '',
      codeError: '',
      countdown: 0,
      isLogin: false,
      showInterests: false,
      selectedInterests: [],
      interestTags: [
        '美食', '桌游', '户外', '运动', '咖啡', '电影', '音乐', '读书', '旅行', '摄影'
      ]
    }
  },
  computed: {
    canSendCode() {
      return /^1[3-9]\d{9}$/.test(this.phone)
    },
    canLogin() {
      if (this.showInterests) {
        return this.selectedInterests.length > 0
      }
      return /^1[3-9]\d{9}$/.test(this.phone) && /^\d{6}$/.test(this.code)
    }
  },
  methods: {
    onPhoneInput(e) {
      this.phone = e.detail.value
      this.phoneError = ''
    },
    
    sendCode() {
      if (!this.canSendCode) {
        this.phoneError = '请输入正确的手机号'
        return
      }

      this.phoneError = ''
      
      // 模拟发送验证码
      console.log('发送验证码到:', this.phone)
      
      // 开始倒计时
      this.countdown = 60
      const timer = setInterval(() => {
        this.countdown--
        if (this.countdown <= 0) {
          clearInterval(timer)
        }
      }, 1000)

      uni.showToast({
        title: '验证码已发送',
        icon: 'success'
      })
    },

    toggleInterest(tag) {
      const index = this.selectedInterests.indexOf(tag)
      if (index > -1) {
        this.selectedInterests.splice(index, 1)
      } else {
        this.selectedInterests.push(tag)
      }
    },

    handleLogin() {
      if (!this.canLogin) return

      this.isLogin = true

      // 验证手机号
      if (!/^1[3-9]\d{9}$/.test(this.phone)) {
        this.phoneError = '请输入正确的手机号'
        this.isLogin = false
        return
      }

      // 验证验证码
      if (!this.showInterests && !/^\d{6}$/.test(this.code)) {
        this.codeError = '请输入6位验证码'
        this.isLogin = false
        return
      }

      this.phoneError = ''
      this.codeError = ''

      // 模拟登录过程
      setTimeout(() => {
        if (this.showInterests) {
          // 完成注册
          this.completeRegistration()
        } else {
          // 检查是否是首次登录（模拟）
          const isFirstLogin = !uni.getStorageSync('userInfo')
          
          if (isFirstLogin) {
            // 首次登录，显示兴趣标签选择
            this.showInterests = true
            this.isLogin = false
          } else {
            // 老用户直接登录
            this.loginSuccess()
          }
        }
      }, 1500)
    },

    completeRegistration() {
      if (this.selectedInterests.length === 0) {
        uni.showToast({
          title: '请至少选择一个兴趣标签',
          icon: 'none'
        })
        this.isLogin = false
        return
      }

      const userInfo = {
        id: 1,
        phone: this.phone,
        nickname: '用户' + this.phone.slice(-4),
        avatar_url: '',
        gender: 0,
        city: '北京',
        status: 1,
        interests: this.selectedInterests,
        created_at: new Date().toISOString()
      }
      
      uni.setStorageSync('userInfo', userInfo)
      this.loginSuccess()
    },

    loginSuccess() {
      uni.showToast({
        title: '登录成功',
        icon: 'success'
      })

      // 跳转到首页
      setTimeout(() => {
        uni.navigateTo({
          url: '/pages/index/index'
        })
      }, 1500)
    },

    onWechatLogin(e) {
      const userInfo = e.detail.userInfo
      if (!userInfo) {
        uni.showToast({
          title: '授权失败',
          icon: 'error'
        })
        return
      }

      // 模拟微信登录
      const mockUserInfo = {
        id: 1,
        phone: '138****8888',
        nickname: userInfo.nickName || '微信用户',
        avatar_url: userInfo.avatarUrl || '',
        gender: userInfo.gender || 0,
        city: '北京',
        status: 1,
        created_at: new Date().toISOString()
      }
      
      uni.setStorageSync('userInfo', mockUserInfo)
      this.loginSuccess()
    },

    showAgreement() {
      uni.showModal({
        title: '用户协议',
        content: '用户协议内容：\n\n1. 用户在使用本服务前，请仔细阅读本协议。\n2. 用户在使用本服务时，应当遵守相关法律法规。\n3. 本协议的解释权归YM组局平台所有。',
        showCancel: false
      })
    },

    showPrivacy() {
      uni.showModal({
        title: '隐私政策',
        content: '隐私政策内容：\n\n1. 我们重视您的隐私保护。\n2. 我们仅收集必要的用户信息。\n3. 我们不会向第三方泄露您的个人信息。',
        showCancel: false
      })
    }
  },

  onLoad() {
    // 检查是否已经登录
    const userInfo = uni.getStorageSync('userInfo')
    if (userInfo) {
      uni.navigateTo({
        url: '/pages/index/index'
      })
    }
  }
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 0 40rpx;
}

.header-decoration {
  padding-top: 120rpx;
  text-align: center;
  margin-bottom: 80rpx;
}

.logo-section {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.logo {
  width: 120rpx;
  height: 120rpx;
  margin-bottom: 20rpx;
  background: #fff;
  border-radius: 20rpx;
}

.app-name {
  font-size: 48rpx;
  font-weight: bold;
  color: #fff;
  margin-bottom: 10rpx;
}

.app-desc {
  font-size: 28rpx;
  color: rgba(255, 255, 255, 0.8);
}

.login-form {
  background: #fff;
  border-radius: 24rpx;
  padding: 60rpx 40rpx;
  box-shadow: 0 20rpx 40rpx rgba(0, 0, 0, 0.1);
}

.form-title {
  text-align: center;
  margin-bottom: 60rpx;
}

.title {
  display: block;
  font-size: 40rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 10rpx;
}

.subtitle {
  font-size: 28rpx;
  color: #666;
}

.input-group {
  margin-bottom: 40rpx;
}

.input-wrapper {
  position: relative;
}

.input-label {
  display: block;
  font-size: 28rpx;
  color: #333;
  margin-bottom: 16rpx;
  font-weight: 500;
}

.input-field {
  width: 100%;
  height: 88rpx;
  background: #f8f9fa;
  border: 2rpx solid #e9ecef;
  border-radius: 12rpx;
  padding: 0 24rpx;
  font-size: 32rpx;
  color: #333;
  box-sizing: border-box;
}

.input-field:focus {
  border-color: #667eea;
  background: #fff;
}

.code-input-wrapper {
  display: flex;
  align-items: center;
  gap: 20rpx;
}

.code-input {
  flex: 1;
}

.code-btn {
  width: 200rpx;
  height: 88rpx;
  background: #667eea;
  color: #fff;
  border: none;
  border-radius: 12rpx;
  font-size: 28rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.code-btn:disabled {
  background: #ccc;
  color: #999;
}

.error-msg {
  font-size: 24rpx;
  color: #ff4757;
  margin-top: 10rpx;
}

.interest-section {
  margin-bottom: 40rpx;
}

.section-title {
  display: block;
  font-size: 28rpx;
  color: #333;
  margin-bottom: 24rpx;
  font-weight: 500;
}

.interest-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}

.interest-tag {
  padding: 16rpx 32rpx;
  background: #f8f9fa;
  border: 2rpx solid #e9ecef;
  border-radius: 40rpx;
  font-size: 28rpx;
  color: #666;
  transition: all 0.3s;
}

.interest-tag.active {
  background: #667eea;
  border-color: #667eea;
  color: #fff;
}

.login-btn {
  width: 100%;
  height: 88rpx;
  background: #667eea;
  color: #fff;
  border: none;
  border-radius: 12rpx;
  font-size: 32rpx;
  font-weight: bold;
  margin-bottom: 40rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.login-btn.disabled {
  background: #ccc;
  color: #999;
}

.wechat-login {
  margin-bottom: 40rpx;
}

.divider {
  text-align: center;
  margin: 40rpx 0;
  position: relative;
}

.divider::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  height: 2rpx;
  background: #e9ecef;
}

.divider-text {
  background: #fff;
  padding: 0 20rpx;
  font-size: 24rpx;
  color: #999;
}

.wechat-btn {
  width: 100%;
  height: 88rpx;
  background: #07c160;
  color: #fff;
  border: none;
  border-radius: 12rpx;
  font-size: 32rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16rpx;
}

.wechat-icon {
  font-size: 36rpx;
}

.agreement {
  text-align: center;
}

.agreement-text {
  font-size: 24rpx;
  color: #999;
  line-height: 1.5;
}

.link {
  color: #667eea;
  text-decoration: underline;
}
</style>

